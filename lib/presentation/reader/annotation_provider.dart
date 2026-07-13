import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/repository_locator.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/usecases/annotations/add_highlight.dart';
import '../../domain/usecases/annotations/add_note.dart';
import '../../domain/usecases/annotations/change_annotation_color.dart';
import '../../domain/usecases/annotations/delete_annotation.dart';
import '../../domain/usecases/annotations/get_annotations_for_book.dart';
import '../../domain/usecases/annotations/toggle_bookmark.dart';
import '../../domain/usecases/annotations/update_note_text.dart';

/// `ChangeNotifier` scoped to one open book, fed reactively by
/// `GetAnnotationsForBook` (→ `AnnotationRepository.watchForBook`). Mutation
/// methods never throw — persistence failures resolve to a returned error
/// message string instead, so callers (toolbar/sheets) can show a snackbar
/// and, for notes specifically, keep the user's typed text in the sheet
/// rather than losing it (per the brief's error-handling constraint).
///
/// Hive writes are local and effectively synchronous from a UI-latency
/// standpoint, so "optimistic" paint is achieved simply by relying on the
/// `watchForBook` stream (fed by `Box.watch()`) to reflect a mutation within
/// a frame or two — no separate optimistic cache is layered on top.
class AnnotationProvider extends ChangeNotifier {
  final String bookId;

  final AddHighlight _addHighlightUsecase;
  final AddNote _addNoteUsecase;
  final ToggleBookmark _toggleBookmarkUsecase;
  final DeleteAnnotation _deleteAnnotationUsecase;
  final UpdateNoteText _updateNoteTextUsecase;
  final ChangeAnnotationColor _changeColorUsecase;

  StreamSubscription<List<Annotation>>? _subscription;
  List<Annotation> _annotations = const [];
  bool _isLoading = true;

  AnnotationProvider({
    required this.bookId,
    AddHighlight? addHighlight,
    AddNote? addNote,
    ToggleBookmark? toggleBookmark,
    DeleteAnnotation? deleteAnnotation,
    UpdateNoteText? updateNoteText,
    ChangeAnnotationColor? changeColor,
    GetAnnotationsForBook? getAnnotationsForBook,
  })  : _addHighlightUsecase = addHighlight ?? AddHighlight(RepositoryLocator.annotationRepository),
        _addNoteUsecase = addNote ?? AddNote(RepositoryLocator.annotationRepository),
        _toggleBookmarkUsecase = toggleBookmark ?? ToggleBookmark(RepositoryLocator.annotationRepository),
        _deleteAnnotationUsecase = deleteAnnotation ?? DeleteAnnotation(RepositoryLocator.annotationRepository),
        _updateNoteTextUsecase = updateNoteText ?? UpdateNoteText(RepositoryLocator.annotationRepository),
        _changeColorUsecase = changeColor ?? ChangeAnnotationColor(RepositoryLocator.annotationRepository) {
    final getAll = getAnnotationsForBook ?? GetAnnotationsForBook(RepositoryLocator.annotationRepository);
    _subscription = getAll(bookId).listen(
      (list) {
        _annotations = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object _) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  bool get isLoading => _isLoading;
  List<Annotation> get all => _annotations;

  List<Annotation> forChapter(String chapterId) =>
      _annotations.where((a) => a.chapterId == chapterId).toList();

  /// Highlights and notes only (both paint the same way) for a given block —
  /// what `paintBlockHtml` needs when a block rebuilds.
  List<Annotation> forBlock(String chapterId, int blockIndex) {
    return forChapter(chapterId).where((a) {
      if (a.type == AnnotationType.bookmark) return false;
      final anchor = AnnotationAnchor.parse(a.anchor);
      return anchor?.blockIndex == blockIndex;
    }).toList();
  }

  bool chapterHasBookmark(String chapterId) =>
      _annotations.any((a) => a.type == AnnotationType.bookmark && a.chapterId == chapterId);

  Annotation? findById(String id) {
    for (final a in _annotations) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<String?> addHighlight({
    required String chapterId,
    required AnnotationAnchor anchor,
    required String selectedText,
    required String colorKey,
    required double progressPercent,
    required String blockPlainText,
  }) async {
    try {
      await _addHighlightUsecase(
        bookId: bookId,
        chapterId: chapterId,
        anchor: anchor,
        selectedText: selectedText,
        colorKey: colorKey,
        progressPercent: progressPercent,
        blockPlainText: blockPlainText,
      );
      return null;
    } catch (_) {
      return 'Could not save this highlight. Please try again.';
    }
  }

  Future<String?> addNote({
    required String chapterId,
    required AnnotationAnchor anchor,
    required String selectedText,
    required String noteText,
    required String colorKey,
    required double progressPercent,
    required String blockPlainText,
  }) async {
    try {
      await _addNoteUsecase(
        bookId: bookId,
        chapterId: chapterId,
        anchor: anchor,
        selectedText: selectedText,
        noteText: noteText,
        colorKey: colorKey,
        progressPercent: progressPercent,
        blockPlainText: blockPlainText,
      );
      return null;
    } catch (_) {
      return 'Could not save this note. Please try again.';
    }
  }

  /// Returns null on success (whether that created or removed a bookmark —
  /// callers distinguish via [chapterHasBookmark] after the call), or an
  /// error message on failure.
  Future<String?> toggleBookmark({
    required String chapterId,
    required String anchor,
    required double progressPercent,
  }) async {
    try {
      await _toggleBookmarkUsecase(
        bookId: bookId,
        chapterId: chapterId,
        anchor: anchor,
        progressPercent: progressPercent,
      );
      return null;
    } catch (_) {
      return 'Could not update your bookmark. Please try again.';
    }
  }

  Future<String?> deleteAnnotation(String id) async {
    try {
      await _deleteAnnotationUsecase(id);
      return null;
    } catch (_) {
      return 'Could not delete this. Please try again.';
    }
  }

  /// Clearing the note (null/empty) downgrades a note back to a plain
  /// highlight — see `AnnotationRepository.updateNote`.
  Future<String?> updateNoteText(String id, String? noteText) async {
    try {
      await _updateNoteTextUsecase(id, noteText);
      return null;
    } catch (_) {
      return 'Could not save this note. Please try again.';
    }
  }

  Future<String?> changeColor(String id, String colorKey) async {
    try {
      await _changeColorUsecase(id, colorKey);
      return null;
    } catch (_) {
      return 'Could not change the color. Please try again.';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
