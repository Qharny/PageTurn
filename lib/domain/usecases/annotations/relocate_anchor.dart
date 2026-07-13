import '../../entities/annotation.dart';

/// Repairs an [AnnotationAnchor] that no longer resolves against the current
/// chapter content (e.g. the EPUB was re-parsed, or — in this app's case —
/// block splitting produced a different block list than when the annotation
/// was created) by searching for the original [selectedText] instead.
///
/// Pure and IO-free so it's unit-testable without the reader. Callers
/// (`AnnotationProvider`) are responsible for debug-logging when this fires,
/// per the brief — this function only does the search.
class RelocateAnchor {
  RelocateAnchor._();

  /// Searches [blockPlainTexts] (the chapter's current block plain-text
  /// projections, in order) for [selectedText], preferring
  /// [preferredBlockIndex] first since that's the most likely surviving
  /// location for a small content shift. Returns null if the text can't be
  /// found anywhere in the chapter (e.g. that passage was deleted).
  static AnnotationAnchor? relocate({
    required String selectedText,
    required List<String> blockPlainTexts,
    required int preferredBlockIndex,
  }) {
    if (selectedText.isEmpty) return null;

    final searchOrder = <int>[
      if (preferredBlockIndex >= 0 && preferredBlockIndex < blockPlainTexts.length) preferredBlockIndex,
      for (var i = 0; i < blockPlainTexts.length; i++)
        if (i != preferredBlockIndex) i,
    ];

    for (final blockIndex in searchOrder) {
      final start = blockPlainTexts[blockIndex].indexOf(selectedText);
      if (start != -1) {
        return AnnotationAnchor(
          blockIndex: blockIndex,
          startOffset: start,
          endOffset: start + selectedText.length,
        );
      }
    }
    return null;
  }

  /// True if [anchor] still resolves against [blockPlainTexts] as-is (the
  /// common case — no relocation needed). Callers check this first and only
  /// fall back to [relocate] when it returns false.
  static bool resolves(AnnotationAnchor anchor, List<String> blockPlainTexts) {
    if (anchor.blockIndex < 0 || anchor.blockIndex >= blockPlainTexts.length) return false;
    final block = blockPlainTexts[anchor.blockIndex];
    return anchor.endOffset <= block.length;
  }
}
