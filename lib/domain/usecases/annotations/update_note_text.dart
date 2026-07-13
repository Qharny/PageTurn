import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';

/// Updates a note's text (or clears it, which downgrades it back to a plain
/// highlight — see [AnnotationRepository.updateNote]).
class UpdateNoteText {
  final AnnotationRepository _repository;

  UpdateNoteText(this._repository);

  Future<Annotation> call(String id, String? noteText) => _repository.updateNote(id, noteText);
}
