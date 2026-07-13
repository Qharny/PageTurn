import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/data/models/annotation_model.dart';
import 'package:pageturn/domain/entities/annotation.dart';

void main() {
  group('AnnotationModel JSON round-trip', () {
    test('round-trips a highlight with all fields set', () {
      final entity = Annotation(
        id: 'annotation_1',
        bookId: 'book_1',
        type: AnnotationType.highlight,
        chapterId: '3',
        anchor: const AnnotationAnchor(blockIndex: 2, startOffset: 10, endOffset: 25).serialize(),
        selectedText: 'a memorable phrase',
        colorKey: 'amber',
        progressPercent: 0.42,
        createdAt: DateTime.utc(2026, 1, 5, 10, 30),
        updatedAt: DateTime.utc(2026, 1, 5, 10, 31),
      );

      final json = AnnotationModel.fromEntity(entity).toJson();
      // Snake-cased keys, ready for a future Supabase row.
      expect(json.keys, containsAll([
        'id', 'book_id', 'type', 'chapter_id', 'anchor', 'selected_text',
        'note_text', 'color_key', 'progress_percent', 'created_at', 'updated_at',
      ]));
      expect(json['type'], 'highlight');

      final restored = AnnotationModel.fromJson(json).toEntity();
      expect(restored.id, entity.id);
      expect(restored.bookId, entity.bookId);
      expect(restored.type, entity.type);
      expect(restored.chapterId, entity.chapterId);
      expect(restored.anchor, entity.anchor);
      expect(restored.selectedText, entity.selectedText);
      expect(restored.noteText, entity.noteText);
      expect(restored.colorKey, entity.colorKey);
      expect(restored.progressPercent, entity.progressPercent);
      expect(restored.createdAt, entity.createdAt);
      expect(restored.updatedAt, entity.updatedAt);
    });

    test('round-trips a note (non-null noteText)', () {
      final entity = Annotation(
        id: 'annotation_2',
        bookId: 'book_1',
        type: AnnotationType.note,
        chapterId: '0',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 5).serialize(),
        selectedText: 'intro',
        noteText: 'Come back to this later.',
        colorKey: 'blue',
        progressPercent: 0.0,
        createdAt: DateTime.utc(2026, 2, 1),
        updatedAt: DateTime.utc(2026, 2, 1),
      );

      final restored = AnnotationModel.fromJson(AnnotationModel.fromEntity(entity).toJson()).toEntity();
      expect(restored.type, AnnotationType.note);
      expect(restored.noteText, 'Come back to this later.');
    });

    test('round-trips a bookmark (null selectedText/noteText/colorKey)', () {
      final entity = Annotation(
        id: 'annotation_3',
        bookId: 'book_1',
        type: AnnotationType.bookmark,
        chapterId: '7',
        anchor: const AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 0).serialize(),
        progressPercent: 0.88,
        createdAt: DateTime.utc(2026, 3, 1),
        updatedAt: DateTime.utc(2026, 3, 1),
      );

      final json = AnnotationModel.fromEntity(entity).toJson();
      expect(json['selected_text'], isNull);
      expect(json['note_text'], isNull);
      expect(json['color_key'], isNull);

      final restored = AnnotationModel.fromJson(json).toEntity();
      expect(restored.type, AnnotationType.bookmark);
      expect(restored.selectedText, isNull);
      expect(restored.noteText, isNull);
      expect(restored.colorKey, isNull);
      expect(restored.anchor, entity.anchor);
    });

    test('survives a Hive-shaped Map<dynamic, dynamic> (not Map<String, dynamic>)', () {
      // Hive returns boxes typed as Map<dynamic,dynamic> in practice; the
      // local source wraps reads in Map<String, dynamic>.from(...) before
      // handing to fromJson — this test exercises that exact shape.
      final entity = Annotation(
        id: 'annotation_4',
        bookId: 'book_1',
        type: AnnotationType.highlight,
        chapterId: '1',
        anchor: const AnnotationAnchor(blockIndex: 1, startOffset: 0, endOffset: 4).serialize(),
        selectedText: 'text',
        colorKey: 'green',
        progressPercent: 0.1,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
      );

      final Map<dynamic, dynamic> rawMap = Map<dynamic, dynamic>.from(
        AnnotationModel.fromEntity(entity).toJson(),
      );
      final restored = AnnotationModel.fromJson(Map<String, dynamic>.from(rawMap)).toEntity();
      expect(restored.id, entity.id);
      expect(restored.selectedText, 'text');
    });
  });
}
