import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';

/// Changes a highlight/note's color. Not in the brief's named usecase list,
/// but added for consistency: the highlight-edit sheet (Phase 3) needs a
/// "change color" action, and every other mutation goes through a usecase
/// rather than the reader calling `AnnotationRepository` directly.
class ChangeAnnotationColor {
  final AnnotationRepository _repository;

  ChangeAnnotationColor(this._repository);

  Future<Annotation> call(String id, String colorKey) => _repository.changeColor(id, colorKey);
}
