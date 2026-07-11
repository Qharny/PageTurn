import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/data/models/librivox_audiobook_model.dart';
import 'package:pageturn/domain/entities/book.dart';

Map<String, dynamic> _loadFixtureBook(int index) {
  final file = File('test/fixtures/librivox_extended.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return (json['books'] as List)[index] as Map<String, dynamic>;
}

void main() {
  group('LibriVoxAudiobookModel.fromJson (real captured extended response)', () {
    test('parses title, authors, duration, genres, and sections', () {
      final model = LibriVoxAudiobookModel.fromJson(_loadFixtureBook(0));

      expect(model.id, '47');
      expect(model.title, 'Count of Monte Cristo');
      expect(model.authorNames, ['Alexandre Dumas']);
      expect(model.totalTimeSeconds, 178995);
      expect(model.genres, contains('Literary Fiction'));
      expect(model.chapters, isNotEmpty);
      expect(model.chapters.first.listenUrl, startsWith('https://'));
      expect(model.chapters.first.durationSeconds, greaterThan(0));
    });

    test('strips HTML from the description', () {
      final model = LibriVoxAudiobookModel.fromJson(_loadFixtureBook(0));
      expect(model.descriptionHtml, contains('<i>'));
      expect(LibriVoxAudiobookModel.stripHtml(model.descriptionHtml), isNot(contains('<i>')));
    });

    test('toEntity maps into a Book with librivox sourceType and populated audioChapters', () {
      final book = LibriVoxAudiobookModel.fromJson(_loadFixtureBook(0)).toEntity();

      expect(book.id, 'librivox_47');
      expect(book.sourceType, BookSourceType.librivox);
      expect(book.remoteId, '47');
      expect(book.author, 'Alexandre Dumas');
      expect(book.audioDuration, '49h 43m');
      expect(book.audioChapters, isNotNull);
      expect(book.audioChapters, isNotEmpty);
      // LibriVox cover art is inconsistent -- left null for the repository
      // layer to fill in via Google Books enrichment.
      expect(book.coverUrl, isNull);
    });

    test('handles a response with empty/missing sections without throwing', () {
      final json = Map<String, dynamic>.from(_loadFixtureBook(0));
      json['sections'] = <dynamic>[];
      final model = LibriVoxAudiobookModel.fromJson(json);
      expect(model.chapters, isEmpty);
    });

    test('handles a response where sections is missing entirely (defensive parsing)', () {
      final json = Map<String, dynamic>.from(_loadFixtureBook(0));
      json.remove('sections');
      final model = LibriVoxAudiobookModel.fromJson(json);
      expect(model.chapters, isEmpty);
    });
  });
}
