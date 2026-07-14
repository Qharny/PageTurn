import 'package:flutter/material.dart';

/// A curated palette a book cover's dominant color is bucketed into for
/// "Browse by Color". Fixed set rather than raw RGB so books cleanly group
/// together instead of every cover forming its own one-item bucket.
enum ColorCategory {
  red,
  orange,
  yellow,
  green,
  teal,
  blue,
  purple,
  pink,
  brown,
  black,
  white,
  gray;

  String get label => switch (this) {
        ColorCategory.red => 'Red',
        ColorCategory.orange => 'Orange',
        ColorCategory.yellow => 'Yellow',
        ColorCategory.green => 'Green',
        ColorCategory.teal => 'Teal',
        ColorCategory.blue => 'Blue',
        ColorCategory.purple => 'Purple',
        ColorCategory.pink => 'Pink',
        ColorCategory.brown => 'Brown',
        ColorCategory.black => 'Black',
        ColorCategory.white => 'White',
        ColorCategory.gray => 'Gray',
      };

  /// Representative swatch color shown in the picker UI.
  Color get swatch => switch (this) {
        ColorCategory.red => const Color(0xFFE53935),
        ColorCategory.orange => const Color(0xFFFB8C00),
        ColorCategory.yellow => const Color(0xFFFDD835),
        ColorCategory.green => const Color(0xFF43A047),
        ColorCategory.teal => const Color(0xFF00897B),
        ColorCategory.blue => const Color(0xFF1E88E5),
        ColorCategory.purple => const Color(0xFF8E24AA),
        ColorCategory.pink => const Color(0xFFD81B60),
        ColorCategory.brown => const Color(0xFF6D4C33),
        ColorCategory.black => const Color(0xFF1A1A1A),
        ColorCategory.white => const Color(0xFFFAFAFA),
        ColorCategory.gray => const Color(0xFF9E9E9E),
      };

  static ColorCategory? fromName(String name) {
    for (final category in ColorCategory.values) {
      if (category.name == name) return category;
    }
    return null;
  }
}
