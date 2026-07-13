import '../../core/errors/app_exception.dart';
import '../../domain/entities/annotation.dart';

/// Data-layer mapping for [Annotation]. Fields mirror the entity 1:1 (no
/// transformation needed, unlike the remote book models) — this class exists
/// to own JSON (de)serialization so the domain entity stays persistence-
/// agnostic, and so the same snake_case shape can serialize to Hive today
/// and a Supabase `annotations` row later without changing the entity.
class AnnotationModel {
  final Annotation entity;

  const AnnotationModel(this.entity);

  factory AnnotationModel.fromEntity(Annotation entity) => AnnotationModel(entity);

  Annotation toEntity() => entity;

  factory AnnotationModel.fromJson(Map<String, dynamic> json) {
    try {
      return AnnotationModel(Annotation(
        id: json['id'] as String,
        bookId: json['book_id'] as String,
        type: AnnotationType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AnnotationType.highlight,
        ),
        chapterId: json['chapter_id'] as String,
        anchor: json['anchor'] as String,
        selectedText: json['selected_text'] as String?,
        noteText: json['note_text'] as String?,
        colorKey: json['color_key'] as String?,
        progressPercent: (json['progress_percent'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      ));
    } catch (e) {
      throw ParseException('Could not read this annotation from local storage.', e);
    }
  }

  Map<String, dynamic> toJson() => {
        'id': entity.id,
        'book_id': entity.bookId,
        'type': entity.type.name,
        'chapter_id': entity.chapterId,
        'anchor': entity.anchor,
        'selected_text': entity.selectedText,
        'note_text': entity.noteText,
        'color_key': entity.colorKey,
        'progress_percent': entity.progressPercent,
        'created_at': entity.createdAt.toIso8601String(),
        'updated_at': entity.updatedAt.toIso8601String(),
      };
}
