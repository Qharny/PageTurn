import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/repository_locator.dart';

class LibraryProvider extends ChangeNotifier {
  static final LibraryProvider instance = LibraryProvider._internal();
  LibraryProvider._internal() {
    _libraryBooks.addAll(RepositoryLocator.localSource.getAllBooks());
  }

  final List<Book> _libraryBooks = [];

  List<Book> get books => List.unmodifiable(_libraryBooks);

  bool isBookmarked(String bookId) {
    return _libraryBooks.any((book) => book.id == bookId);
  }

  void toggleBookmark(Book book) {
    final index = _libraryBooks.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      _libraryBooks.removeAt(index);
      RepositoryLocator.localSource.deleteBook(book.id);
    } else {
      _libraryBooks.add(book);
      RepositoryLocator.localSource.saveBook(book);
    }
    notifyListeners();
  }

  void addBook(Book book) {
    if (!_libraryBooks.any((b) => b.id == book.id)) {
      _libraryBooks.add(book);
      RepositoryLocator.localSource.saveBook(book);
      notifyListeners();
    }
  }

  void removeBook(String bookId) {
    _libraryBooks.removeWhere((b) => b.id == bookId);
    RepositoryLocator.localSource.deleteBook(bookId);
    notifyListeners();
  }

  /// Replaces a book's entry entirely (e.g. after a download completes and
  /// it now has a [Book.localFilePath]), persisting the new state.
  void updateBook(Book updated) {
    final index = _libraryBooks.indexWhere((b) => b.id == updated.id);
    if (index >= 0) {
      _libraryBooks[index] = updated;
    } else {
      _libraryBooks.add(updated);
    }
    RepositoryLocator.localSource.saveBook(updated);
    notifyListeners();
  }

  void updateBookProgress(String bookId, double progress) {
    final index = _libraryBooks.indexWhere((b) => b.id == bookId);
    if (index >= 0) {
      final updated = _libraryBooks[index].copyWith(
        progress: progress,
        isFinished: progress >= 1.0,
      );
      _libraryBooks[index] = updated;
      RepositoryLocator.localSource.saveBook(updated);
      notifyListeners();
    }
  }
}
