/// The three kinds of reader annotation, unified into one entity so the
/// annotations panel (Phase 4) can list/filter/sort them together instead of
/// juggling three parallel collections.
enum AnnotationType { bookmark, highlight, note }

/// A single reader annotation — bookmark, highlight, or note.
///
/// [anchor] is a serialized [AnnotationAnchor] (`"blockIndex:start:end"`) for
/// this app's HTML-per-block reader (see `AnnotationAnchor`). It is kept as a
/// plain `String` here rather than the structured type so this entity stays
/// agnostic of any one anchoring scheme — a future webview/CFI-based reader
/// could store a CFI string in the same field without changing this class.
class Annotation {
  final String id;
  final String bookId;
  final AnnotationType type;

  /// Chapter identity as the reader knows it — currently the chapter's list
  /// index stringified (`EpubChapterRef` has no stable id of its own).
  final String chapterId;

  final String anchor;

  /// The text the annotation covers. Null for bookmarks, which mark a
  /// position rather than a range.
  final String? selectedText;

  /// Non-null only for [AnnotationType.note] (and highlights that had a note
  /// merged into them — see the overlap-merge rule).
  final String? noteText;

  /// Theme-safe color key (see `core/theme/highlight_colors.dart`) for
  /// highlights/notes. Null for bookmarks. Never a raw color/hex — resolved
  /// against the reader's palette at render time.
  final String? colorKey;

  /// 0.0-1.0 position in the book, used for sorting and "jump to" UI.
  final double progressPercent;

  final DateTime createdAt;
  final DateTime updatedAt;

  const Annotation({
    required this.id,
    required this.bookId,
    required this.type,
    required this.chapterId,
    required this.anchor,
    this.selectedText,
    this.noteText,
    this.colorKey,
    required this.progressPercent,
    required this.createdAt,
    required this.updatedAt,
  });

  Annotation copyWith({
    String? id,
    String? bookId,
    AnnotationType? type,
    String? chapterId,
    String? anchor,
    String? selectedText,
    bool clearSelectedText = false,
    String? noteText,
    bool clearNoteText = false,
    String? colorKey,
    bool clearColorKey = false,
    double? progressPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Annotation(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      type: type ?? this.type,
      chapterId: chapterId ?? this.chapterId,
      anchor: anchor ?? this.anchor,
      selectedText: clearSelectedText ? null : (selectedText ?? this.selectedText),
      noteText: clearNoteText ? null : (noteText ?? this.noteText),
      colorKey: clearColorKey ? null : (colorKey ?? this.colorKey),
      progressPercent: progressPercent ?? this.progressPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Structural anchor for this reader's per-block HTML rendering: which block
/// (paragraph-equivalent) within the chapter, and the character offsets into
/// that block's plain-text projection. See Phase 0 audit — there are no EPUB
/// CFIs available here (no webview/epub.js), so this is the closest stable
/// equivalent: block position + offsets, independent of exact HTML markup.
class AnnotationAnchor {
  final int blockIndex;
  final int startOffset;
  final int endOffset;

  const AnnotationAnchor({
    required this.blockIndex,
    required this.startOffset,
    required this.endOffset,
  });

  String serialize() => '$blockIndex:$startOffset:$endOffset';

  /// Parses a `"blockIndex:start:end"` string. Returns null on any
  /// malformed input rather than throwing — callers (relocation, merge)
  /// treat an unparseable anchor as "needs repair" rather than a crash.
  static AnnotationAnchor? parse(String raw) {
    final parts = raw.split(':');
    if (parts.length != 3) return null;
    final blockIndex = int.tryParse(parts[0]);
    final startOffset = int.tryParse(parts[1]);
    final endOffset = int.tryParse(parts[2]);
    if (blockIndex == null || startOffset == null || endOffset == null) return null;
    if (blockIndex < 0 || startOffset < 0 || endOffset < startOffset) return null;
    return AnnotationAnchor(blockIndex: blockIndex, startOffset: startOffset, endOffset: endOffset);
  }

  @override
  String toString() => serialize();

  @override
  bool operator ==(Object other) =>
      other is AnnotationAnchor &&
      other.blockIndex == blockIndex &&
      other.startOffset == startOffset &&
      other.endOffset == endOffset;

  @override
  int get hashCode => Object.hash(blockIndex, startOffset, endOffset);
}
