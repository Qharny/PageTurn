import '../entities/annotation.dart';

/// Local-first store for bookmarks/highlights/notes. Implementations persist
/// on-device (Hive today) and must support reactive watching, since the
/// reader and the annotations panel both repaint from [watchForBook].
///
/// Guest-first: no auth is required or checked here (see Phase 2 note on the
/// data-layer implementation) — annotations belong to this device until a
/// later sync feature attaches them to an account.
abstract class AnnotationRepository {
  /// Reactive stream of every annotation for [bookId], in no particular
  /// order — consumers (providers) sort/group as needed.
  Stream<List<Annotation>> watchForBook(String bookId);

  /// One-shot fetch scoped to a single chapter, so chapter load only pays
  /// for that chapter's annotations rather than the whole book.
  Future<List<Annotation>> getForChapter(String bookId, String chapterId);

  /// Upsert by [Annotation.id] — adds a new annotation, or overwrites an
  /// existing one with the same id (used by the overlap-merge rule in
  /// `AddHighlight`, which merges into the existing annotation's id rather
  /// than allocating a new one).
  Future<Annotation> add(Annotation annotation);

  /// Sets (or clears, when [noteText] is null or empty) the note text on an
  /// existing annotation. Clearing the note on an [AnnotationType.note]
  /// downgrades it back to [AnnotationType.highlight] (a note is only a
  /// highlight with text attached); setting non-empty text on a highlight
  /// upgrades it to a note. Bookmarks are untouched by this method.
  Future<Annotation> updateNote(String id, String? noteText);

  Future<Annotation> changeColor(String id, String colorKey);

  Future<void> delete(String id);

  /// Adds a bookmark at [anchor] if none exists there yet, or removes the
  /// existing bookmark for that exact chapter+anchor if one does — "tap
  /// again to remove". Returns the created [Annotation], or null if this
  /// call removed one instead.
  Future<Annotation?> toggleBookmark(
    String bookId,
    String chapterId,
    String anchor,
    double progressPercent,
  );
}
