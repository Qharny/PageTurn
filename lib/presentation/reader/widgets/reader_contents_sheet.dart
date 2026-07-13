import 'package:flutter/material.dart';

import '../../../domain/entities/annotation.dart';
import '../../../domain/entities/chapter.dart';
import '../../../theme.dart';
import 'annotations_panel.dart';

/// The reader's "contents" bottom sheet: Chapters and Annotations as two
/// tabs of one sheet. The reader has no `Drawer` anywhere (chapters were
/// already a bottom sheet before annotations existed) — this extends that
/// existing sheet rather than introducing a new navigation surface.
class ReaderContentsSheet extends StatefulWidget {
  final List<EpubChapterRef> chapters;
  final int currentIndex;
  final ValueChanged<int> onSelectChapter;

  final List<Annotation> annotations;
  final ValueChanged<Annotation> onJumpToAnnotation;
  final ValueChanged<Annotation> onDeleteAnnotation;
  final ValueChanged<Annotation> onEditNote;
  final ValueChanged<Annotation> onSendToQuoteStudio;

  const ReaderContentsSheet({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.onSelectChapter,
    required this.annotations,
    required this.onJumpToAnnotation,
    required this.onDeleteAnnotation,
    required this.onEditNote,
    required this.onSendToQuoteStudio,
  });

  @override
  State<ReaderContentsSheet> createState() => _ReaderContentsSheetState();
}

class _ReaderContentsSheetState extends State<ReaderContentsSheet> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.78),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Contents',
                style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3826)),
              ),
            ),
            TabBar(
              controller: _tabs,
              labelColor: const Color(0xFF5C3826),
              unselectedLabelColor: const Color(0xFF7A6B63),
              indicatorColor: AppTheme.primary,
              labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                const Tab(text: 'Chapters'),
                Tab(text: widget.annotations.isEmpty ? 'Annotations' : 'Annotations (${widget.annotations.length})'),
              ],
            ),
            Flexible(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _buildChapterList(),
                  AnnotationsPanel(
                    annotations: widget.annotations,
                    chapters: widget.chapters,
                    onJumpTo: widget.onJumpToAnnotation,
                    onDelete: widget.onDeleteAnnotation,
                    onEditNote: widget.onEditNote,
                    onSendToQuoteStudio: widget.onSendToQuoteStudio,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.chapters.length,
      itemBuilder: (context, index) {
        final isCurrent = index == widget.currentIndex;
        return ListTile(
          title: Text(
            widget.chapters[index].title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppTheme.primary : const Color(0xFF5C3826),
            ),
          ),
          trailing: isCurrent ? const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 18) : null,
          onTap: () {
            widget.onSelectChapter(index);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
