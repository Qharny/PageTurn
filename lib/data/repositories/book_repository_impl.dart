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
import '../sources/local/api_cache_source.dart';
import '../sources/local/hive_local_source.dart';
import '../sources/remote/google_books_source.dart';
import '../sources/remote/gutendex_source.dart';
import '../sources/remote/local_epub_import_source.dart';

class BookRepositoryImpl implements BookRepository {
  final GutendexSource _gutendex;
  final GoogleBooksSource _googleBooks;
  final HiveLocalSource _localSource;
  final LocalEpubImportSource _importSource;
  final ApiCacheSource _cache;
  final http.Client _downloadClient;

  BookRepositoryImpl({
    required GutendexSource gutendex,
    required GoogleBooksSource googleBooks,
    required HiveLocalSource localSource,
    required LocalEpubImportSource importSource,
    required ApiCacheSource cache,
    http.Client? downloadClient,
  })  : _gutendex = gutendex,
        _googleBooks = googleBooks,
        _localSource = localSource,
        _importSource = importSource,
        _cache = cache,
        _downloadClient = downloadClient ?? http.Client();

  @override
  Future<List<Book>> searchBooks(String query, {int page = 1}) async {
    final books = await _cache.cachedList('gutendex_search_${query.toLowerCase()}_p$page', () async {
      final result = await _gutendex.searchBooks(query, page: page);
      return result.books.map((b) => b.toEntity()).toList();
    });
    return _mergeWithLocalState(books);
  }

  @override
  Future<List<Book>> browseByTopic(String topic, {int page = 1}) async {
    final books = await _cache.cachedList('gutendex_topic_${topic.toLowerCase()}_p$page', () async {
      final result = await _gutendex.browseByTopic(topic, page: page);
      return result.books.map((b) => b.toEntity()).toList();
    });
    return _mergeWithLocalState(books);
  }

  @override
  Future<List<Book>> popularBooks({int page = 1}) async {
    final books = await _cache.cachedList('gutendex_popular_p$page', () async {
      final result = await _gutendex.popularBooks(page: page);
      return result.books.map((b) => b.toEntity()).toList();
    });
    return _mergeWithLocalState(books);
  }

  @override
  Future<Book> getBook(String id) async {
    final book = await _cache.cachedBook(
      'gutendex_book_$id',
      () async => (await _gutendex.getBook(id)).toEntity(),
    );
    return _mergeOneWithLocalState(book);
  }

  @override
  Future<List<Book>> searchGoogleBooks(String query, {int startIndex = 0}) async {
    final books = await _cache.cachedList('google_search_${query.toLowerCase()}_i$startIndex', () async {
      final volumes = await _googleBooks.searchVolumes(query, startIndex: startIndex);
      return volumes.map((v) => v.toEntity()).toList();
    });
    return _mergeWithLocalState(books);
  }

  @override
  Future<Book> getGoogleBooksVolume(String id) async {
    final book = await _cache.cachedBook(
      'google_volume_$id',
      () async => (await _googleBooks.getVolume(id)).toEntity(),
    );
    return _mergeOneWithLocalState(book);
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
