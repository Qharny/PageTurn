import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';
import 'annotation_id.dart';
import 'annotation_merge.dart';

/// Adds a note: same shape/merge behavior as [AddHighlight] (a note is a
/// highlight with text attached), but always creates with
/// [AnnotationType.note] and a non-null [noteText] from the start, so it
/// still reads correctly in the Notes filter even before any merge occurs.
class AddNote {
  final AnnotationRepository _repository;

  AddNote(this._repository);

  Future<Annotation> call({
    required String bookId,
    required String chapterId,
    required AnnotationAnchor anchor,
    required String selectedText,
    required String noteText,
    required String colorKey,
    required double progressPercent,
    required String blockPlainText,
  }) async {
    final now = DateTime.now();
    final incoming = Annotation(
      id: newAnnotationId(),
      bookId: bookId,
      type: AnnotationType.note,
      chapterId: chapterId,
      anchor: anchor.serialize(),
      selectedText: selectedText,
      noteText: noteText,
      colorKey: colorKey,
      progressPercent: progressPercent,
      createdAt: now,
      updatedAt: now,
    );

    final existingInChapter = await _repository.getForChapter(bookId, chapterId);
    for (final existing in existingInChapter) {
      final merged = AnnotationMerge.tryMerge(
        existing: existing,
        incoming: incoming,
        blockPlainText: blockPlainText,
      );
      if (merged != null) {
        return _repository.add(merged.copyWith(id: existing.id));
      }
    }

    return _repository.add(incoming);
  }
}
