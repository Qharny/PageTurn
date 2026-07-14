import 'package:hive_flutter/hive_flutter.dart';

import 'hive_boxes.dart';

/// On-device cache of each book's computed dominant cover-color category
/// name, keyed by book id. Downloading and analyzing a cover image is
/// relatively expensive, so a resolved category is persisted here and never
/// recomputed for the same book.
class CoverColorCache {
  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(HiveBoxes.coverColors);
  }

  Box<String> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError('CoverColorCache.init() must be awaited before use.');
    }
    return box;
  }

  String? get(String bookId) => _requireBox.get(bookId);

  Future<void> put(String bookId, String categoryName) => _requireBox.put(bookId, categoryName);
}
