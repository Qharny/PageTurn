import '../../repositories/annotation_repository.dart';

class DeleteAnnotation {
  final AnnotationRepository _repository;

  DeleteAnnotation(this._repository);

  Future<void> call(String id) => _repository.delete(id);
}
