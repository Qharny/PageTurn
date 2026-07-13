import 'package:flutter/material.dart';

/// The 4 highlight/note colors offered in the reader's selection toolbar.
/// Annotations store this key ([Annotation.colorKey]), never a raw hex —
/// [HighlightColors.resolve] is the only place that turns a key into an
/// actual [Color], so the palette can change without touching stored data.
enum HighlightColorKey { amber, green, blue, rose }

/// Placeholder for a future reader theme system. Per the Phase 0 audit,
/// `core/theme/{light,dark,sepia}_theme.dart` are empty/unwired — there is
/// no reader theme switcher today, only the reader's one hardcoded cream
/// palette. [HighlightColors.resolve] takes this parameter now so a real
/// light/dark/sepia system can be wired in later without a breaking
/// signature change at every call site.
enum ReaderPalette { current }

/// Resolves [HighlightColorKey]s to actual paint colors. All four values
/// are opaque pastels chosen to stay readable under the reader's dark-brown
/// body text (`0xFF2C1810`) against its cream background (`0xFFFAF6F0`).
class HighlightColors {
  HighlightColors._();

  static const Map<HighlightColorKey, Color> _current = {
    HighlightColorKey.amber: Color(0xFFFDE68A),
    HighlightColorKey.green: Color(0xFFBBF7B0),
    HighlightColorKey.blue: Color(0xFFBFDBFE),
    HighlightColorKey.rose: Color(0xFFFBCFE8),
  };

  static Color resolveKey(HighlightColorKey key, {ReaderPalette palette = ReaderPalette.current}) {
    return _current[key]!;
  }

  /// Resolves a stored `colorKey` string (e.g. `"amber"`). Falls back to
  /// amber for an unrecognized/legacy key rather than throwing, since a
  /// color is never critical enough to crash the reader over.
  static Color resolve(String colorKey, {ReaderPalette palette = ReaderPalette.current}) {
    return resolveKey(parse(colorKey) ?? HighlightColorKey.amber, palette: palette);
  }

  /// `"#RRGGBB"` form for embedding in injected HTML
  /// (`style="background-color:#RRGGBB"`) — see the block-painting logic in
  /// `reader_provider.dart`.
  static String hexFor(String colorKey, {ReaderPalette palette = ReaderPalette.current}) {
    final color = resolve(colorKey, palette: palette);
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static HighlightColorKey? parse(String? raw) {
    if (raw == null) return null;
    for (final key in HighlightColorKey.values) {
      if (key.name == raw) return key;
    }
    return null;
  }

  static const List<HighlightColorKey> toolbarOrder = [
    HighlightColorKey.amber,
    HighlightColorKey.green,
    HighlightColorKey.blue,
    HighlightColorKey.rose,
  ];
}
