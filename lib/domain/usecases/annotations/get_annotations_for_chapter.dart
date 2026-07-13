import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';

/// One-shot fetch scoped to a single chapter — used when a chapter loads, so
/// the reader only pays for that chapter's annotations rather than the
/// whole book (performance constraint from the brief).
class GetAnnotationsForChapter {
  final AnnotationRepository _repository;

  GetAnnotationsForChapter(this._repository);

  Future<List<Annotation>> call(String bookId, String chapterId) =>
      _repository.getForChapter(bookId, chapterId);
}
