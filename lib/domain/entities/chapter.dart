/// A reference to one chapter/section inside a parsed EPUB, used by the
/// reader's table-of-contents and pager. Populated at parse time — never
/// fetched remotely, since neither Gutendex nor local files expose a TOC
/// ahead of opening the book.
class EpubChapterRef {
  final String title;
  final String contentHtml;
  final int order;

  const EpubChapterRef({
    required this.title,
    required this.contentHtml,
    required this.order,
  });
}
