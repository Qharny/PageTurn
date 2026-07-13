import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../core/theme/highlight_colors.dart';
import '../../data/models/book_model.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/usecases/annotations/relocate_anchor.dart';
import '../../theme.dart';
import '../common/widgets/book_cover.dart';
import '../explore/quote_studio/quote_studio_screen.dart';
import 'annotation_provider.dart';
import 'reader_highlight_painter.dart';
import 'reader_provider.dart';
import 'widgets/bookmark_ribbon.dart';
import 'widgets/font_settings_sheet.dart';
import 'widgets/highlight_edit_sheet.dart';
import 'widgets/note_editor_sheet.dart';
import 'widgets/reader_contents_sheet.dart';
import 'widgets/selection_toolbar.dart';

/// The distraction-free EPUB reader. Opens the same way for a downloaded
/// Gutendex book or a locally-imported one — both simply arrive here with
/// [Book.localFilePath] already set.
class EbookReaderScreen extends StatefulWidget {
  const EbookReaderScreen({super.key, required this.book});

  final Book book;

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

/// Tracks the current text selection between `onSelectionChanged` firing and
/// the user tapping a toolbar action. Resolved via `RelocateAnchor` search
/// (see the reader audit) since `SelectionArea` doesn't expose a structural
/// position, only the selected plain text.
class _PendingSelection {
  final String text;
  final AnnotationAnchor anchor;
  final String blockPlainText;

  const _PendingSelection({required this.text, required this.anchor, required this.blockPlainText});
}

class _EbookReaderScreenState extends State<EbookReaderScreen> {
  late final ReaderProvider _reader = ReaderProvider();
  late final AnnotationProvider _annotations = AnnotationProvider(bookId: widget.book.id);

  final GlobalKey<SelectableRegionState> _selectionKey = GlobalKey<SelectableRegionState>();
  final GlobalKey _scrollViewportKey = GlobalKey();
  final FocusNode _selectionFocusNode = FocusNode();

  int? _blockKeysChapterIndex;
  List<GlobalKey> _blockKeys = [];

  _PendingSelection? _pendingSelection;
  int _lastChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _reader.loadBook(widget.book);
  }

  @override
  void dispose() {
    _reader.dispose();
    _annotations.dispose();
    _selectionFocusNode.dispose();
    super.dispose();
  }

  void _clearSelection() {
    _selectionKey.currentState?.clearSelection();
    setState(() => _pendingSelection = null);
  }

  void _goToNextChapter() {
    _clearSelection();
    _reader.nextChapter();
  }

  void _goToPreviousChapter() {
    _clearSelection();
    _reader.previousChapter();
  }

