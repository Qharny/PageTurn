import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../entities/color_category.dart';

/// Decodes [imageBytes] (a book cover) and buckets its dominant color into
/// a [ColorCategory] via a simple hue/lightness/saturation histogram —
/// downscales during decode so this stays cheap even for large covers.
/// Returns null if the image can't be decoded.
Future<ColorCategory?> extractDominantColorCategory(Uint8List imageBytes) async {
  ui.Image? image;
  try {
    final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: 48);
    final frame = await codec.getNextFrame();
    image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    final pixels = byteData.buffer.asUint8List();
    final counts = <ColorCategory, int>{};

    for (var i = 0; i + 3 < pixels.length; i += 4) {
      final alpha = pixels[i + 3];
      if (alpha < 128) continue; // skip transparent pixels

      final category = _categorize(pixels[i], pixels[i + 1], pixels[i + 2]);
      counts[category] = (counts[category] ?? 0) + 1;
    }

    if (counts.isEmpty) return null;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  } catch (_) {
    return null;
  } finally {
    image?.dispose();
  }
}

ColorCategory _categorize(int r, int g, int b) {
  final hsl = HSLColor.fromColor(Color.fromARGB(255, r, g, b));
  final lightness = hsl.lightness;
  final saturation = hsl.saturation;
  final hue = hsl.hue;

  if (saturation < 0.12) {
    if (lightness > 0.88) return ColorCategory.white;
    if (lightness < 0.15) return ColorCategory.black;
    return ColorCategory.gray;
  }

  // Dark, muted warm hues read as "brown" (book covers lean heavily on this)
  // rather than red/orange.
  final isWarmHue = hue < 45 || hue >= 345;
  if (isWarmHue && lightness < 0.45) return ColorCategory.brown;

  if (hue < 15 || hue >= 345) return ColorCategory.red;
  if (hue < 45) return ColorCategory.orange;
  if (hue < 70) return ColorCategory.yellow;
  if (hue < 165) return ColorCategory.green;
  if (hue < 195) return ColorCategory.teal;
  if (hue < 255) return ColorCategory.blue;
  if (hue < 290) return ColorCategory.purple;
  return ColorCategory.pink;
}
