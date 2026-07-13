import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/annotation.dart';
import '../../models/annotation_model.dart';
import 'hive_boxes.dart';

/// On-device store for [Annotation]s — plain JSON maps in a Hive box, same
/// "no generated TypeAdapters" style as [HiveLocalSource]. Filters by
/// bookId/chapterId in Dart rather than maintaining secondary indexes:
/// annotation counts per device are small (tens to low hundreds), so a full
/// box scan on each read/watch tick is simpler and fast enough.
class AnnotationLocalSource {
  Box<Map>? _box;

  /// Assumes `Hive.init`/`initFlutter` has already run — [HiveLocalSource]
  /// does that as part of [RepositoryLocator.init]'s existing sequencing.
  /// Opening a second, differently-named box afterwards is safe.
  Future<void> init() async {
    try {
      _box = await Hive.openBox<Map>(HiveBoxes.annotations);
    } catch (e) {
      throw CacheException('Could not open annotation storage.', e);
    }
  }

  Box<Map> get _requireBox {
    final box = _box;
    if (box == null) {
      throw const CacheException('Annotation storage was not initialized.');
    }
    return box;
  }

  Future<void> put(Annotation annotation) async {
    try {
      await _requireBox.put(annotation.id, AnnotationModel.fromEntity(annotation).toJson());
    } catch (e) {
      throw CacheException('Could not save this annotation.', e);
    }
  }

  Future<void> delete(String id) async {
    await _requireBox.delete(id);
  }

  Annotation? getById(String id) {
    final raw = _requireBox.get(id);
    if (raw == null) return null;
    return AnnotationModel.fromJson(Map<String, dynamic>.from(raw)).toEntity();
  }

  List<Annotation> getAllForBook(String bookId) {
    return _requireBox.values
        .map((raw) => AnnotationModel.fromJson(Map<String, dynamic>.from(raw)).toEntity())
        .where((a) => a.bookId == bookId)
        .toList();
  }

  List<Annotation> getForChapter(String bookId, String chapterId) {
    return getAllForBook(bookId).where((a) => a.chapterId == chapterId).toList();
  }

  /// Reactive stream of every annotation for [bookId]: emits once
  /// immediately with the current contents, then again on every Hive write
  /// to this box (any key — this box only ever holds annotations, so a
  /// whole-box watch plus a bookId filter is simplest and correct).
  Stream<List<Annotation>> watchForBook(String bookId) async* {
    yield getAllForBook(bookId);
    await for (final _ in _requireBox.watch()) {
      yield getAllForBook(bookId);
    }
  }
}
