/// App-wide configuration switches and third-party API base URLs.
class AppConfig {
  AppConfig._();

  /// Kept for backward compatibility; the library no longer seeds demo
  /// books, so this flag currently has no effect. Search, audiobook
  /// browsing, quick-add, and EPUB import always use the real Gutendex/
  /// LibriVox/Google Books sources.
  static const bool useMockData = false;

  static const String gutendexBaseUrl = 'https://gutendex.com';
  static const String libriVoxBaseUrl = 'https://librivox.org/api/feed/audiobooks';
  static const String googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static const Duration httpTimeout = Duration(seconds: 20);
}
