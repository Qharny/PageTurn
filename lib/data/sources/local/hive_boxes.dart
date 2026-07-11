class HiveBoxes {
  HiveBoxes._();

  /// Books downloaded (Gutendex) or imported (local EPUB) — the on-device
  /// index that the library/continue-reading screens read from, keyed by
  /// [Book.id]. Google Books quick-add entries also live here.
  static const String downloadedBooks = 'downloaded_books_box';
}
