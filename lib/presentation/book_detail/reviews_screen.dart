import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';

/// Full "See all" page for a book's reviews. Shows a rating summary with a
/// star distribution and the complete list of reader reviews.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.book});

  final Book book;

  static const _chocolateBrown = Color(0xFF5C3826);
  static const _mutedText = Color(0xFF7A6B63);

  /// Combines the book's own reviews with a few sample reviews so the page
  /// always feels populated.
  List<BookReview> get _allReviews => [
        ...book.reviews,
        const BookReview(
          reviewerName: 'Maya R.',
          reviewerAvatarUrl: '',
          rating: 5,
          comment:
              'Could not put it down. The pacing is immaculate and the ending genuinely surprised me.',
        ),
        const BookReview(
          reviewerName: 'Daniel O.',
          reviewerAvatarUrl: '',
          rating: 4,
          comment:
              'Beautifully written with rich, memorable characters. Dragged a little in the middle but well worth it.',
        ),
        const BookReview(
          reviewerName: 'Priya S.',
          reviewerAvatarUrl: '',
          rating: 5,
          comment:
              'One of my favourite reads this year. I already recommended it to everyone in my book club.',
        ),
        const BookReview(
          reviewerName: 'Tom H.',
          reviewerAvatarUrl: '',
          rating: 3,
          comment:
              'Solid but not spectacular. Some plot threads felt unresolved by the final chapter.',
        ),
        const BookReview(
          reviewerName: 'Grace W.',
          reviewerAvatarUrl: '',
          rating: 5,
          comment:
              'Gorgeous prose and a story with real heart. The kind of book you think about long after finishing.',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final reviews = _allReviews;
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: _buildSummary(reviews)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildReviewCard(reviews[index]),
                  childCount: reviews.length,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reviews',
                  style: TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _chocolateBrown,
                  ),
                ),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
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

  /// Weighted star distribution (5→1) derived from the book's average rating.
  List<double> _distribution(double avg) {
    if (avg >= 4.5) return [0.72, 0.20, 0.05, 0.02, 0.01];
    if (avg >= 4.0) return [0.55, 0.28, 0.10, 0.05, 0.02];
    if (avg >= 3.5) return [0.40, 0.30, 0.18, 0.08, 0.04];
    return [0.28, 0.30, 0.22, 0.12, 0.08];
  }

  Widget _buildSummary(List<BookReview> reviews) {
    final avg = book.rating;
    final dist = _distribution(avg);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E8DC), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Average score
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: _chocolateBrown,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < avg.round() ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 15,
                    color: const Color(0xFFF4A836),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '${book.reviewCount} reviews',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Text(
                        '$star',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _mutedText,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: dist[i],
                            backgroundColor: const Color(0xFFF0EAE0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFF4A836)),
                            minHeight: 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BookReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0E8DC), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  review.reviewerName.isNotEmpty
                      ? review.reviewerName.substring(0, 1)
                      : '?',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _chocolateBrown,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: i < review.rating
                              ? const Color(0xFFF4A836)
                              : const Color(0xFFE0D5C8),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: _mutedText,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
