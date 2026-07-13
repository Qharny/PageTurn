import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:pageturn/core/theme/highlight_colors.dart';
import 'package:pageturn/domain/entities/annotation.dart';
import 'package:pageturn/presentation/reader/reader_block_parser.dart';
import 'package:pageturn/presentation/reader/reader_highlight_painter.dart';

Annotation _annotation({
  required String id,
  required AnnotationAnchor anchor,
  String colorKey = 'amber',
  AnnotationType type = AnnotationType.highlight,
}) {
  final now = DateTime(2026, 1, 1);
  return Annotation(
    id: id,
    bookId: 'book1',
    type: type,
    chapterId: '0',
    anchor: anchor.serialize(),
    selectedText: 'x',
    colorKey: colorKey,
    progressPercent: 0.1,
    createdAt: now,
    updatedAt: now,
  );
}

/// Re-parses [html] and flattens it back to plain text the same way the
/// block parser does — used to assert painting never loses or duplicates
/// visible text, regardless of how many `<a>` spans got injected.
String _visibleText(String html) {
  final doc = html_parser.parse(html);
  final body = doc.body;
  if (body == null) return '';
  final root = body.children.isNotEmpty ? body.children.first : body;
  return flattenBlockText(root);
}

void main() {
  group('paintBlockHtml', () {
    test('returns rawHtml unchanged when there are no annotations', () {
      const html = '<p>Nothing highlighted here.</p>';
      expect(paintBlockHtml(html, const []), html);
    });

    test('ignores bookmark-type annotations (no range to paint)', () {
      const html = '<p>Some text.</p>';
      final bookmark = _annotation(
        id: 'bm',
        type: AnnotationType.bookmark,
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 4),
      );
      expect(paintBlockHtml(html, [bookmark]), html);
    });

    test('wraps a single-text-node highlight in a tappable colored span', () {
      const html = '<p>The quick brown fox jumps.</p>';
      final blocks = splitChapterIntoBlocks('<html><body>$html</body></html>');
      final plainText = blocks.first.plainText;
      final start = plainText.indexOf('quick brown');
      final annotation = _annotation(
        id: 'h1',
        colorKey: 'green',
        anchor: AnnotationAnchor(blockIndex: 0, startOffset: start, endOffset: start + 'quick brown'.length),
      );

      final painted = paintBlockHtml(html, [annotation]);

      expect(painted, contains('href="pageturn-hl://h1"'));
      expect(painted, contains(HighlightColors.hexFor('green')));
      expect(painted, contains('>quick brown<'));
      // Visible text is unchanged — painting never loses/duplicates content.
      expect(_visibleText(painted), plainText);
    });

    test('splits into two <a> tags when the range crosses an inline <em> boundary', () {
      const html = '<p>Some <em>emphasized</em> text right after.</p>';
      final blocks = splitChapterIntoBlocks('<html><body>$html</body></html>');
      final plainText = blocks.first.plainText; // "Some emphasized text right after."
      final start = plainText.indexOf('emphasized text');
      final annotation = _annotation(
        id: 'h2',
        anchor: AnnotationAnchor(blockIndex: 0, startOffset: start, endOffset: start + 'emphasized text'.length),
      );

      final painted = paintBlockHtml(html, [annotation]);

      // Two separate spans (one inside <em>, one in the following text node)
      // sharing the same annotation id, rather than one span illegally
      // wrapping across the <em> boundary.
      expect('href="pageturn-hl://h2"'.allMatches(painted).length, 2);
      expect(painted, contains('<em><a href="pageturn-hl://h2"'));
      expect(_visibleText(painted), plainText);
    });

    test('paints two adjacent highlights independently with their own colors', () {
      const html = '<p>The quick brown fox jumps over the lazy dog.</p>';
      final blocks = splitChapterIntoBlocks('<html><body>$html</body></html>');
      final plainText = blocks.first.plainText;
      final quickStart = plainText.indexOf('quick');
      final lazyStart = plainText.indexOf('lazy dog');

      final h1 = _annotation(
        id: 'h1',
        colorKey: 'amber',
        anchor: AnnotationAnchor(blockIndex: 0, startOffset: quickStart, endOffset: quickStart + 'quick'.length),
      );
      final h2 = _annotation(
        id: 'h2',
        colorKey: 'rose',
        anchor: AnnotationAnchor(blockIndex: 0, startOffset: lazyStart, endOffset: lazyStart + 'lazy dog'.length),
      );

      final painted = paintBlockHtml(html, [h1, h2]);

      expect(painted, contains('href="pageturn-hl://h1"'));
      expect(painted, contains('href="pageturn-hl://h2"'));
      expect(painted, contains(HighlightColors.hexFor('amber')));
      expect(painted, contains(HighlightColors.hexFor('rose')));
      expect(_visibleText(painted), plainText);
    });

    test('handles offsets shifted by whitespace collapsing (newlines between words)', () {
      const html = '<p>Word one\n    word two\n    word three.</p>';
      final blocks = splitChapterIntoBlocks('<html><body>$html</body></html>');
      final plainText = blocks.first.plainText; // "Word one word two word three."
      final start = plainText.indexOf('word two');
      final annotation = _annotation(
        id: 'h3',
        anchor: AnnotationAnchor(blockIndex: 0, startOffset: start, endOffset: start + 'word two'.length),
      );

      final painted = paintBlockHtml(html, [annotation]);

      expect(painted, contains('href="pageturn-hl://h3"'));
      // The highlight must land on the correct raw text ("word two"), not a
      // shifted/garbled substring caused by the collapsed-vs-raw offset gap.
      expect(_visibleText(painted), plainText);
      final start2 = painted.indexOf('href="pageturn-hl://h3"');
      final segment = painted.substring(start2, start2 + 120);
      expect(segment, contains('>word two<'));
    });
  });
}
