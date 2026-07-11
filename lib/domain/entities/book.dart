import 'audiobook.dart';

/// Where a [Book]'s content/metadata came from. Nullable on [Book] — mock
/// catalog entries and user-typed custom books simply have no source.
enum BookSourceType {
  gutenberg,
  librivox,
  googleBooks,
  localImport,
  supabase,
}

class Book {
  final String id;
  final String title;
  final String author;
  final String coverAsset; // bundled asset path, used by mock/catalog books
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

  // --- Content-source fields (added for Gutendex/LibriVox/Google Books/local import) ---
  final String? coverUrl; // remote cover image, takes priority over [coverAsset] when set
  final BookSourceType? sourceType;
  final String? remoteId; // id within the source's own catalog
  final String? downloadUrl; // remote EPUB location (Gutendex)
  final String? fileFormat; // e.g. 'epub'
  final String? isbn; // from Google Books industryIdentifiers
  final String? localFilePath; // set once an EPUB has been downloaded/imported
  final List<AudiobookChapter>? audioChapters; // populated for LibriVox audiobooks

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
    this.coverUrl,
    this.sourceType,
    this.remoteId,
    this.downloadUrl,
    this.fileFormat,
    this.isbn,
    this.localFilePath,
    this.audioChapters,
  });

  /// True once the book's content is on-device and ready for the reader,
  /// whether via download or local import.
  bool get isAvailableOffline => localFilePath != null && localFilePath!.isNotEmpty;

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      coverAsset: json['coverAsset'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as String? ?? '0',
      length: json['length'] as String? ?? '',
      audioDuration: json['audioDuration'] as String? ?? '',
      language: json['language'] as String? ?? 'Eng',
      description: json['description'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((t) => BookTag.fromJson(t as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((r) => BookReview.fromJson(r as Map<String, dynamic>))
          .toList(),
      progress: (json['progress'] as num?)?.toDouble(),
      isFinished: json['isFinished'] as bool?,
      coverUrl: json['coverUrl'] as String?,
      sourceType: json['sourceType'] != null
          ? BookSourceType.values.firstWhere(
              (e) => e.name == json['sourceType'],
              orElse: () => BookSourceType.localImport,
            )
          : null,
      remoteId: json['remoteId'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      fileFormat: json['fileFormat'] as String?,
      isbn: json['isbn'] as String?,
      localFilePath: json['localFilePath'] as String?,
      audioChapters: (json['audioChapters'] as List<dynamic>?)
          ?.map((c) => AudiobookChapter.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'coverAsset': coverAsset,
        'rating': rating,
        'reviewCount': reviewCount,
        'length': length,
        'audioDuration': audioDuration,
        'language': language,
        'description': description,
        'tags': tags.map((t) => t.toJson()).toList(),
        'reviews': reviews.map((r) => r.toJson()).toList(),
        'progress': progress,
        'isFinished': isFinished,
        'coverUrl': coverUrl,
        'sourceType': sourceType?.name,
        'remoteId': remoteId,
        'downloadUrl': downloadUrl,
        'fileFormat': fileFormat,
        'isbn': isbn,
        'localFilePath': localFilePath,
        'audioChapters': audioChapters?.map((c) => c.toJson()).toList(),
      };

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? coverAsset,
    double? rating,
    String? reviewCount,
    String? length,
    String? audioDuration,
    String? language,
    String? description,
    List<BookTag>? tags,
    List<BookReview>? reviews,
    double? progress,
    bool? isFinished,
    String? coverUrl,
    BookSourceType? sourceType,
    String? remoteId,
    String? downloadUrl,
    String? fileFormat,
    String? isbn,
    String? localFilePath,
    List<AudiobookChapter>? audioChapters,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverAsset: coverAsset ?? this.coverAsset,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      length: length ?? this.length,
      audioDuration: audioDuration ?? this.audioDuration,
      language: language ?? this.language,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      reviews: reviews ?? this.reviews,
      progress: progress ?? this.progress,
      isFinished: isFinished ?? this.isFinished,
      coverUrl: coverUrl ?? this.coverUrl,
      sourceType: sourceType ?? this.sourceType,
      remoteId: remoteId ?? this.remoteId,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileFormat: fileFormat ?? this.fileFormat,
      isbn: isbn ?? this.isbn,
      localFilePath: localFilePath ?? this.localFilePath,
      audioChapters: audioChapters ?? this.audioChapters,
    );
  }
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

  factory BookTag.fromJson(Map<String, dynamic> json) => BookTag(
        text: json['text'] as String,
        backgroundColorValue: json['backgroundColorValue'] as int,
        textColorValue: json['textColorValue'] as int,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'backgroundColorValue': backgroundColorValue,
        'textColorValue': textColorValue,
      };
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

  factory BookReview.fromJson(Map<String, dynamic> json) => BookReview(
        reviewerName: json['reviewerName'] as String,
        reviewerAvatarUrl: json['reviewerAvatarUrl'] as String? ?? '',
        rating: (json['rating'] as num).toDouble(),
        comment: json['comment'] as String,
      );

  Map<String, dynamic> toJson() => {
        'reviewerName': reviewerName,
        'reviewerAvatarUrl': reviewerAvatarUrl,
        'rating': rating,
        'comment': comment,
      };
}
