import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../home/mock_books.dart';
import '../../routes.dart';

class AudiobooksScreen extends StatelessWidget {
  const AudiobooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Book> audiobooks = [
      MockBooks.becoming,
      MockBooks.echoOfStarlight,
      MockBooks.circe,
      MockBooks.alchemist,
      MockBooks.atomicHabits,
    ];

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Listen &\nExplore',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Premium narrations for every mood and moment.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF7A6B63),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Featured audio card
                    _buildFeaturedBanner(context, audiobooks.first),
                    const SizedBox(height: 28),
                    const Text(
                      'Popular Audiobooks',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...audiobooks.skip(1).map((book) => _buildAudioRow(context, book)),
                  ],
                ),
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
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Audiobooks',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C3826),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.player, arguments: book),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(book.coverAsset, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2C3E50))),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'FEATURED',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.title,
                              style: const TextStyle(
                                fontFamily: 'Literata',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )),
                          Text(book.author,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioRow(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.player, arguments: book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(book.coverAsset,
                width: 64, height: 64, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64, height: 64, color: const Color(0xFFE0D4C8),
                  child: const Icon(Icons.book, color: Color(0xFF7A6B63)),
                )),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      )),
                  const SizedBox(height: 3),
                  Text(book.author,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF7A6B63),
                      )),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.headphones_rounded, size: 12, color: Color(0xFF8C481A)),
                      const SizedBox(width: 4),
                      Text(book.audioDuration,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Color(0xFF8C481A),
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_filled_rounded, color: AppTheme.primary, size: 36),
          ],
        ),
      ),
    );
  }
}
