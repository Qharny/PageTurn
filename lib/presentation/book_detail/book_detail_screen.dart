import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../../routes.dart';

class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Stack(
        children: [
          // Speckled paper texture background
          const Positioned.fill(
            child: CustomPaint(painter: _SpeckPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildBookCover(),
                        const SizedBox(height: 24),
                        _buildBookTitle(),
                        const SizedBox(height: 8),
                        _buildRatingRow(),
                        const SizedBox(height: 28),
                        _buildActionsBar(context),
                        const SizedBox(height: 32),
                        _buildSpecsBar(),
                        const SizedBox(height: 40),
                        _buildAboutSection(),
                        const SizedBox(height: 24),
                        _buildTagsRow(),
                        const SizedBox(height: 36),
                        _buildReviewsSection(),
                        const SizedBox(height: 48), // Padding at bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 26),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFF5C3826), size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBookCover() {
    return Center(
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            book.coverAsset,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback if cover image asset not found
              return Container(
                width: 190,
                height: 280,
                color: const Color(0xFF37474F),
                child: Center(
                  child: Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBookTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            book.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3826),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            book.author,
            style: const TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5C3826),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stars
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starVal = index + 1;
            if (book.rating >= starVal) {
              return const Icon(Icons.star_rounded, color: Color(0xFFFBC02D), size: 18);
            } else if (book.rating > index && book.rating < starVal) {
              return const Icon(Icons.star_half_rounded, color: Color(0xFFFBC02D), size: 18);
            } else {
              return const Icon(Icons.star_outline_rounded, color: Color(0xFFFBC02D), size: 18);
            }
          }),
        ),
        const SizedBox(width: 8),
        Text(
          '${book.rating} (${book.reviewCount})',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A6B63),
          ),
        ),
      ],
    );
  }

  Widget _buildActionsBar(BuildContext context) {
    final borderStyle = OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF5C3826),
      side: const BorderSide(color: Color(0xFFE2DDD5), width: 1.5),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0,
    );

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.reader, arguments: book);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_book_rounded, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Read',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              style: borderStyle,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.player, arguments: book);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.headset_rounded, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Listen',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 60,
            child: OutlinedButton(
              style: borderStyle,
              onPressed: () {},
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.download_rounded, size: 20),
                  SizedBox(height: 2),
                  Text(
                    'Get',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF3EFE9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpecCol('LENGTH', book.length),
              _buildSpecDivider(),
              _buildSpecCol('AUDIO', book.audioDuration),
              _buildSpecDivider(),
              _buildSpecCol('ENGLISH', book.language),
            ],
          ),
        ),
        Positioned(
          bottom: -12,
          right: 20,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecCol(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9C8F84),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Literata',
            fontFamilyFallback: ['serif'],
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3826),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecDivider() {
    return Container(
      width: 1.5,
      height: 24,
      color: const Color(0xFFE2DDD5),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this book',
          style: TextStyle(
            fontFamily: 'Literata',
            fontFamilyFallback: ['serif'],
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C3826),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          book.description,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: Color(0xFF7A6B63),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'READ MORE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagsRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: book.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(tag.backgroundColorValue),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag.text.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(tag.textColorValue),
              letterSpacing: 0.5,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Community Reviews',
              style: TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C3826),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A6B63),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...book.reviews.map((review) => _buildReviewCard(review)),
      ],
    );
  }

  Widget _buildReviewCard(BookReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFF3EFE9),
                child: Text(
                  review.reviewerName.substring(0, 1),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5C3826),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewerName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star_rounded,
                        color: index < review.rating ? const Color(0xFFFBC02D) : const Color(0xFFE0E0E0),
                        size: 14,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontStyle: FontStyle.italic,
              fontSize: 13,
              color: Color(0xFF7A6B63),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeckPainter extends CustomPainter {
  const _SpeckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..color = AppTheme.secondary.withValues(alpha: 0.05);

    const speckCount = 90;
    for (var i = 0; i < speckCount; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.1 + 0.3;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeckPainter oldDelegate) => false;
}
