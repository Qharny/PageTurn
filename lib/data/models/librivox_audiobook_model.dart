import '../../core/errors/app_exception.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/audiobook.dart';
import '../../domain/entities/book.dart';

const List<List<int>> _librivoxTagPalette = [
  [0xFFE0F2F1, 0xFF00796B],
  [0xFFFBEFE3, 0xFFE67E22],
  [0xFFF3E5F5, 0xFF6A1B9A],
];

class LibriVoxAudiobookModel {
  final String id;
  final String title;
  final List<String> authorNames;
  final String descriptionHtml;
  final int totalTimeSeconds;
  final List<String> genres;
  final List<AudiobookChapter> chapters;

  const LibriVoxAudiobookModel({
    required this.id,
    required this.title,
    required this.authorNames,
    required this.descriptionHtml,
    required this.totalTimeSeconds,
    required this.genres,
    required this.chapters,
  });

  factory LibriVoxAudiobookModel.fromJson(Map<String, dynamic> json) {
    try {
      final authors = (json['authors'] as List<dynamic>? ?? [])
          .map((a) {
            final map = a as Map<String, dynamic>;
            final first = (map['first_name'] as String? ?? '').trim();
            final last = (map['last_name'] as String? ?? '').trim();
            return '$first $last'.trim();
          })
          .where((n) => n.isNotEmpty)
          .toList();

      final genresRaw = json['genres'];
      final genres = genresRaw is List
          ? genresRaw.map((g) => (g as Map<String, dynamic>)['name'] as String? ?? '').where((n) => n.isNotEmpty).toList()
          : <String>[];

      final sectionsRaw = json['sections'];
      final chapters = <AudiobookChapter>[];
      if (sectionsRaw is List) {
        for (var i = 0; i < sectionsRaw.length; i++) {
          final s = sectionsRaw[i] as Map<String, dynamic>;
          final listenUrl = s['listen_url'] as String?;
          if (listenUrl == null || listenUrl.isEmpty) continue;
          chapters.add(AudiobookChapter(
            title: (s['title'] as String? ?? '').trim().isEmpty
                ? 'Section ${i + 1}'
                : (s['title'] as String).trim(),
            listenUrl: listenUrl,
            durationSeconds: int.tryParse('${s['playtime'] ?? 0}') ?? 0,
            order: int.tryParse('${s['section_number'] ?? i + 1}') ?? i,
          ));
        }
      }
      // LibriVox's `sections` is only reliable in `extended=1` responses; if
      // it's missing/empty here there is no per-chapter stream to offer, so
      // audioChapters is simply left empty rather than falling back to the
      // book-level RSS/ZIP URLs, which aren't directly streamable as MP3.

      return LibriVoxAudiobookModel(
        id: json['id'].toString(),
        title: json['title'] as String? ?? 'Untitled',
        authorNames: authors,
        descriptionHtml: json['description'] as String? ?? '',
        totalTimeSeconds: json['totaltimesecs'] is int
            ? json['totaltimesecs'] as int
            : int.tryParse('${json['totaltimesecs'] ?? 0}') ?? 0,
        genres: genres,
        chapters: chapters,
      );
    } catch (e) {
      throw ParseException('Could not read this audiobook from LibriVox.', e);
    }
  }

  static String stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll('&nbsp;', ' ').trim();
  }

  Book toEntity() {
    final tags = <BookTag>[];
    for (var i = 0; i < genres.length && i < 3; i++) {
      final palette = _librivoxTagPalette[i % _librivoxTagPalette.length];
      tags.add(BookTag(text: genres[i], backgroundColorValue: palette[0], textColorValue: palette[1]));
    }

    return Book(
      id: 'librivox_$id',
      title: title,
      author: authorNames.isEmpty ? 'Unknown' : authorNames.join(', '),
      coverAsset: '',
      // LibriVox cover art is inconsistent; left null here so the repository
      // layer can fall back to a Google Books cover lookup by title/author.
      coverUrl: null,
      rating: 0.0,
      reviewCount: '0',
      length: '',
      audioDuration: Formatters.durationFromSeconds(totalTimeSeconds),
      language: 'EN',
      description: stripHtml(descriptionHtml),
      tags: tags,
      reviews: const [],
      sourceType: BookSourceType.librivox,
      remoteId: id,
      audioChapters: chapters,
    );
  }
}
