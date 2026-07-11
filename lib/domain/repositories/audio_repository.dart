import '../entities/book.dart';

/// Audiobook catalog access, backed by LibriVox.
abstract class AudioRepository {
  /// Searches LibriVox audiobooks. All params are optional filters.
  Future<List<Book>> searchAudiobooks({
    String? title,
    String? author,
    String? genre,
    int limit = 20,
    int offset = 0,
  });

  /// LibriVox's most-recently-catalogued books — used for browse/trending.
  Future<List<Book>> recentAudiobooks({int limit = 20, int offset = 0});

  /// A single LibriVox audiobook, with its section/chapter list populated.
  Future<Book> getAudiobook(String remoteId);
}
