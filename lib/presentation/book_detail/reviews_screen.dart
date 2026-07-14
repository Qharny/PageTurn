import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../../domain/entities/review.dart';
import '../../core/auth/session_provider.dart';
import 'reviews_provider.dart';

/// Full "See all" page for a book's reviews — real reviews from the
/// Supabase `reviews` table, with a "Write a Review" flow for signed-in
/// users.
class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.book});

  final Book book;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const _chocolateBrown = Color(0xFF5C3826);
  static const _mutedText = Color(0xFF7A6B63);

  @override
  void initState() {
    super.initState();
    ReviewsProvider.instance.loadReviews(widget.book.id);
  }

  void _openWriteReviewSheet() {
    SessionProvider.instance.requireAuth(
      context,
      pendingAction: () => _showReviewSheet(context, widget.book.id),
      reason: 'Sign in to write a review.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReviewsProvider.instance,
      builder: (context, _) {
        final reviews = ReviewsProvider.instance.reviewsFor(widget.book.id);
        final isLoading = ReviewsProvider.instance.isLoading(widget.book.id);

        return Scaffold(
          backgroundColor: AppTheme.neutral,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openWriteReviewSheet,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.rate_review_rounded, size: 18),
            label: const Text('Write a Review', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: isLoading && reviews.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader(context)),
                      SliverToBoxAdapter(child: _buildSummary(reviews)),
                      if (reviews.isEmpty)
                        SliverToBoxAdapter(child: _buildEmptyState())
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
      },
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
                  widget.book.title,
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 100),
      child: Column(
        children: [
          const Icon(Icons.rate_review_outlined, size: 48, color: _mutedText),
          const SizedBox(height: 16),
          const Text(
            'No reviews yet',
            style: TextStyle(fontFamily: 'Literata', fontSize: 17, fontWeight: FontWeight.bold, color: _chocolateBrown),
          ),
          const SizedBox(height: 6),
          const Text(
            'Be the first to share your thoughts on this book.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
          ),
        ],
      ),
    );
  }

  /// Exact per-star counts from the real review set (no fabricated curve).
  List<int> _distribution(List<Review> reviews) {
    final counts = List.filled(5, 0);
    for (final r in reviews) {
      final star = r.rating.clamp(1, 5);
      counts[star - 1]++;
    }
    return counts.reversed.toList(); // index 0 = 5-star
  }

  Widget _buildSummary(List<Review> reviews) {
    final count = reviews.length;
    final avg = count == 0
        ? 0.0
        : reviews.map((r) => r.rating).reduce((a, b) => a + b) / count;
    final dist = _distribution(reviews);

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
          Column(
            children: [
              Text(
                count == 0 ? '—' : avg.toStringAsFixed(1),
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
                count == 0 ? 'No ratings yet' : '$count review${count == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: _mutedText,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final fraction = count == 0 ? 0.0 : dist[i] / count;
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
                            value: fraction,
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

  Widget _buildReviewCard(Review review) {
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
                      ? review.reviewerName.substring(0, 1).toUpperCase()
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

  void _showReviewSheet(BuildContext context, String bookId) {
    final existing = ReviewsProvider.instance.myReviewFor(bookId);
    int rating = existing?.rating ?? 5;
    final commentCtrl = TextEditingController(text: existing?.comment ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing != null ? 'Edit Your Review' : 'Write a Review',
                    style: const TextStyle(fontFamily: 'Literata', fontSize: 20, fontWeight: FontWeight.bold, color: _chocolateBrown),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      return IconButton(
                        onPressed: () => setSheetState(() => rating = starValue),
                        icon: Icon(
                          starValue <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFF4A836),
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Your thoughts',
                      labelStyle: TextStyle(color: _mutedText),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontFamily: 'Inter', color: _chocolateBrown),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setSheetState(() => saving = true);
                              final success = await ReviewsProvider.instance.submitReview(
                                bookId,
                                rating: rating,
                                comment: commentCtrl.text.trim(),
                              );
                              if (sheetContext.mounted) Navigator.pop(sheetContext);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Review posted!' : "Couldn't post your review. Please try again."),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Post Review', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
