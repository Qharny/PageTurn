// Constructor uses named public params mapped to private fields deliberately
// (keeps the DI call sites readable); initializing-formal lint disabled.
// ignore_for_file: prefer_initializing_formals
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../config/env.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../sources/local/hive_local_source.dart';
import '../sources/remote/google_books_source.dart';
import '../sources/remote/gutendex_source.dart';
import '../sources/remote/local_epub_import_source.dart';

class BookRepositoryImpl implements BookRepository {
  final GutendexSource _gutendex;
  final GoogleBooksSource _googleBooks;
  final HiveLocalSource _localSource;
  final LocalEpubImportSource _importSource;
  final http.Client _downloadClient;

  BookRepositoryImpl({
    required GutendexSource gutendex,
    required GoogleBooksSource googleBooks,
    required HiveLocalSource localSource,
    required LocalEpubImportSource importSource,
    http.Client? downloadClient,
  })  : _gutendex = gutendex,
        _googleBooks = googleBooks,
        _localSource = localSource,
        _importSource = importSource,
        _downloadClient = downloadClient ?? http.Client();

  @override
  Future<List<Book>> searchBooks(String query, {int page = 1}) async {
    final result = await _gutendex.searchBooks(query, page: page);
    return _mergeWithLocalState(result.books.map((b) => b.toEntity()).toList());
  }

  @override
  Future<List<Book>> browseByTopic(String topic, {int page = 1}) async {
    final result = await _gutendex.browseByTopic(topic, page: page);
    return _mergeWithLocalState(result.books.map((b) => b.toEntity()).toList());
  }

  @override
  Future<List<Book>> popularBooks({int page = 1}) async {
    final result = await _gutendex.popularBooks(page: page);
    return _mergeWithLocalState(result.books.map((b) => b.toEntity()).toList());
  }

  @override
  Future<Book> getBook(String id) async {
    final model = await _gutendex.getBook(id);
    return _mergeOneWithLocalState(model.toEntity());
  }

  @override
  Future<List<Book>> searchGoogleBooks(String query, {int startIndex = 0}) async {
    final volumes = await _googleBooks.searchVolumes(query, startIndex: startIndex);
    return _mergeWithLocalState(volumes.map((v) => v.toEntity()).toList());
  }

  @override
  Future<Book> getGoogleBooksVolume(String id) async {
    final volume = await _googleBooks.getVolume(id);
    return _mergeOneWithLocalState(volume.toEntity());
  }

  /// If we already have a local (downloaded/imported/saved) copy of a book
  /// with the same id, prefer its state (local file path, reading progress)
  /// over the freshly-fetched remote metadata.
  List<Book> _mergeWithLocalState(List<Book> books) {
    return books.map(_mergeOneWithLocalState).toList();
  }

  Book _mergeOneWithLocalState(Book book) {
    final local = _localSource.getBook(book.id);
    if (local == null) return book;
    return book.copyWith(
      localFilePath: local.localFilePath,
      progress: local.progress,
      isFinished: local.isFinished,
    );
  }

  @override
  Future<String> downloadBook(Book book, {void Function(double progress)? onProgress}) async {
    final url = book.downloadUrl;
    if (url == null || url.isEmpty) {
      throw const NotFoundException('This book has no downloadable file.');
    }

    final destPath = await _downloadToAppStorage(url, '${book.id}.epub', onProgress);

    final savedBook = book.copyWith(localFilePath: destPath);
    await _localSource.saveBook(savedBook);
    return destPath;
  }

  Future<String> _downloadToAppStorage(
    String url,
    String fileName,
    void Function(double progress)? onProgress,
  ) async {
    http.StreamedResponse response;
    try {
      final request = http.Request('GET', Uri.parse(url));
      response = await _downloadClient.send(request).timeout(AppConfig.httpTimeout * 6);
    } catch (e) {
      throw NetworkException('Could not download this book.', e);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ServerException('Download failed (${response.statusCode}).');
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final epubDir = Directory('${dir.path}/epubs');
      if (!await epubDir.exists()) {
        await epubDir.create(recursive: true);
      }
      final destPath = '${epubDir.path}/$fileName';
      final file = File(destPath);
      final sink = file.openWrite();

      final total = response.contentLength ?? 0;
      var received = 0;
      await response.stream.map((chunk) {
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
        return chunk;
      }).pipe(sink);
      await sink.close();

      return destPath;
    } catch (e) {
      throw FileException('Could not save the downloaded file.', e);
    }
  }

  @override
  Future<Book?> importLocalEpub() => _importSource.pickAndImport();

  void dispose() {
    _gutendex.dispose();
    _downloadClient.close();
  }
}
