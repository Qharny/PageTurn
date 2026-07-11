import '../../core/errors/app_exception.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/book.dart';

/// A small, fixed tag palette cycled through for Gutendex subjects, since
/// Gutendex gives no color/category metadata of its own.
const List<List<int>> _tagPalette = [
  [0xFFE8F5E9, 0xFF2E7D32],
  [0xFFE3F2FD, 0xFF1E88E5],
  [0xFFFFF3E0, 0xFFE65100],
  [0xFFEDE7F6, 0xFF5E35B1],
  [0xFFECEFF1, 0xFF455A64],
];

class GutendexBookModel {
  final int id;
  final String rawAuthorNames;
  final String title;
  final List<String> subjects;
  final List<String> languages;
  final Map<String, dynamic> formats;
  final int downloadCount;
  final String? summary;

  const GutendexBookModel({
    required this.id,
    required this.rawAuthorNames,
    required this.title,
    required this.subjects,
    required this.languages,
    required this.formats,
    required this.downloadCount,
    this.summary,
  });

  factory GutendexBookModel.fromJson(Map<String, dynamic> json) {
    try {
      final authors = (json['authors'] as List<dynamic>? ?? [])
          .map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
          .where((n) => n.isNotEmpty)
          .toList();
      final summaries = json['summaries'] as List<dynamic>?;
      return GutendexBookModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? 'Untitled',
        rawAuthorNames: authors.join(' & '),
        subjects: (json['subjects'] as List<dynamic>? ?? []).cast<String>(),
        languages: (json['languages'] as List<dynamic>? ?? ['en']).cast<String>(),
        formats: Map<String, dynamic>.from(json['formats'] as Map? ?? {}),
        downloadCount: json['download_count'] as int? ?? 0,
        summary: (summaries != null && summaries.isNotEmpty) ? summaries.first as String : null,
      );
    } catch (e) {
      throw ParseException('Could not read this book from Gutendex.', e);
    }
  }

  /// "Doyle, Arthur Conan" -> "Arthur Conan Doyle". Handles multiple
  /// "&"-joined authors and names with no comma (left as-is).
  static String formatAuthorName(String raw) {
    if (raw.isEmpty) return 'Unknown';
    return raw.split(' & ').map((name) {
      final parts = name.split(',');
      if (parts.length < 2) return name.trim();
      final last = parts[0].trim();
      final first = parts.sublist(1).join(',').trim();
      return '$first $last'.trim();
    }).join(', ');
  }

  /// Picks the best EPUB URL from a Gutendex `formats` map. Gutendex
  /// normally exposes exactly one `application/epub+zip` entry, but this
  /// defensively scans all epub-flavoured keys in case of variants, and
  /// prefers a URL that does NOT look like the images-inclusive copy.
  static String? selectEpubUrl(Map<String, dynamic> formats) {
    final epubEntries = formats.entries.where((e) => e.key.contains('epub')).toList();
    if (epubEntries.isEmpty) return null;
    final noImagesMatch = epubEntries.where((e) => !_looksLikeImagesVariant(e.value.toString()));
    if (noImagesMatch.isNotEmpty) return noImagesMatch.first.value.toString();
    return epubEntries.first.value.toString();
  }

  static bool _looksLikeImagesVariant(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.images') || lower.contains('-images');
  }

  static String? selectCoverUrl(Map<String, dynamic> formats) {
    return formats['image/jpeg'] as String?;
  }

  Book toEntity() {
    final tags = <BookTag>[];
    for (var i = 0; i < subjects.length && i < 3; i++) {
      final label = subjects[i].split(' -- ').first.trim();
      final palette = _tagPalette[i % _tagPalette.length];
      tags.add(BookTag(
        text: label.length > 24 ? '${label.substring(0, 24)}…' : label,
        backgroundColorValue: palette[0],
        textColorValue: palette[1],
      ));
    }

    return Book(
      id: 'gutenberg_$id',
      title: title,
      author: formatAuthorName(rawAuthorNames),
      coverAsset: '',
      coverUrl: selectCoverUrl(formats),
      rating: Formatters.popularityRating(downloadCount),
      reviewCount: Formatters.compactCount(downloadCount),
      length: '',
      audioDuration: '',
      language: languages.isNotEmpty ? languages.first.toUpperCase() : 'EN',
      description: summary ?? '',
      tags: tags,
      reviews: const [],
      sourceType: BookSourceType.gutenberg,
      remoteId: id.toString(),
      downloadUrl: selectEpubUrl(formats),
      fileFormat: 'epub',
    );
  }
}
