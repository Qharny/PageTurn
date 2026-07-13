import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

/// One block-level unit (paragraph, heading, blockquote, list item, …)
/// within a chapter. See the Phase 0 reader audit: chapters arrive as one
/// HTML blob with no paragraph concept of their own, so this is what gives
/// annotations a stable `blockIndex` to anchor against, and what lets the
/// reader render (and highlight-paint) one block at a time instead of one
/// opaque whole-chapter `HtmlWidget`.
class ReaderBlock {
  final int index;
  final String rawHtml;
  final String plainText;

  const ReaderBlock({required this.index, required this.rawHtml, required this.plainText});
}

/// Splits a chapter's raw XHTML into block-level elements. Falls back to
/// treating the whole `<body>` as one block if it has no element children
/// (some Gutenberg front-matter/cover pages are just loose text nodes).
/// Deterministic for a given [contentHtml] — the same EPUB always produces
/// the same block list and indices, which is what keeps stored anchors
/// valid across app restarts.
List<ReaderBlock> splitChapterIntoBlocks(String contentHtml) {
  final document = html_parser.parse(contentHtml);
  final body = document.body;
  if (body == null) return const [];

  final candidates = body.children.isEmpty ? [body] : body.children;

  final blocks = <ReaderBlock>[];
  for (final element in candidates) {
    final text = flattenBlockText(element);
    final hasMedia = element.querySelector('img') != null;
    if (text.isEmpty && !hasMedia) {
      // Skip whitespace-only <p> tags (common EPUB filler) so blockIndex
      // stays meaningful — but keep image-only blocks since they're still
      // visible content worth being able to bookmark near.
      continue;
    }
    blocks.add(ReaderBlock(index: blocks.length, rawHtml: element.outerHtml, plainText: text));
  }
  return blocks;
}

/// One character of a block's collapsed plain text, tracking exactly which
/// raw DOM text node (and raw, uncollapsed offset within it) it came from.
/// This is what lets the highlight painter (`reader_highlight_painter.dart`)
/// split the *original* text nodes at the right place even though the
/// annotation's stored offsets are in collapsed-whitespace space.
class CollapsedChar {
  final dom.Text node;
  final int rawIndex;
  const CollapsedChar(this.node, this.rawIndex);
}

class CollapsedText {
  final String text;
  final List<CollapsedChar> origins; // origins[i] is where text[i] came from

  const CollapsedText(this.text, this.origins);
}

/// Flattens [root]'s text content, collapsing runs of whitespace to a
/// single space and trimming ends — identically to `String.trim()` +
/// `replaceAll(RegExp(r'\s+'), ' ')`, but tracking each emitted character's
/// origin so callers can map a collapsed-text offset back to a specific
/// text node + raw index. Both [flattenBlockText] and the highlight painter
/// use this same walk, in the same document order, so offsets computed
/// against one are valid against the other.
CollapsedText collapseTextWithOrigins(dom.Node root) {
  final buffer = StringBuffer();
  final origins = <CollapsedChar>[];
  var lastWasSpace = true; // starts true so leading whitespace is dropped

  void walk(dom.Node node) {
    if (node is dom.Text) {
      final raw = node.text;
      for (var i = 0; i < raw.length; i++) {
        final isSpace = _isWhitespace(raw.codeUnitAt(i));
        if (isSpace) {
          if (!lastWasSpace) {
            buffer.write(' ');
            origins.add(CollapsedChar(node, i));
            lastWasSpace = true;
          }
          continue;
        }
        buffer.write(raw[i]);
        origins.add(CollapsedChar(node, i));
        lastWasSpace = false;
      }
      return;
    }
    for (final child in List<dom.Node>.from(node.nodes)) {
      walk(child);
    }
  }

  walk(root);

  // Trailing space trim (leading was already dropped via lastWasSpace=true).
  if (buffer.isNotEmpty && origins.isNotEmpty && buffer.toString().endsWith(' ')) {
    final text = buffer.toString();
    return CollapsedText(text.substring(0, text.length - 1), origins.sublist(0, origins.length - 1));
  }
  return CollapsedText(buffer.toString(), origins);
}

bool _isWhitespace(int codeUnit) {
  // Matches Dart's `\s` regex class closely enough for EPUB/XHTML content:
  // space, tab, newline, carriage return, form feed, vertical tab, NBSP.
  return codeUnit == 0x20 ||
      codeUnit == 0x09 ||
      codeUnit == 0x0A ||
      codeUnit == 0x0D ||
      codeUnit == 0x0C ||
      codeUnit == 0x0B ||
      codeUnit == 0xA0;
}

String flattenBlockText(dom.Node node) => collapseTextWithOrigins(node).text;
