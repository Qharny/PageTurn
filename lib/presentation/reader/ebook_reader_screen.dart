import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../data/models/book_model.dart';
import '../../theme.dart';
import 'reader_provider.dart';
import 'widgets/chapter_list_sheet.dart';
import 'widgets/font_settings_sheet.dart';

/// The distraction-free EPUB reader. Opens the same way for a downloaded
/// Gutendex book or a locally-imported one — both simply arrive here with
/// [Book.localFilePath] already set.
class EbookReaderScreen extends StatefulWidget {
  const EbookReaderScreen({super.key, required this.book});

  final Book book;

  @override
  State<EbookReaderScreen> createState() => _EbookReaderScreenState();
}

class _EbookReaderScreenState extends State<EbookReaderScreen> {
  late final ReaderProvider _provider = ReaderProvider();

  @override
  void initState() {
    super.initState();
    _provider.loadBook(widget.book);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChapterListSheet(
        chapters: _provider.chapters,
        currentIndex: _provider.currentChapterIndex,
        onSelect: _provider.jumpToChapter,
      ),
    );
  }

  void _showFontSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: _provider,
        builder: (context, _) => FontSettingsSheet(
          fontSize: _provider.fontSize,
          onIncrease: _provider.increaseFontSize,
          onDecrease: _provider.decreaseFontSize,
        ),
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
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            onPressed: _showFontSettings,
          ),
          IconButton(
            icon: const Icon(Icons.list_rounded),
            onPressed: () {
              if (_provider.chapters.isNotEmpty) _showChapterList();
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          switch (_provider.status) {
            case ReaderStatus.idle:
            case ReaderStatus.loading:
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            case ReaderStatus.error:
              return _buildError(_provider.error?.message ?? 'Something went wrong.');
            case ReaderStatus.ready:
              return _buildChapter();
          }
        },
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: _provider,
        builder: (context, _) {
          if (_provider.status != ReaderStatus.ready) return const SizedBox.shrink();
          return _buildChapterNav();
        },
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

  Widget _buildChapter() {
    final chapter = _provider.currentChapter;
    if (chapter == null) return _buildError('This book has no readable chapters.');
    return SingleChildScrollView(
      key: ValueKey(_provider.currentChapterIndex),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: HtmlWidget(
        chapter.contentHtml,
        textStyle: TextStyle(fontFamily: 'Literata', fontSize: _provider.fontSize, height: 1.5, color: const Color(0xFF2C1810)),
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
              onPressed: _provider.currentChapterIndex > 0 ? _provider.previousChapter : null,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 14),
              label: const Text('Previous'),
            ),
            Text(
              '${_provider.currentChapterIndex + 1} / ${_provider.chapters.length}',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Color(0xFF7A6B63)),
            ),
            TextButton.icon(
              onPressed: _provider.currentChapterIndex < _provider.chapters.length - 1 ? _provider.nextChapter : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              label: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
