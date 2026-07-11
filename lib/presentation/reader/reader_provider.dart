import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/errors/failure.dart';
import '../../data/sources/local/epub_parser.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';

enum ReaderStatus { idle, loading, ready, error }

/// Drives the ebook reader: parses the book's on-device EPUB once and holds
/// chapter navigation + font-size state. Works the same for a downloaded
/// Gutendex book or a locally-imported one — both simply have
/// [Book.localFilePath] set by the time they reach this provider.
class ReaderProvider extends ChangeNotifier {
  final EpubParser _parser;

  ReaderProvider({EpubParser? parser}) : _parser = parser ?? EpubParser();

  ReaderStatus status = ReaderStatus.idle;
  Failure? error;
  Book? book;
  List<EpubChapterRef> chapters = [];
  int currentChapterIndex = 0;
  double fontSize = 17;

  EpubChapterRef? get currentChapter =>
      chapters.isEmpty ? null : chapters[currentChapterIndex.clamp(0, chapters.length - 1)];

  Future<void> loadBook(Book targetBook) async {
    book = targetBook;
    status = ReaderStatus.loading;
    error = null;
    currentChapterIndex = 0;
    notifyListeners();

    final path = targetBook.localFilePath;
    if (path == null || path.isEmpty) {
      status = ReaderStatus.error;
      error = const FileFailure('This book has not been downloaded yet.');
      notifyListeners();
      return;
    }

    try {
      final parsed = _parser.parse(File(path));
      chapters = parsed.chapters;
      status = ReaderStatus.ready;
    } on Exception catch (e) {
      status = ReaderStatus.error;
      error = const FileFailure('This EPUB could not be opened. It may be corrupted.');
      debugPrint('EPUB parse failed: $e');
    }
    notifyListeners();
  }

  void nextChapter() {
    if (currentChapterIndex < chapters.length - 1) {
      currentChapterIndex++;
      notifyListeners();
    }
  }

  void previousChapter() {
    if (currentChapterIndex > 0) {
      currentChapterIndex--;
      notifyListeners();
    }
  }

  void jumpToChapter(int index) {
    if (index >= 0 && index < chapters.length) {
      currentChapterIndex = index;
      notifyListeners();
    }
  }

  void increaseFontSize() {
    fontSize = (fontSize + 1).clamp(12, 28);
    notifyListeners();
  }

  void decreaseFontSize() {
    fontSize = (fontSize - 1).clamp(12, 28);
    notifyListeners();
  }
}
