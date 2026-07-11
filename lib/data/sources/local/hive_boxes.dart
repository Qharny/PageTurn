class HiveBoxes {
  HiveBoxes._();

  /// Books downloaded (Gutendex) or imported (local EPUB) — the on-device
  /// index that the library/continue-reading screens read from, keyed by
  /// [Book.id]. Google Books quick-add entries also live here.
  static const String downloadedBooks = 'downloaded_books_box';

  /// Time-boxed cache of remote API responses (search/browse/popular list
  /// pages and individual book lookups), so repeated navigation doesn't
  /// re-hit Gutendex/Google Books/LibriVox every time. Separate from
  /// [downloadedBooks], which represents the user's actual library.
  static const String apiCache = 'api_cache_box';
}
