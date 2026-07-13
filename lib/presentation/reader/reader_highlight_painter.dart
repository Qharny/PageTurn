import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../../core/theme/highlight_colors.dart';
import '../../domain/entities/annotation.dart';
import 'reader_block_parser.dart';

/// Injects highlight/note background spans into a block's raw HTML by
/// walking its text nodes and splitting them at the annotations' character
/// offsets — DOM-level surgery (not string splicing), so the output is
/// always well-formed regardless of how the highlighted range interacts
/// with nested inline tags (e.g. spanning across a `<em>...</em>` boundary,
/// which becomes two adjacent highlighted `<a>` elements rather than one
/// malformed span crossing the `<em>` tag).
///
/// Each injected span becomes a tappable `<a href="pageturn-hl://{id}">` so
/// `HtmlWidget(onTapUrl:)` can open the highlight-edit sheet without needing
/// a custom gesture layer over the rendered HTML.
///
/// Offsets in [blockAnnotations]' anchors are in *collapsed* whitespace
/// space (matching what `SelectionArea` sees on-screen and what
/// `ReaderBlock.plainText` stores) — this re-derives that same collapsed
/// mapping via [collapseTextWithOrigins] to find the correct *raw* DOM
/// position to split at.
String paintBlockHtml(String rawHtml, List<Annotation> blockAnnotations) {
  final rangeAnnotations =
      blockAnnotations.where((a) => a.type == AnnotationType.highlight || a.type == AnnotationType.note).toList();
  if (rangeAnnotations.isEmpty) return rawHtml;

  final document = html_parser.parse(rawHtml);
  final body = document.body;
  if (body == null) return rawHtml;
  final dom.Element root = body.children.isNotEmpty ? body.children.first : body;

  final collapsed = collapseTextWithOrigins(root);
  final origins = collapsed.origins;
  if (origins.isEmpty) return rawHtml;

  // Group each annotation's [start,end) collapsed-offset range into the
  // raw (textNode, rawStart, rawEnd) segments it covers — usually one
  // segment, but more than one if the range crosses a text-node boundary.
  final byNode = <dom.Text, List<_NodeRange>>{};
  for (final annotation in rangeAnnotations) {
    final anchor = AnnotationAnchor.parse(annotation.anchor);
    if (anchor == null) continue;
    final start = anchor.startOffset.clamp(0, origins.length);
    final end = anchor.endOffset.clamp(start, origins.length);
    if (start >= end) continue;

    var i = start;
    while (i < end) {
      final node = origins[i].node;
      final rawStart = origins[i].rawIndex;
      var rawEnd = rawStart;
      var j = i;
      while (j < end && origins[j].node == node) {
        rawEnd = origins[j].rawIndex + 1;
        j++;
      }
      byNode.putIfAbsent(node, () => []).add(_NodeRange(rawStart, rawEnd, annotation));
      i = j;
    }
  }

  for (final entry in byNode.entries) {
    final ranges = entry.value..sort((a, b) => a.start.compareTo(b.start));
    _splitTextNode(entry.key, ranges);
  }

  return root.outerHtml;
}

class _NodeRange {
  final int start; // raw offset within the text node's own .text
  final int end;
  final Annotation annotation;
  _NodeRange(this.start, this.end, this.annotation);
}

/// Replaces [node] in its parent's child list with an alternating sequence
/// of plain [dom.Text] nodes and highlighted `<a>` elements per [ranges]
/// (sorted, non-overlapping — guaranteed by the domain-layer overlap-merge
/// rule, since two annotations never end up with intersecting anchors).
void _splitTextNode(dom.Text node, List<_NodeRange> ranges) {
  final parent = node.parentNode;
  if (parent == null) return;
  final text = node.text;
  final replacement = <dom.Node>[];
  var pos = 0;

  for (final range in ranges) {
    final start = range.start.clamp(0, text.length);
    final end = range.end.clamp(start, text.length);
    if (start > pos) {
      replacement.add(dom.Text(text.substring(pos, start)));
    }
    if (end > start) {
      final hex = HighlightColors.hexFor(range.annotation.colorKey ?? 'amber');
      final highlightEl = dom.Element.tag('a')
        ..attributes['href'] = 'pageturn-hl://${range.annotation.id}'
        ..attributes['style'] = 'background-color:$hex; color:inherit; text-decoration:none;';
      highlightEl.append(dom.Text(text.substring(start, end)));
      replacement.add(highlightEl);
      pos = end;
    }
  }
  if (pos < text.length) {
    replacement.add(dom.Text(text.substring(pos)));
  }

  final index = parent.nodes.indexOf(node);
  if (index == -1) return;
  parent.nodes.removeAt(index);
  parent.nodes.insertAll(index, replacement);
}

const String highlightTapUrlScheme = 'pageturn-hl://';
