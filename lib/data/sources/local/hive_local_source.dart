import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/book.dart';
import 'hive_boxes.dart';

/// On-device index of books whose content lives on disk (downloaded
/// Gutendex EPUBs, locally-imported EPUBs) or that were quick-added as
/// metadata-only (Google Books). Stores each [Book] as a plain JSON map —
/// no generated TypeAdapters needed.
class HiveLocalSource {
  Box<Map>? _box;

  /// [testDirectoryPath] bypasses `path_provider` (unavailable in plain
  /// `flutter test`) so tests can point Hive at a temp directory directly.
  Future<void> init({String? testDirectoryPath}) async {
    try {
      if (testDirectoryPath != null) {
        Hive.init(testDirectoryPath);
      } else {
        await Hive.initFlutter();
      }
      _box = await Hive.openBox<Map>(HiveBoxes.downloadedBooks);
    } catch (e) {
      throw CacheException('Could not open local storage.', e);
    }
  }

  Box<Map> get _requireBox {
    final box = _box;
    if (box == null) {
      throw const CacheException('Local storage was not initialized.');
    }
    return box;
  }

  Future<void> saveBook(Book book) async {
    try {
      await _requireBox.put(book.id, book.toJson());
    } catch (e) {
      throw CacheException('Could not save this book locally.', e);
    }
  }

  List<Book> getAllBooks() {
    try {
      return _requireBox.values
          .map((raw) => Book.fromJson(Map<String, dynamic>.from(raw)))
          .toList();
    } catch (e) {
      throw CacheException('Could not read your local library.', e);
    }
  }

  Book? getBook(String id) {
    final raw = _requireBox.get(id);
    if (raw == null) return null;
    return Book.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<void> deleteBook(String id) async {
    await _requireBox.delete(id);
  }

  bool isDownloaded(String id) => _requireBox.containsKey(id);
}
