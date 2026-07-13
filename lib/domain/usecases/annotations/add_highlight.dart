import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';
import 'annotation_id.dart';
import 'annotation_merge.dart';

/// Adds a highlight, applying the v1 overlap-merge rule: if the new range
/// intersects an existing highlight/note in the same chapter+block, the two
/// merge into one annotation (see [AnnotationMerge]) instead of creating a
/// second overlapping highlight.
class AddHighlight {
  final AnnotationRepository _repository;

  AddHighlight(this._repository);

  /// [blockPlainText] is the full plain text of the block the selection
  /// falls in — needed to compute the correct `selectedText` if this ends
  /// up merging with an existing annotation.
  Future<Annotation> call({
    required String bookId,
    required String chapterId,
    required AnnotationAnchor anchor,
    required String selectedText,
    required String colorKey,
    required double progressPercent,
    required String blockPlainText,
  }) async {
    final now = DateTime.now();
    final incoming = Annotation(
      id: newAnnotationId(),
      bookId: bookId,
      type: AnnotationType.highlight,
      chapterId: chapterId,
      anchor: anchor.serialize(),
      selectedText: selectedText,
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
