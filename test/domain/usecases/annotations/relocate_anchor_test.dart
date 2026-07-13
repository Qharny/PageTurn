import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/domain/entities/annotation.dart';
import 'package:pageturn/domain/usecases/annotations/relocate_anchor.dart';

void main() {
  group('RelocateAnchor.resolves', () {
    test('true when the anchor still fits inside the block', () {
      final blocks = ['The quick brown fox jumps over the lazy dog.'];
      const anchor = AnnotationAnchor(blockIndex: 0, startOffset: 4, endOffset: 9);
      expect(RelocateAnchor.resolves(anchor, blocks), isTrue);
    });

    test('false when blockIndex is out of range', () {
      final blocks = ['short text'];
      const anchor = AnnotationAnchor(blockIndex: 5, startOffset: 0, endOffset: 3);
      expect(RelocateAnchor.resolves(anchor, blocks), isFalse);
    });

    test('false when endOffset now exceeds the block length (content shrank)', () {
      final blocks = ['short'];
      const anchor = AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 20);
      expect(RelocateAnchor.resolves(anchor, blocks), isFalse);
    });
  });

  group('RelocateAnchor.relocate — repair after content shift', () {
    test('finds text that shifted later in the same block after an inserted sentence', () {
      // Original content when the highlight on "lazy dog" was created.
      const original = 'The quick brown fox jumps over the lazy dog.';
      final originalAnchor = AnnotationAnchor(
        blockIndex: 0,
        startOffset: original.indexOf('lazy dog'),
        endOffset: original.indexOf('lazy dog') + 'lazy dog'.length,
      );
      const selectedText = 'lazy dog';

      // The book was re-parsed (or the app re-flowed the chapter) and a new
      // sentence was inserted before the highlighted phrase, shifting its
      // offset — the stored anchor no longer resolves to the same text.
      const reflowed = 'A storm rolled in overnight. The quick brown fox jumps over the lazy dog.';
      final reflowedBlocks = [reflowed];

      // The stored anchor still numerically "fits" (endOffset < length) but
      // now points at the wrong substring — this is the drift scenario
      // relocate() must catch, not resolves().
      expect(reflowed.substring(originalAnchor.startOffset, originalAnchor.endOffset), isNot(selectedText));

      final repaired = RelocateAnchor.relocate(
        selectedText: selectedText,
        blockPlainTexts: reflowedBlocks,
        preferredBlockIndex: originalAnchor.blockIndex,
      );

      expect(repaired, isNotNull);
      expect(repaired!.blockIndex, 0);
      expect(reflowed.substring(repaired.startOffset, repaired.endOffset), selectedText);
    });

    test('falls back to searching other blocks when the text moved to a different block', () {
      final blocks = [
        'First paragraph with nothing interesting.',
        'Second paragraph contains the important phrase right here.',
      ];

      final repaired = RelocateAnchor.relocate(
        selectedText: 'important phrase',
        blockPlainTexts: blocks,
        preferredBlockIndex: 0, // stale — the text is actually in block 1
      );

      expect(repaired, isNotNull);
      expect(repaired!.blockIndex, 1);
      expect(blocks[1].substring(repaired.startOffset, repaired.endOffset), 'important phrase');
    });

    test('returns null when the selected text no longer exists anywhere', () {
      final blocks = ['This paragraph no longer contains the old phrase at all.'];

      final repaired = RelocateAnchor.relocate(
        selectedText: 'deleted passage',
        blockPlainTexts: blocks,
        preferredBlockIndex: 0,
      );

      expect(repaired, isNull);
    });

    test('returns null for empty selectedText rather than matching everything', () {
      final blocks = ['Any text at all.'];
      final repaired = RelocateAnchor.relocate(
        selectedText: '',
        blockPlainTexts: blocks,
        preferredBlockIndex: 0,
      );
      expect(repaired, isNull);
    });
  });
}