  void _goToChapter(int index) {
    _clearSelection();
    _reader.jumpToChapter(index);
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: Listenable.merge([_reader, _annotations]),
        builder: (context, _) => ReaderContentsSheet(
          chapters: _reader.chapters,
          currentIndex: _reader.currentChapterIndex,
          onSelectChapter: _goToChapter,
          annotations: _annotations.all,
          onJumpToAnnotation: _jumpToAnnotation,
          onDeleteAnnotation: _deleteAnnotationFromPanel,
          onEditNote: _openHighlightEditSheetFor,
          onSendToQuoteStudio: _sendToQuoteStudio,
        ),
      ),
    );
  }

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: _reader,
        builder: (context, _) => FontSettingsSheet(
          fontSize: _reader.fontSize,
          onIncrease: _reader.increaseFontSize,
          onDecrease: _reader.decreaseFontSize,
        ),
      ),
    );
  }

  // ── Selection handling ──────────────────────────────────────────────

  void _onSelectionChanged(SelectedContent? content) {
    final text = content?.plainText.trim() ?? '';
    if (text.isEmpty) {
      if (_pendingSelection != null) setState(() => _pendingSelection = null);
      return;
    }
    final blocks = _reader.currentBlocks;
    final resolved = RelocateAnchor.relocate(
      selectedText: text,
      blockPlainTexts: blocks.map((b) => b.plainText).toList(),
      preferredBlockIndex: 0,
    );
    if (resolved == null) {
      // Selected text doesn't map onto any block's plain text (can happen
      // with certain punctuation/whitespace edge cases in HtmlWidget's
      // rendering) — no toolbar rather than acting on a bad anchor.
      if (_pendingSelection != null) setState(() => _pendingSelection = null);
      return;
    }
    setState(() {
      _pendingSelection = _PendingSelection(
        text: text,
        anchor: resolved,
        blockPlainText: blocks[resolved.blockIndex].plainText,
      );
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _handleColorTap(HighlightColorKey key) async {
    final selection = _pendingSelection;
    if (selection == null) return;
    final chapterId = _reader.currentChapterId;
    _clearSelection();
    final error = await _annotations.addHighlight(
      chapterId: chapterId,
      anchor: selection.anchor,
      selectedText: selection.text,
      colorKey: key.name,
      progressPercent: _reader.progressForBlock(selection.anchor.blockIndex),
      blockPlainText: selection.blockPlainText,
    );
    if (error != null) _showSnackBar(error);
  }

  void _handleNoteTap() {
    final selection = _pendingSelection;
    if (selection == null) return;
    final chapterId = _reader.currentChapterId;
    _clearSelection();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NoteEditorSheet(
        selectedText: selection.text,
        onSave: (noteText) async {
          final error = await _annotations.addNote(
            chapterId: chapterId,
            anchor: selection.anchor,
            selectedText: selection.text,
            noteText: noteText,
            colorKey: HighlightColorKey.amber.name,
            progressPercent: _reader.progressForBlock(selection.anchor.blockIndex),
            blockPlainText: selection.blockPlainText,
          );
          if (error != null) _showSnackBar(error);
          return error;
        },
      ),
    );
  }

  void _handleCopyTap() {
    final selection = _pendingSelection;
    if (selection == null) return;
    Clipboard.setData(ClipboardData(text: selection.text));
    _clearSelection();
    _showSnackBar('Copied to clipboard.');
  }

  // ── Highlight tap / edit ─────────────────────────────────────────────

  void _openHighlightEditSheetFor(Annotation annotation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => HighlightEditSheet(
        annotation: annotation,
        onChangeColor: (colorKey) async {
          final error = await _annotations.changeColor(annotation.id, colorKey);
          if (error != null) _showSnackBar(error);
          return error;
        },
        onSaveNote: (noteText) async {
          final error = await _annotations.updateNoteText(annotation.id, noteText);
          if (error != null) _showSnackBar(error);
          return error;
        },
        onDelete: () async {
          final error = await _annotations.deleteAnnotation(annotation.id);
          if (error != null) _showSnackBar(error);
          return error;
        },
      ),
    );
  }

  void _onHighlightTapUrl(String url) {
    if (!url.startsWith(highlightTapUrlScheme)) return;
    final id = url.substring(highlightTapUrlScheme.length);
    final annotation = _annotations.findById(id);
    if (annotation == null) return;
    _openHighlightEditSheetFor(annotation);
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────

  void _rebuildBlockKeysIfNeeded(int blockCount) {
    if (_blockKeysChapterIndex == _reader.currentChapterIndex && _blockKeys.length == blockCount) return;
    _blockKeysChapterIndex = _reader.currentChapterIndex;
    _blockKeys = List.generate(blockCount, (_) => GlobalKey());
  }

  /// Finds the first block whose top is at or below the scroll viewport's
  /// own top edge — i.e. the first (mostly) visible block — so the
  /// bookmark toolbar button anchors at the position the user is actually
  /// looking at, not just "top of chapter".
  int _firstVisibleBlockIndex() {
    final viewportBox = _scrollViewportKey.currentContext?.findRenderObject();
    if (viewportBox is! RenderBox) return 0;
    for (var i = 0; i < _blockKeys.length; i++) {
      final blockBox = _blockKeys[i].currentContext?.findRenderObject();
      if (blockBox is! RenderBox) continue;
      final relativeTop = blockBox.localToGlobal(Offset.zero, ancestor: viewportBox).dy;
      if (relativeTop >= -(blockBox.size.height * 0.5)) return i;
    }
    return 0;
  }

  Future<void> _toggleBookmark() async {
    final blockIndex = _firstVisibleBlockIndex();
    final anchor = AnnotationAnchor(blockIndex: blockIndex, startOffset: 0, endOffset: 0);
    final error = await _annotations.toggleBookmark(
      chapterId: _reader.currentChapterId,
      anchor: anchor.serialize(),
      progressPercent: _reader.progressForBlock(blockIndex),
    );
    if (error != null) _showSnackBar(error);
  }

  // ── Jump-to-annotation (from the annotations panel) ────────────────────

  void _jumpToAnnotation(Annotation annotation) {
    Navigator.pop(context); // close the contents sheet first
    final chapterIndex = int.tryParse(annotation.chapterId);
    if (chapterIndex == null) return;
    _clearSelection();
    _reader.jumpToChapter(chapterIndex);
    // The target block will be near the top shortly after chapter load;
    // precise in-chapter scroll-to-block is a further-out refinement (no
    // per-block scroll offset tracking exists yet — see Phase 0 audit on
    // the reader's lack of scroll-position infrastructure).
  }

  Future<void> _deleteAnnotationFromPanel(Annotation annotation) async {
    final error = await _annotations.deleteAnnotation(annotation.id);
    if (error != null) _showSnackBar(error);
  }

  void _sendToQuoteStudio(Annotation annotation) {
    Navigator.pop(context); // close the contents sheet first
    Navigator.of(context).pushNamed(
      QuoteStudioArgs.routeName,
      arguments: QuoteStudioArgs(
        quoteText: annotation.selectedText ?? '',
        bookTitle: widget.book.title,
        bookAuthor: widget.book.author,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF5C3826)),
        title: Text(
          widget.book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF5C3826)),
        ),
        actions: [
          ListenableBuilder(
            listenable: Listenable.merge([_reader, _annotations]),
            builder: (context, _) {
              final bookmarked = _annotations.chapterHasBookmark(_reader.currentChapterId);
              return IconButton(
                icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
                color: bookmarked ? AppTheme.primary : const Color(0xFF5C3826),
                tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark this page',
                onPressed: _reader.status == ReaderStatus.ready ? _toggleBookmark : null,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: _showFontSettings,
          ),
          IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () {
              if (_reader.chapters.isNotEmpty) _showChapterList();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([_reader, _annotations]),
        builder: (context, _) {
          switch (_reader.status) {
            case ReaderStatus.idle:
            case ReaderStatus.loading:
              return _buildLoadingSplash();
            case ReaderStatus.error:
              return _buildError(_reader.error?.message ?? 'Something went wrong.');
            case ReaderStatus.ready:
              if (_reader.currentChapterIndex != _lastChapterIndex) {
                _lastChapterIndex = _reader.currentChapterIndex;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _pendingSelection != null) setState(() => _pendingSelection = null);
                });
              }
              return _buildChapterWithToolbar();
          }
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _reader,
        builder: (context, _) {
          if (_reader.status != ReaderStatus.ready) return const SizedBox.shrink();
          return _buildChapterNav();
        },
      ),
    );
  }

  Widget _buildLoadingSplash() {
    final book = widget.book;
    final hasCover = (book.coverUrl != null && book.coverUrl!.isNotEmpty) || book.coverAsset.isNotEmpty;
    return Container(
      color: const Color(0xFFFAF6F0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 160,
              height: 230,
              child: hasCover
                  ? BookCover(
                      coverAsset: book.coverAsset,
                      coverUrl: book.coverUrl,
                      title: book.title,
                      width: 160,
                      height: 230,
                      fit: BoxFit.cover,
                    )
                  : BookCover(
                      coverAsset: '',
                      coverUrl: null,
                      title: book.title,
                      width: 160,
                      height: 230,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              book.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Literata',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C1810),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF7A6B63),
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Opening book…',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF7A6B63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFF7A6B63)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF7A6B63)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterWithToolbar() {
    return Stack(
      children: [
        Positioned.fill(child: _buildChapter()),
        if (_annotations.chapterHasBookmark(_reader.currentChapterId))
          const Positioned(top: 0, right: 24, child: BookmarkRibbon()),
        if (_pendingSelection != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SelectionToolbar(
              onColorTap: _handleColorTap,
              onNoteTap: _handleNoteTap,
              onCopyTap: _handleCopyTap,
            ),
          ),
      ],
    );
  }

  Widget _buildChapter() {
    final chapter = _reader.currentChapter;
    if (chapter == null) return _buildError('This book has no readable chapters.');
    final blocks = _reader.currentBlocks;
    if (blocks.isEmpty) return _buildError('This chapter has no readable content.');
    _rebuildBlockKeysIfNeeded(blocks.length);

    final chapterId = _reader.currentChapterId;

    return SelectionArea(
      key: _selectionKey,
      focusNode: _selectionFocusNode,
      onSelectionChanged: _onSelectionChanged,
      // Keyed on the fixed viewport (not the scrolled content) — its
      // RenderBox's on-screen position never moves as the user scrolls, so
      // it's the correct `ancestor` reference for `_firstVisibleBlockIndex`
      // to measure each block's position *relative to what's visible*.
      child: Container(
        key: _scrollViewportKey,
        child: SingleChildScrollView(
          key: ValueKey(_reader.currentChapterIndex),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final block in blocks)
                  Padding(
                    key: _blockKeys[block.index],
                    padding: const EdgeInsets.only(bottom: 4),
                    child: HtmlWidget(
                      paintBlockHtml(block.rawHtml, _annotations.forBlock(chapterId, block.index)),
                      textStyle: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: _reader.fontSize,
                        height: 1.5,
                        color: const Color(0xFF2C1810),
                      ),
                      onTapUrl: (url) async {
                        _onHighlightTapUrl(url);
                        return true;
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChapterNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _reader.currentChapterIndex > 0 ? _goToPreviousChapter : null,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('Previous'),
            ),
            Text(
              '${_reader.currentChapterIndex + 1} / ${_reader.chapters.length}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF7A6B63)),
            ),
            TextButton.icon(
              onPressed: _reader.currentChapterIndex < _reader.chapters.length - 1 ? _goToNextChapter : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              label: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
