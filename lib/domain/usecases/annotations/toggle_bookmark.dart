import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';

/// Toggles a bookmark at the reader's current position. Thin wrapper around
/// [AnnotationRepository.toggleBookmark] — kept as its own usecase (rather
/// than calling the repository directly from the provider) so the reader
/// only ever depends on the usecase layer, matching every other mutation.
class ToggleBookmark {
  final AnnotationRepository _repository;

  ToggleBookmark(this._repository);

  Future<Annotation?> call({
    required String bookId,
    required String chapterId,
    required String anchor,
    required double progressPercent,
  }) {
    return _repository.toggleBookmark(bookId, chapterId, anchor, progressPercent);
  }
}
