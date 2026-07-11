import 'package:flutter/material.dart';

import '../../../domain/entities/chapter.dart';
import '../../../theme.dart';

class ChapterListSheet extends StatelessWidget {
  final List<EpubChapterRef> chapters;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const ChapterListSheet({
    super.key,
    required this.chapters,
    required this.currentIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Chapters',
                style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3826)),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: chapters.length,
                itemBuilder: (context, index) {
                  final isCurrent = index == currentIndex;
                  return ListTile(
                    title: Text(
                      chapters[index].title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent ? AppTheme.primary : const Color(0xFF5C3826),
                      ),
                    ),
                    trailing: isCurrent ? const Icon(Icons.menu_book_rounded, color: AppTheme.primary, size: 18) : null,
                    onTap: () {
                      onSelect(index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
