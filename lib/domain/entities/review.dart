/// A reader's review of a book, backed by the Supabase `reviews` table.
class Review {
  final String id;
  final String bookId;
  final String profileId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.bookId,
    required this.profileId,
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromRow(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>?;
    return Review(
      id: row['id'] as String,
      bookId: row['book_id'] as String,
      profileId: row['profile_id'] as String,
      reviewerName: (profile?['name'] as String?)?.isNotEmpty == true
          ? profile!['name'] as String
          : 'Reader',
      reviewerAvatarUrl: profile?['avatar_url'] as String?,
      rating: (row['rating'] as num).toInt(),
      comment: row['comment'] as String? ?? '',
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
