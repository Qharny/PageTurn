import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/review.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

/// Loads and writes real user reviews for books, backed by the Supabase
/// `reviews` table. Follows the same direct-Supabase `ChangeNotifier`
/// pattern as `ReadingClubProvider`.
class ReviewsProvider extends ChangeNotifier {
  static final ReviewsProvider instance = ReviewsProvider._internal();
  ReviewsProvider._internal();

  final Map<String, List<Review>> _reviewsByBook = {};
  final Set<String> _loading = {};

  bool get _isSupabaseInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Review> reviewsFor(String bookId) => _reviewsByBook[bookId] ?? const [];

  bool isLoading(String bookId) => _loading.contains(bookId);

  double averageRatingFor(String bookId) {
    final reviews = reviewsFor(bookId);
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
  }

  int reviewCountFor(String bookId) => reviewsFor(bookId).length;

  Review? myReviewFor(String bookId) {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return null;
    for (final review in reviewsFor(bookId)) {
      if (review.profileId == userId) return review;
    }
    return null;
  }

  Future<void> loadReviews(String bookId) async {
    if (!_isSupabaseInitialized) return;
    _loading.add(bookId);
    notifyListeners();

    try {
      final res = await SupabaseService.client
          .from('reviews')
          .select('*, profiles(name, avatar_url)')
          .eq('book_id', bookId)
          .order('created_at', ascending: false);

      _reviewsByBook[bookId] = (res as List)
          .map((row) => Review.fromRow(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error loading reviews: $e');
    } finally {
      _loading.remove(bookId);
      notifyListeners();
    }
  }

  /// Creates or updates the current user's review for [bookId]. Requires a
  /// real (non-anonymous) account — enforced both here and by RLS.
  Future<bool> submitReview(String bookId, {required int rating, required String comment}) async {
    if (!_isSupabaseInitialized) return false;
    if (!AuthService.instance.isAuthenticated) return false;
    final user = AuthService.instance.currentUser!;

    try {
      await SupabaseService.client.from('reviews').upsert(
        {
          'book_id': bookId,
          'profile_id': user.id,
          'rating': rating,
          'comment': comment,
        },
        onConflict: 'book_id,profile_id',
      );
      await loadReviews(bookId);
      return true;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }

  Future<bool> deleteReview(String bookId) async {
    if (!_isSupabaseInitialized) return false;
    final user = AuthService.instance.currentUser;
    if (user == null) return false;

    try {
      await SupabaseService.client
          .from('reviews')
          .delete()
          .eq('book_id', bookId)
          .eq('profile_id', user.id);
      await loadReviews(bookId);
      return true;
    } catch (e) {
      debugPrint('Error deleting review: $e');
      return false;
    }
  }
}
