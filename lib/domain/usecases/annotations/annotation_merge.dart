import '../../entities/annotation.dart';

/// Overlap-merge rule for highlights/notes (v1): when a new highlight range
/// intersects an existing one in the same chapter+block, they merge into one
/// annotation spanning the union rather than sitting as two overlapping
/// highlights.
///
/// Pure and IO-free on purpose — the caller (AddHighlight usecase) supplies
/// [blockPlainText] (already cached by the reader) so this stays unit
/// testable without a repository or Hive.
class AnnotationMerge {
  AnnotationMerge._();

  static const String noteSeparator = '\n\n---\n\n';

  /// Returns the merged annotation if [incoming] overlaps [existing] in the
  /// same chapter and block, or null if they don't overlap (caller should
  /// add [incoming] as a separate annotation instead).
  ///
  /// Rules: union of the two ranges; keep [incoming]'s color (the newer
  /// one); if only one side has a note, keep it; if both have notes,
  /// concatenate with [noteSeparator]; the merged type becomes
  /// [AnnotationType.note] if the result has a note, else stays
  /// [AnnotationType.highlight].
  static Annotation? tryMerge({
    required Annotation existing,
    required Annotation incoming,
    required String blockPlainText,
  }) {
    if (!_isRangeType(existing.type) || !_isRangeType(incoming.type)) return null;
    if (existing.chapterId != incoming.chapterId) return null;

    final existingAnchor = AnnotationAnchor.parse(existing.anchor);
    final incomingAnchor = AnnotationAnchor.parse(incoming.anchor);
    if (existingAnchor == null || incomingAnchor == null) return null;
    if (existingAnchor.blockIndex != incomingAnchor.blockIndex) return null;

    final overlaps = incomingAnchor.startOffset <= existingAnchor.endOffset &&
        incomingAnchor.endOffset >= existingAnchor.startOffset;
    if (!overlaps) return null;

    final unionStart = existingAnchor.startOffset < incomingAnchor.startOffset
        ? existingAnchor.startOffset
        : incomingAnchor.startOffset;
    final unionEndRaw = existingAnchor.endOffset > incomingAnchor.endOffset
        ? existingAnchor.endOffset
        : incomingAnchor.endOffset;

    final clampedStart = unionStart.clamp(0, blockPlainText.length);
    final clampedEnd = unionEndRaw.clamp(clampedStart, blockPlainText.length);
    final mergedAnchor = AnnotationAnchor(
      blockIndex: existingAnchor.blockIndex,
      startOffset: clampedStart,
      endOffset: clampedEnd,
    );

    final String? mergedNote;
    if (existing.noteText != null && incoming.noteText != null) {
      mergedNote = '${existing.noteText}$noteSeparator${incoming.noteText}';
    } else {
      mergedNote = incoming.noteText ?? existing.noteText;
    }

    return existing.copyWith(
      type: mergedNote != null ? AnnotationType.note : AnnotationType.highlight,
      anchor: mergedAnchor.serialize(),
      selectedText: clampedStart == clampedEnd ? '' : blockPlainText.substring(clampedStart, clampedEnd),
      noteText: mergedNote,
      clearNoteText: mergedNote == null,
      colorKey: incoming.colorKey ?? existing.colorKey,
      progressPercent: incoming.progressPercent,
      updatedAt: incoming.updatedAt,
    );
  }

  static bool _isRangeType(AnnotationType type) =>
      type == AnnotationType.highlight || type == AnnotationType.note;
}
