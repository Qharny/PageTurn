import '../../core/errors/app_exception.dart';
import '../../domain/entities/book.dart';

class GoogleBookVolumeModel {
  final String id;
  final String title;
  final List<String> authors;
  final String? description;
  final int? pageCount;
  final List<String> categories;
  final double? averageRating;
  final int? ratingsCount;
  final String? thumbnailUrl;
  final String language;
  final String? isbn13;
  final String? isbn10;

  const GoogleBookVolumeModel({
    required this.id,
    required this.title,
    required this.authors,
    this.description,
    this.pageCount,
    this.categories = const [],
    this.averageRating,
    this.ratingsCount,
    this.thumbnailUrl,
    this.language = 'en',
    this.isbn13,
    this.isbn10,
  });

  factory GoogleBookVolumeModel.fromJson(Map<String, dynamic> json) {
    try {
      final info = json['volumeInfo'] as Map<String, dynamic>? ?? {};
      final identifiers = (info['industryIdentifiers'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      String? isbnOfType(String type) {
        for (final id in identifiers) {
          if (id['type'] == type) return id['identifier'] as String?;
        }
        return null;
      }

      final imageLinks = info['imageLinks'] as Map<String, dynamic>?;

      return GoogleBookVolumeModel(
        id: json['id'] as String,
        title: info['title'] as String? ?? 'Untitled',
        authors: (info['authors'] as List<dynamic>? ?? []).cast<String>(),
        description: info['description'] as String?,
        pageCount: info['pageCount'] as int?,
        categories: (info['categories'] as List<dynamic>? ?? []).cast<String>(),
        averageRating: (info['averageRating'] as num?)?.toDouble(),
        ratingsCount: info['ratingsCount'] as int?,
        thumbnailUrl: rewriteToHttps(imageLinks?['thumbnail'] as String?),
        language: info['language'] as String? ?? 'en',
        isbn13: isbnOfType('ISBN_13'),
        isbn10: isbnOfType('ISBN_10'),
      );
    } catch (e) {
      throw ParseException('Could not read this result from Google Books.', e);
    }
  }

  /// Google Books sometimes returns `http://` cover URLs, which are blocked
  /// under App Transport Security / cleartext-traffic policies.
  static String? rewriteToHttps(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://')) return 'https://${url.substring(7)}';
    return url;
  }

  Book toEntity() {
    const tagPalette = [
      [0xFFECEFF1, 0xFF455A64],
      [0xFFE0F2F1, 0xFF00796B],
    ];
    final tags = categories.take(2).toList().asMap().entries.map((e) {
      final palette = tagPalette[e.key % tagPalette.length];
      return BookTag(text: e.value, backgroundColorValue: palette[0], textColorValue: palette[1]);
    }).toList();

    return Book(
      id: 'googlebooks_$id',
      title: title,
      author: authors.isEmpty ? 'Unknown' : authors.join(', '),
      coverAsset: '',
      coverUrl: thumbnailUrl,
      rating: averageRating ?? 0.0,
      reviewCount: ratingsCount?.toString() ?? '0',
      length: pageCount != null ? '${pageCount}p' : '',
      audioDuration: '',
      language: language.toUpperCase(),
      description: description ?? '',
      tags: tags,
      reviews: const [],
      sourceType: BookSourceType.googleBooks,
      remoteId: id,
      isbn: isbn13 ?? isbn10,
    );
  }
}
