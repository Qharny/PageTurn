/// App-wide configuration switches and third-party API base URLs.
class AppConfig {
  AppConfig._();

  /// When true, the library's demo seed books ([MockBooks]) are shown
  /// alongside anything real that's been downloaded/imported/quick-added.
  /// This only affects the initial Library seed list — search, audiobook
  /// browsing, quick-add, and EPUB import always use the real Gutendex/
  /// LibriVox/Google Books sources regardless of this flag. Keeping it true
  /// preserves the existing demo experience out of the box.
  static const bool useMockData = true;

  static const String gutendexBaseUrl = 'https://gutendex.com';
  static const String libriVoxBaseUrl = 'https://librivox.org/api/feed/audiobooks';
  static const String googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/volumes';

  static const Duration httpTimeout = Duration(seconds: 20);
}
