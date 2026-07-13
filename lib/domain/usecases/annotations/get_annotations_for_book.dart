import '../../entities/annotation.dart';
import '../../repositories/annotation_repository.dart';

/// Reactive stream of every annotation for a book — feeds `AnnotationProvider`
/// and, through it, both the in-reader painting and the annotations panel.
class GetAnnotationsForBook {
  final AnnotationRepository _repository;

  GetAnnotationsForBook(this._repository);

  Stream<List<Annotation>> call(String bookId) => _repository.watchForBook(bookId);
}
