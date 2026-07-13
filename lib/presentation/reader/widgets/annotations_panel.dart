import 'package:flutter/material.dart';

import '../../../core/theme/highlight_colors.dart';
import '../../../domain/entities/annotation.dart';
import '../../../domain/entities/chapter.dart';
import '../../../theme.dart';

enum _AnnotationFilter { all, highlights, notes, bookmarks }

/// Segmented All/Highlights/Notes/Bookmarks list of a book's annotations,
/// grouped by chapter and sorted by [Annotation.progressPercent] — the
/// "Annotations" half of the reader's contents sheet (see
/// `reader_contents_sheet.dart`).
class AnnotationsPanel extends StatefulWidget {
  final List<Annotation> annotations;
  final List<EpubChapterRef> chapters;
  final ValueChanged<Annotation> onJumpTo;
  final ValueChanged<Annotation> onDelete;
  final ValueChanged<Annotation> onEditNote;
  final ValueChanged<Annotation> onSendToQuoteStudio;

  const AnnotationsPanel({
    super.key,
    required this.annotations,
    required this.chapters,
    required this.onJumpTo,
    required this.onDelete,
    required this.onEditNote,
    required this.onSendToQuoteStudio,
  });

  @override
  State<AnnotationsPanel> createState() => _AnnotationsPanelState();
}

class _AnnotationsPanelState extends State<AnnotationsPanel> {
  _AnnotationFilter _filter = _AnnotationFilter.all;

  static const _ink = Color(0xFF1E1E1E);
  static const _mutedText = Color(0xFF7A6B63);

  String _chapterTitle(String chapterId) {
    final index = int.tryParse(chapterId);
    if (index == null || index < 0 || index >= widget.chapters.length) return 'Chapter';
    return widget.chapters[index].title;
  }

  List<Annotation> get _filtered {
    switch (_filter) {
      case _AnnotationFilter.all:
        return widget.annotations;
      case _AnnotationFilter.highlights:
        return widget.annotations.where((a) => a.type == AnnotationType.highlight).toList();
      case _AnnotationFilter.notes:
        return widget.annotations.where((a) => a.type == AnnotationType.note).toList();
      case _AnnotationFilter.bookmarks:
        return widget.annotations.where((a) => a.type == AnnotationType.bookmark).toList();
    }
  }

  /// chapterId -> annotations in that chapter, sorted by progress, with
  /// chapters themselves ordered by their first annotation's progress.
  List<MapEntry<String, List<Annotation>>> get _grouped {
    final byChapter = <String, List<Annotation>>{};
    for (final a in _filtered) {
      byChapter.putIfAbsent(a.chapterId, () => []).add(a);
    }
    for (final list in byChapter.values) {
      list.sort((a, b) => a.progressPercent.compareTo(b.progressPercent));
    }
    final entries = byChapter.entries.toList()
      ..sort((a, b) => a.value.first.progressPercent.compareTo(b.value.first.progressPercent));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: _buildFilterBar(),
        ),
        Flexible(
          child: widget.annotations.isEmpty
              ? _buildEmptyState()
              : _filtered.isEmpty
                  ? _buildEmptyState(filtered: true)
                  : ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: [
                        for (final group in _grouped) ...[
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 6),
                            child: Text(
                              _chapterTitle(group.key),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _mutedText,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          for (final annotation in group.value) _buildRow(annotation),
                        ],
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    const labels = {
      _AnnotationFilter.all: 'All',
      _AnnotationFilter.highlights: 'Highlights',
      _AnnotationFilter.notes: 'Notes',
      _AnnotationFilter.bookmarks: 'Bookmarks',
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFF0EAE0), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final filter in _AnnotationFilter.values)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _filter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _filter == filter ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _filter == filter
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[filter]!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _filter == filter ? const Color(0xFF5C3826) : _mutedText,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({bool filtered = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filtered ? Icons.filter_alt_off_rounded : Icons.bookmark_border_rounded,
              color: _mutedText,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              filtered ? 'Nothing in this filter yet.' : 'No bookmarks, highlights, or notes yet.',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(Annotation annotation) {
    final isBookmark = annotation.type == AnnotationType.bookmark;
    final color = annotation.colorKey != null ? HighlightColors.resolve(annotation.colorKey!) : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF2ECE4), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onJumpTo(annotation),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 44,
                  margin: const EdgeInsets.only(top: 2, right: 10),
                  decoration: BoxDecoration(
                    color: isBookmark ? AppTheme.primary : (color ?? _mutedText),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isBookmark)
                        const Row(
                          children: [
                            Icon(Icons.bookmark_rounded, size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text('Bookmark', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: _ink)),
                          ],
                        )
                      else ...[
                        if ((annotation.selectedText ?? '').isNotEmpty)
                          Text(
                            annotation.selectedText!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _ink, height: 1.35),
                          ),
                        if ((annotation.noteText ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            annotation.noteText!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontStyle: FontStyle.italic, color: _mutedText),
                          ),
                        ],
                      ],
                      const SizedBox(height: 6),
                      Text(
                        _formatTimestamp(annotation.updatedAt),
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: _mutedText),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: _mutedText),
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        widget.onEditNote(annotation);
                        break;
                      case 'quote':
                        widget.onSendToQuoteStudio(annotation);
                        break;
                      case 'delete':
                        widget.onDelete(annotation);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isBookmark)
                      const PopupMenuItem(value: 'edit', child: Text('Edit note')),
                    if (!isBookmark)
                      const PopupMenuItem(value: 'quote', child: Text('Create quote card')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
