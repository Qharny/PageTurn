import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../core/errors/failure.dart';
import '../../data/sources/local/epub_parser.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/chapter.dart';
import 'reader_block_parser.dart';

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

  /// This chapter's block-level split (see `reader_block_parser.dart`) —
  /// what gives annotations a stable `blockIndex` to anchor against, and
  /// what the reader renders one `HtmlWidget` per, instead of one opaque
  /// whole-chapter blob. Memoized per chapter index: block splitting
  /// reparses HTML, so it's only redone when the chapter actually changes,
  /// not on every rebuild (font-size changes, annotation updates, etc.).
  final Map<int, List<ReaderBlock>> _blocksByChapter = {};

  List<ReaderBlock> get currentBlocks {
    final chapter = currentChapter;
    if (chapter == null) return const [];
    return _blocksByChapter.putIfAbsent(
      currentChapterIndex,
      () => splitChapterIntoBlocks(chapter.contentHtml),
    );
  }

  /// The reader identifies chapters by their list index — `EpubChapterRef`
  /// has no id of its own (see the Phase 0 audit).
  String get currentChapterId => currentChapterIndex.toString();

  /// 0.0-1.0 position in the book for a given block within the current
  /// chapter, used as `Annotation.progressPercent`. Approximates evenly by
  /// chapter count + block position within the chapter — there is no finer
  /// reading-position tracking anywhere else in the app to build on (see
  /// Phase 0 audit: `Book.progress` is never written by the reader).
  double progressForBlock(int blockIndex) {
    if (chapters.isEmpty) return 0.0;
    final blocks = currentBlocks;
    final blockFraction = blocks.isEmpty ? 0.0 : blockIndex / blocks.length;
    return ((currentChapterIndex + blockFraction) / chapters.length).clamp(0.0, 1.0);
  }

  Future<void> loadBook(Book targetBook) async {
    book = targetBook;
    status = ReaderStatus.loading;
    error = null;
    currentChapterIndex = 0;
    _blocksByChapter.clear(); // stale cache would collide by index across books
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
