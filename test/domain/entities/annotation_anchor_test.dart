import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/domain/entities/annotation.dart';

void main() {
  group('AnnotationAnchor.serialize/parse round-trip', () {
    test('round-trips a typical anchor', () {
      const anchor = AnnotationAnchor(blockIndex: 4, startOffset: 12, endOffset: 37);
      final serialized = anchor.serialize();
      expect(serialized, '4:12:37');

      final parsed = AnnotationAnchor.parse(serialized);
      expect(parsed, anchor);
    });

    test('round-trips a zero-offset anchor (bookmark position)', () {
      const anchor = AnnotationAnchor(blockIndex: 0, startOffset: 0, endOffset: 0);
      expect(AnnotationAnchor.parse(anchor.serialize()), anchor);
    });

    test('round-trips large offsets', () {
      const anchor = AnnotationAnchor(blockIndex: 128, startOffset: 9999, endOffset: 10050);
      expect(AnnotationAnchor.parse(anchor.serialize()), anchor);
    });

    test('toString matches serialize', () {
      const anchor = AnnotationAnchor(blockIndex: 1, startOffset: 2, endOffset: 3);
      expect(anchor.toString(), anchor.serialize());
    });
  });

  group('AnnotationAnchor.parse malformed input', () {
    test('returns null for wrong segment count', () {
      expect(AnnotationAnchor.parse('1:2'), isNull);
      expect(AnnotationAnchor.parse('1:2:3:4'), isNull);
      expect(AnnotationAnchor.parse(''), isNull);
    });

    test('returns null for non-numeric segments', () {
      expect(AnnotationAnchor.parse('a:2:3'), isNull);
      expect(AnnotationAnchor.parse('1:b:3'), isNull);
      expect(AnnotationAnchor.parse('1:2:c'), isNull);
    });

    test('returns null for a CFI-shaped string (not this anchor format)', () {
      expect(AnnotationAnchor.parse('epubcfi(/6/14!/4/2/2/1:0)'), isNull);
    });

    test('returns null for negative offsets', () {
      expect(AnnotationAnchor.parse('-1:0:0'), isNull);
      expect(AnnotationAnchor.parse('0:-1:0'), isNull);
    });

    test('returns null when end is before start', () {
      expect(AnnotationAnchor.parse('0:10:5'), isNull);
    });
  });
}
