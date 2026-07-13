import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/domain/entities/annotation.dart';
import 'package:pageturn/domain/usecases/annotations/annotation_merge.dart';

Annotation _highlight({
  String id = 'existing',
  String chapterId = 'ch0',
  required AnnotationAnchor anchor,
  String? noteText,
  String colorKey = 'amber',
  DateTime? updatedAt,
}) {
  final now = DateTime(2026, 1, 1);
  return Annotation(
    id: id,
    bookId: 'book1',
    type: noteText != null ? AnnotationType.note : AnnotationType.highlight,
    chapterId: chapterId,
    anchor: anchor.serialize(),
    selectedText: 'placeholder',
    noteText: noteText,
    colorKey: colorKey,
    progressPercent: 0.1,
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  const blockText = 'The quick brown fox jumps over the lazy dog near the river bank.';

  group('AnnotationMerge.tryMerge — no merge cases', () {
    test('returns null when ranges do not overlap', () {
      final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 3));
      final incoming = _highlight(
        id: 'incoming',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 10, endOffset: 15),
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
      expect(result, isNull);
    });

    test('returns null when in different chapters', () {
      final existing = _highlight(
        chapterId: 'ch0',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 10),
      );
      final incoming = _highlight(
        id: 'incoming',
        chapterId: 'ch1',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 5, endOffset: 15),
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
      expect(result, isNull);
    });

    test('returns null when in different blocks of the same chapter', () {
      final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 10));
      final incoming = _highlight(
        id: 'incoming',
        anchor: const AnnotationAnchor(blockIndex: 1, startOffset: 0, endOffset: 10),
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
      expect(result, isNull);
    });

    test('returns null for a bookmark (range-less type)', () {
      final now = DateTime(2026, 1, 1);
      final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 10));
      final bookmark = Annotation(
        id: 'bm',
        bookId: 'book1',
        type: AnnotationType.bookmark,
        chapterId: 'ch0',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 5, endOffset: 5).serialize(),
        progressPercent: 0.1,
        createdAt: now,
        updatedAt: now,
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: bookmark, blockPlainText: blockText);
      expect(result, isNull);
    });
  });

  group('AnnotationMerge.tryMerge — overlap merges', () {
    test('merges into the union range and keeps the existing id', () {
      final existing = _highlight(
        id: 'existing-id',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 9), // "quick"
      );
      final incoming = _highlight(
        id: 'incoming-id',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 7, endOffset: 15), // "ck brown" — overlaps "quick"
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);

      expect(result, isNotNull);
      expect(AnnotationAnchor.parse(result!.anchor), const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 15));
      expect(result.selectedText, blockText.substring(4, 15));
      // tryMerge itself preserves `existing`'s id — AddHighlight is what
      // re-applies existing.id via copyWith before persisting.
    });

    test('touching (adjacent, non-overlapping) ranges still merge', () {
      final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 5));
      final incoming = _highlight(
        id: 'incoming',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 5, endOffset: 10),
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
      expect(result, isNotNull);
      expect(AnnotationAnchor.parse(result!.anchor), const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 10));
    });

    test('incoming fully containing existing still merges to the larger range', () {
      final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 9));
      final incoming = _highlight(
        id: 'incoming',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 19),
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
      expect(AnnotationAnchor.parse(result!.anchor), const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 19));
    });

    test('keeps the newer (incoming) color', () {
      final existing = _highlight(
        colorKey: 'blue',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 9),
      );
      final incoming = _highlight(
        id: 'incoming',
        colorKey: 'rose',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 15),
      );

      final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
      expect(result!.colorKey, 'rose');
    });

    group('note branches', () {
      test('neither side has a note -> merged stays a highlight with no note', () {
        final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 9));
        final incoming = _highlight(
          id: 'incoming',
          anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 15),
        );

        final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
        expect(result!.type, AnnotationType.highlight);
        expect(result.noteText, isNull);
      });

      test('only existing has a note -> merged keeps it and becomes a note', () {
        final existing = _highlight(
          noteText: 'my thought',
          anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 9),
        );
        final incoming = _highlight(
          id: 'incoming',
          anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 15),
        );

        final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
        expect(result!.type, AnnotationType.note);
        expect(result.noteText, 'my thought');
      });

      test('only incoming has a note -> merged keeps it and becomes a note', () {
        final existing = _highlight(anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 9));
        final incoming = _highlight(
          id: 'incoming',
          noteText: 'new thought',
          anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 15),
        );

        final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
        expect(result!.type, AnnotationType.note);
        expect(result.noteText, 'new thought');
      });

      test('both sides have notes -> concatenated with the separator', () {
        final existing = _highlight(
          noteText: 'first note',
          anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 9),
        );
        final incoming = _highlight(
          id: 'incoming',
          noteText: 'second note',
          anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 15),
        );

        final result = AnnotationMerge.tryMerge(existing: existing, incoming: incoming, blockPlainText: blockText);
        expect(result!.type, AnnotationType.note);
        expect(result.noteText, 'first note${AnnotationMerge.noteSeparator}second note');
      });
    });
  });
}
