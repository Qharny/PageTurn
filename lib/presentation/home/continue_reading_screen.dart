import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../../routes.dart';
import '../common/widgets/book_cover.dart';
import '../library/library_provider.dart';

/// Full "See All" page for the home screen's Continue Reading rail.
/// Lists every book that is currently in progress (started but not finished).
class ContinueReadingScreen extends StatelessWidget {
  const ContinueReadingScreen({super.key});

  static const _chocolateBrown = Color(0xFF5C3826);
  static const _mutedText = Color(0xFF7A6B63);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(
              child: ListenableBuilder(
                listenable: LibraryProvider.instance,
                builder: (context, _) {
                  final readingBooks = LibraryProvider.instance.books
                      .where((b) =>
                          b.progress != null &&
                          b.progress! > 0 &&
                          b.isFinished != true)
                      .toList();

                  if (readingBooks.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    physics: const BouncingScrollPhysics(),
                    itemCount: readingBooks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) =>
                        _buildCard(context, readingBooks[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: _chocolateBrown, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Reading',
                  style: TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _chocolateBrown,
                  ),
                ),
                Text(
                  'Pick up where you left off',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: _mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: AppTheme.primary, size: 34),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing in progress',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: _chocolateBrown,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start a book to see it here.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Book book) {
    final progress = book.progress ?? 0.0;
    final pagesText = book.length.replaceAll('p', '');
    final totalPages = int.tryParse(pagesText) ?? 300;
    final readPages = (totalPages * progress).toInt();

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.details, arguments: book),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 62,
              height: 88,
              child: BookCover(
                coverAsset: book.coverAsset,
                coverUrl: book.coverUrl,
                title: book.title,
                fit: BoxFit.cover,
                borderRadius: 10,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _chocolateBrown,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        '$readPages/$totalPages pages',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF5EFEB),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
