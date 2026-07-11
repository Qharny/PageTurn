import '../../domain/entities/book.dart';
import '../../domain/repositories/audio_repository.dart';
import '../models/librivox_audiobook_model.dart';
import '../sources/local/hive_local_source.dart';
import '../sources/remote/google_books_source.dart';
import '../sources/remote/librivox_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final LibriVoxSource _libriVox;
  final GoogleBooksSource _googleBooks;
  final HiveLocalSource _localSource;

  AudioRepositoryImpl({
    required this._libriVox,
    required this._googleBooks,
    required this._localSource,
  });

  @override
  Future<List<Book>> searchAudiobooks({
    String? title,
    String? author,
    String? genre,
    int limit = 20,
    int offset = 0,
  }) async {
    final models = await _libriVox.search(
      title: title,
      author: author,
      genre: genre,
      limit: limit,
      offset: offset,
    );
    return _toEntities(models);
  }

  @override
  Future<List<Book>> recentAudiobooks({int limit = 20, int offset = 0}) async {
    final models = await _libriVox.recent(limit: limit, offset: offset);
    return _toEntities(models);
  }

  @override
  Future<Book> getAudiobook(String remoteId) async {
    final model = await _libriVox.getById(remoteId);
    final book = model.toEntity();
    return _withCoverFallback(_mergeWithLocalState(book));
  }

  Future<List<Book>> _toEntities(List<LibriVoxAudiobookModel> models) async {
    final books = models.map((m) => m.toEntity()).map(_mergeWithLocalState).toList();
    // Cover enrichment is best-effort and only needed for the handful of
    // results actually missing art, so it's done per-book rather than
    // blocking the whole list on one slow/rate-limited lookup.
    return Future.wait(books.map(_withCoverFallback));
  }

  Book _mergeWithLocalState(Book book) {
    final local = _localSource.getBook(book.id);
    if (local == null) return book;
    return book.copyWith(progress: local.progress, isFinished: local.isFinished);
  }

  Future<Book> _withCoverFallback(Book book) async {
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) return book;
    final enrichment = await _googleBooks.enrichMetadata(book.title, book.author);
    if (enrichment?.coverUrl == null) return book;
    return book.copyWith(coverUrl: enrichment!.coverUrl);
  }
}
