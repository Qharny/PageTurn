import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/data/models/google_book_volume_model.dart';
import 'package:pageturn/domain/entities/book.dart';

List<dynamic> _loadFixtureItems() {
  final file = File('test/fixtures/google_books_search_dune.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json['items'] as List<dynamic>;
}

void main() {
  group('GoogleBookVolumeModel.fromJson', () {
    test('parses a full volume, rewriting the http cover URL to https', () {
      final items = _loadFixtureItems();
      final model = GoogleBookVolumeModel.fromJson(items[0] as Map<String, dynamic>);

      expect(model.id, 'B7GsvHYVQrUC');
      expect(model.title, 'Dune');
      expect(model.authors, ['Frank Herbert']);
      expect(model.pageCount, 412);
      expect(model.isbn13, '9780441172719');
      expect(model.isbn10, '0441172717');
      expect(model.averageRating, 4.5);
      expect(model.ratingsCount, 1832);
      expect(model.thumbnailUrl, startsWith('https://'));
      expect(model.thumbnailUrl, isNot(startsWith('http://')));
    });

    test('handles a volume missing optional fields (rating, subtitle) without throwing', () {
      final items = _loadFixtureItems();
      final model = GoogleBookVolumeModel.fromJson(items[1] as Map<String, dynamic>);

      expect(model.title, 'Dune Messiah');
      expect(model.averageRating, isNull);
      expect(model.ratingsCount, isNull);
      expect(model.isbn10, isNull);
      expect(model.isbn13, '9780441172924');
    });

    test('toEntity maps into a metadata-only Book with googleBooks sourceType', () {
      final items = _loadFixtureItems();
      final book = GoogleBookVolumeModel.fromJson(items[0] as Map<String, dynamic>).toEntity();

      expect(book.id, 'googlebooks_B7GsvHYVQrUC');
      expect(book.sourceType, BookSourceType.googleBooks);
      expect(book.downloadUrl, isNull); // quick-add entries carry no content
      expect(book.length, '412p');
      expect(book.isbn, '9780441172719');
    });
  });

  group('GoogleBookVolumeModel.rewriteToHttps', () {
    test('rewrites http to https', () {
      expect(GoogleBookVolumeModel.rewriteToHttps('http://books.google.com/x.jpg'), 'https://books.google.com/x.jpg');
    });

    test('leaves an already-https URL untouched', () {
      expect(GoogleBookVolumeModel.rewriteToHttps('https://books.google.com/x.jpg'), 'https://books.google.com/x.jpg');
    });

    test('returns null for null input', () {
      expect(GoogleBookVolumeModel.rewriteToHttps(null), isNull);
    });
  });
}
