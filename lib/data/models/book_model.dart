class Book {
  final String id;
  final String title;
  final String author;
  final String coverAsset;
  final double rating;
  final String reviewCount;
  final String length;
  final String audioDuration;
  final String language;
  final String description;
  final List<BookTag> tags;
  final List<BookReview> reviews;
  final double? progress; // Optional reading progress (0.0 to 1.0)
  final bool? isFinished; // Optional flag for completed books

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverAsset,
    required this.rating,
    required this.reviewCount,
    required this.length,
    required this.audioDuration,
    required this.language,
    required this.description,
    required this.tags,
    required this.reviews,
    this.progress,
    this.isFinished,
  });
}

class BookTag {
  final String text;
  final int backgroundColorValue; // Hex color code
  final int textColorValue;       // Hex color code

  const BookTag({
    required this.text,
    required this.backgroundColorValue,
    required this.textColorValue,
  });
}

class BookReview {
  final String reviewerName;
  final String reviewerAvatarUrl; // Asset path or custom avatar
  final double rating;
  final String comment;

  const BookReview({
    required this.reviewerName,
    required this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
  });
}
