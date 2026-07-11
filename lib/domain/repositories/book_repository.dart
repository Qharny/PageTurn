import '../entities/book.dart';

/// Ebook catalog + content access, backed by Gutendex, Google Books, and
/// local EPUB import. Every list method is paginated.
abstract class BookRepository {
  /// Full-text search across the Gutendex catalog.
  Future<List<Book>> searchBooks(String query, {int page = 1});

  /// Browse Gutendex by subject/topic (e.g. 'fantasy', 'history').
  Future<List<Book>> browseByTopic(String topic, {int page = 1});

  /// Gutendex's default sort (by download count) — used for trending/home.
  Future<List<Book>> popularBooks({int page = 1});

  /// A single Gutendex book by its catalog id.
  Future<Book> getBook(String id);

  /// Google Books metadata search, used by the quick-add flow.
  Future<List<Book>> searchGoogleBooks(String query, {int startIndex = 0});

  /// A single Google Books volume by its volume id.
  Future<Book> getGoogleBooksVolume(String id);

  /// Downloads [book]'s EPUB to app storage and registers it in the local
  /// index so the library/continue-reading screens see it immediately.
  /// Returns the on-device file path. [onProgress] receives 0.0–1.0.
  Future<String> downloadBook(Book book, {void Function(double progress)? onProgress});

  /// Lets the user pick an EPUB from device storage, copies it into app
  /// storage, parses its metadata, and returns a ready-to-save [Book].
  /// Returns null if the user cancelled the picker.
  Future<Book?> importLocalEpub();
}
