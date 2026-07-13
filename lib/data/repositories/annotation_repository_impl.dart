import '../../core/errors/app_exception.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../../domain/usecases/annotations/annotation_id.dart';
import '../sources/local/annotation_local_source.dart';

/// Local-first [AnnotationRepository] backed by Hive. Guest-first, like the
/// rest of the app's local data — no auth check anywhere in this file.
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationLocalSource _local;

  AnnotationRepositoryImpl({required AnnotationLocalSource localSource}) : _local = localSource;

  @override
  Stream<List<Annotation>> watchForBook(String bookId) => _local.watchForBook(bookId);

  @override
  Future<List<Annotation>> getForChapter(String bookId, String chapterId) async {
    return _local.getForChapter(bookId, chapterId);
  }

  @override
  Future<Annotation> add(Annotation annotation) async {
    await _local.put(annotation);
    // SYNC: once remote sync exists, enqueue `annotation` for push here
    // (or let a background sync worker diff against `updatedAt`). Every
    // mutation in this file already sets `updatedAt` to `DateTime.now()`,
    // which is what a last-write-wins merge would compare against.
    return annotation;
  }

  @override
  Future<Annotation> updateNote(String id, String? noteText) async {
    final existing = _local.getById(id);
    if (existing == null) {
      throw const NotFoundException('This annotation no longer exists.');
    }
    // Bookmarks have no note concept — leave untouched rather than error,
    // so a stale UI action on a since-changed annotation is a harmless no-op.
    if (existing.type == AnnotationType.bookmark) return existing;

    final trimmed = noteText?.trim();
    final hasNote = trimmed != null && trimmed.isNotEmpty;
    final updated = existing.copyWith(
      type: hasNote ? AnnotationType.note : AnnotationType.highlight,
      noteText: hasNote ? trimmed : null,
      clearNoteText: !hasNote,
      updatedAt: DateTime.now(),
    );
    await _local.put(updated);
    // SYNC: push `updated` here (see note in `add`).
    return updated;
  }

  @override
  Future<Annotation> changeColor(String id, String colorKey) async {
    final existing = _local.getById(id);
    if (existing == null) {
      throw const NotFoundException('This annotation no longer exists.');
    }
    if (existing.type == AnnotationType.bookmark) return existing; // bookmarks have no color

    final updated = existing.copyWith(colorKey: colorKey, updatedAt: DateTime.now());
    await _local.put(updated);
    // SYNC: push `updated` here (see note in `add`).
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _local.delete(id);
    // SYNC: enqueue a tombstone/delete push here once remote sync exists.
  }

  @override
  Future<Annotation?> toggleBookmark(
    String bookId,
    String chapterId,
    String anchor,
    double progressPercent,
  ) async {
    final chapterAnnotations = _local.getForChapter(bookId, chapterId);
    Annotation? existingBookmark;
    for (final a in chapterAnnotations) {
      if (a.type == AnnotationType.bookmark && a.anchor == anchor) {
        existingBookmark = a;
        break;
      }
    }

    if (existingBookmark != null) {
      await _local.delete(existingBookmark.id);
      // SYNC: enqueue a tombstone push here (see note in `delete`).
      return null;
    }

    final now = DateTime.now();
    final created = Annotation(
      id: newAnnotationId(),
      bookId: bookId,
      type: AnnotationType.bookmark,
      chapterId: chapterId,
      anchor: anchor,
      progressPercent: progressPercent,
      createdAt: now,
      updatedAt: now,
    );
    await _local.put(created);
    // SYNC: push `created` here (see note in `add`).
    return created;
  }
}
