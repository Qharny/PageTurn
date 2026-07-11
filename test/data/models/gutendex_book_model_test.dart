import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/data/models/gutendex_book_model.dart';
import 'package:pageturn/domain/entities/book.dart';

Map<String, dynamic> _loadFixture(String name) {
  final file = File('test/fixtures/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('GutendexBookModel.fromJson / toEntity (real captured response)', () {
    late Map<String, dynamic> aliceJson;

    setUpAll(() {
      final page = _loadFixture('gutendex_search_alice.json');
      aliceJson = (page['results'] as List).first as Map<String, dynamic>;
    });

    test('parses core fields from the real Gutendex payload', () {
      final model = GutendexBookModel.fromJson(aliceJson);

      expect(model.id, 11);
      expect(model.title, "Alice's Adventures in Wonderland");
      expect(model.rawAuthorNames, 'Carroll, Lewis');
      expect(model.languages, ['en']);
      expect(model.downloadCount, greaterThan(0));
      expect(model.summary, isNotNull);
      expect(model.summary, contains('Lewis Carroll'));
    });

    test('reformats "Last, First" author names to "First Last"', () {
      expect(GutendexBookModel.formatAuthorName('Carroll, Lewis'), 'Lewis Carroll');
      expect(GutendexBookModel.formatAuthorName('Doyle, Arthur Conan'), 'Arthur Conan Doyle');
      expect(GutendexBookModel.formatAuthorName('Homer'), 'Homer'); // no comma -> unchanged
      expect(GutendexBookModel.formatAuthorName(''), 'Unknown');
    });

    test('toEntity maps into a Book with gutenberg sourceType and a real epub/cover URL', () {
      final book = GutendexBookModel.fromJson(aliceJson).toEntity();

      expect(book.id, 'gutenberg_11');
      expect(book.sourceType, BookSourceType.gutenberg);
      expect(book.remoteId, '11');
      expect(book.author, 'Lewis Carroll');
      expect(book.fileFormat, 'epub');
      expect(book.downloadUrl, isNotNull);
      expect(book.downloadUrl, contains('.epub'));
      expect(book.coverUrl, isNotNull);
      expect(book.coverUrl, endsWith('.jpg'));
      expect(book.description, isNotEmpty);
      expect(book.tags, isNotEmpty);
      expect(book.tags.length, lessThanOrEqualTo(3));
    });

    test('falls back to an empty description when Gutendex has no summary', () {
      final withoutSummary = Map<String, dynamic>.from(aliceJson)..remove('summaries');
      final book = GutendexBookModel.fromJson(withoutSummary).toEntity();
      expect(book.description, isEmpty);
    });
  });

  group('GutendexBookModel.selectEpubUrl', () {
    test('picks the single application/epub+zip entry (the common real-world case)', () {
      final formats = {
        'text/html': 'https://www.gutenberg.org/ebooks/11.html.images',
        'application/epub+zip': 'https://www.gutenberg.org/ebooks/11.epub3.images',
        'image/jpeg': 'https://www.gutenberg.org/cache/epub/11/pg11.cover.medium.jpg',
      };
      expect(GutendexBookModel.selectEpubUrl(formats), 'https://www.gutenberg.org/ebooks/11.epub3.images');
    });

    test('prefers a non-"images" variant when multiple epub-flavoured keys exist', () {
      final formats = {
        'application/epub+zip': 'https://example.org/book-images.epub',
        'application/epub+zip;noimages': 'https://example.org/book.epub',
      };
      expect(GutendexBookModel.selectEpubUrl(formats), 'https://example.org/book.epub');
    });

    test('returns null when there is no epub format at all', () {
      final formats = {'text/html': 'https://example.org/book.html'};
      expect(GutendexBookModel.selectEpubUrl(formats), isNull);
    });

    test('selectCoverUrl reads the image/jpeg entry, or null if absent', () {
      expect(GutendexBookModel.selectCoverUrl({'image/jpeg': 'https://example.org/cover.jpg'}),
          'https://example.org/cover.jpg');
      expect(GutendexBookModel.selectCoverUrl({'text/html': 'https://example.org/book.html'}), isNull);
    });
  });

  test('single-book Gutendex detail response parses the same way as a search result', () {
    final json = _loadFixture('gutendex_book_11.json');
    final book = GutendexBookModel.fromJson(json).toEntity();
    expect(book.id, 'gutenberg_11');
    expect(book.title, "Alice's Adventures in Wonderland");
  });
}
