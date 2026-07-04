import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import '../home/mock_books.dart';

class LibraryProvider extends ChangeNotifier {
  static final LibraryProvider instance = LibraryProvider._internal();
  LibraryProvider._internal();

  final List<Book> _libraryBooks = [
    MockBooks.midnightLibrary,
    MockBooks.atomicHabits,
    MockBooks.dune,
    MockBooks.educated,
    MockBooks.greatGatsby,
  ];

  List<Book> get books => List.unmodifiable(_libraryBooks);

  bool isBookmarked(String bookId) {
    return _libraryBooks.any((book) => book.id == bookId);
  }

  void toggleBookmark(Book book) {
    final index = _libraryBooks.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _libraryBooks.removeAt(index);
    } else {
      _libraryBooks.add(book);
    }
    notifyListeners();
  }

  void addBook(Book book) {
    if (!_libraryBooks.any((b) => b.id == book.id)) {
      _libraryBooks.add(book);
      notifyListeners();
    }
  }

  void removeBook(String bookId) {
    _libraryBooks.removeWhere((b) => b.id == bookId);
    notifyListeners();
  }

  void updateBookProgress(String bookId, double progress) {
    final index = _libraryBooks.indexWhere((b) => b.id == bookId);
    if (index >= 0) {
      final oldBook = _libraryBooks[index];
      _libraryBooks[index] = Book(
        id: oldBook.id,
        title: oldBook.title,
        author: oldBook.author,
        coverAsset: oldBook.coverAsset,
        rating: oldBook.rating,
        reviewCount: oldBook.reviewCount,
        length: oldBook.length,
        audioDuration: oldBook.audioDuration,
        language: oldBook.language,
        description: oldBook.description,
        tags: oldBook.tags,
        reviews: oldBook.reviews,
        progress: progress,
        isFinished: progress >= 1.0 ? true : oldBook.isFinished,
      );
      notifyListeners();
    }
  }
}
