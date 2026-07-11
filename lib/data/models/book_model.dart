// The canonical Book/BookTag/BookReview types now live in
// domain/entities/book.dart (proper Clean Architecture placement). This
// file re-exports them so every existing `import '.../book_model.dart'`
// across the presentation layer keeps compiling unchanged.
export '../../domain/entities/book.dart';
