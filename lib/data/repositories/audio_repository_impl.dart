import '../../domain/entities/book.dart';
import '../../domain/repositories/audio_repository.dart';
import '../models/librivox_audiobook_model.dart';
import '../sources/local/api_cache_source.dart';
import '../sources/local/hive_local_source.dart';
import '../sources/remote/google_books_source.dart';
import '../sources/remote/librivox_source.dart';

class AudioRepositoryImpl implements AudioRepository {
  final LibriVoxSource _libriVox;
  final GoogleBooksSource _googleBooks;
  final HiveLocalSource _localSource;
  final ApiCacheSource _cache;

  AudioRepositoryImpl({
    required this._libriVox,
    required this._googleBooks,
    required this._localSource,
    required this._cache,
  });

  @override
  Future<List<Book>> searchAudiobooks({
    String? title,
    String? author,
    String? genre,
    int limit = 20,
    int offset = 0,
  }) async {
    final key = 'librivox_search_${title ?? ''}_${author ?? ''}_${genre ?? ''}_l${limit}_o$offset';
    final books = await _cache.cachedList(key, () async {
      final models = await _libriVox.search(
        title: title,
        author: author,
        genre: genre,
        limit: limit,
        offset: offset,
      );
      return _toEntities(models);
    });
    return books.map(_mergeWithLocalState).toList();
  }

  @override
  Future<List<Book>> recentAudiobooks({int limit = 20, int offset = 0}) async {
    final books = await _cache.cachedList('librivox_recent_l${limit}_o$offset', () async {
      final models = await _libriVox.recent(limit: limit, offset: offset);
      return _toEntities(models);
    });
    return books.map(_mergeWithLocalState).toList();
  }

  @override
  Future<Book> getAudiobook(String remoteId) async {
    final book = await _cache.cachedBook('librivox_book_$remoteId', () async {
      final model = await _libriVox.getById(remoteId);
      return _withCoverFallback(model.toEntity());
    });
    return _mergeWithLocalState(book);
  }

  /// Cover enrichment is best-effort and only needed for the handful of
  /// results actually missing art, so it's done per-book rather than
  /// blocking the whole list on one slow/rate-limited lookup. Local reading
  /// state is deliberately not merged here — that happens after this
  /// (cacheable) result is read back from cache, so it always reflects the
  /// caller's current progress/downloads regardless of cache age.
  Future<List<Book>> _toEntities(List<LibriVoxAudiobookModel> models) async {
    final books = models.map((m) => m.toEntity()).toList();
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
