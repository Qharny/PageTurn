import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/presentation/reader/reader_block_parser.dart';

void main() {
  group('splitChapterIntoBlocks', () {
    test('splits top-level <p> elements into one block each, in order', () {
      const html = '<html><body><p>First paragraph.</p><p>Second paragraph.</p></body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks.length, 2);
      expect(blocks[0].index, 0);
      expect(blocks[0].plainText, 'First paragraph.');
      expect(blocks[1].index, 1);
      expect(blocks[1].plainText, 'Second paragraph.');
    });

    test('skips whitespace-only filler paragraphs and keeps indices contiguous', () {
      const html = '<html><body><p>Real content.</p><p>   </p><p>More content.</p></body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks.length, 2);
      expect(blocks[0].plainText, 'Real content.');
      expect(blocks[1].plainText, 'More content.');
      expect(blocks[1].index, 1); // not 2 — the empty <p> didn't consume an index
    });

    test('keeps an image-only block even though it has no text', () {
      const html = '<html><body><p>Caption text.</p><p><img src="cover.jpg"/></p></body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks.length, 2);
      expect(blocks[1].plainText, isEmpty);
      expect(blocks[1].rawHtml, contains('img'));
    });

    test('falls back to treating the whole body as one block when there are no element children', () {
      const html = '<html><body>Just loose text, no paragraph tags.</body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks.length, 1);
      expect(blocks[0].plainText, 'Just loose text, no paragraph tags.');
    });

    test('preserves inline markup inside rawHtml', () {
      const html = '<html><body><p>Some <em>emphasized</em> text.</p></body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks[0].rawHtml, contains('<em>emphasized</em>'));
      expect(blocks[0].plainText, 'Some emphasized text.');
    });
  });

  group('flattenBlockText whitespace collapsing', () {
    test('collapses newlines/indentation between inline tags to a single space', () {
      const html = '<html><body><p>Word one\n    <em>word two</em>\n    word three.</p></body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks[0].plainText, 'Word one word two word three.');
    });

    test('trims leading and trailing whitespace', () {
      const html = '<html><body><p>   padded text   </p></body></html>';
      final blocks = splitChapterIntoBlocks(html);
      expect(blocks[0].plainText, 'padded text');
    });
  });
}
