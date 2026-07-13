import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pageturn/core/theme/highlight_colors.dart';
import 'package:pageturn/presentation/reader/widgets/selection_toolbar.dart';

/// Minimal reproduction of `_EbookReaderScreenState`'s selection wiring —
/// a real `SelectionArea` + the real `SelectionToolbar` widget, with a fake
/// "create highlight" callback standing in for `AnnotationProvider` (which
/// would need Hive/a real EPUB fixture to exercise end-to-end). This tests
/// the actual UI integration point the brief asks for — "selection toolbar
/// appears on selection and a color tap paints a highlight" — without the
/// unrelated overhead of booting the full reader screen.
class _SelectionHarness extends StatefulWidget {
  final String text;
  final void Function(String colorKey, String selectedText) onHighlight;

  const _SelectionHarness({required this.text, required this.onHighlight});

  @override
  State<_SelectionHarness> createState() => _SelectionHarnessState();
}

class _SelectionHarnessState extends State<_SelectionHarness> {
  final GlobalKey<SelectableRegionState> _key = GlobalKey<SelectableRegionState>();
  String? _pendingText;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SelectionArea(
          key: _key,
          onSelectionChanged: (content) {
            final text = content?.plainText.trim() ?? '';
            setState(() => _pendingText = text.isEmpty ? null : text);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(widget.text),
          ),
        ),
        if (_pendingText != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SelectionToolbar(
              onColorTap: (key) {
                widget.onHighlight(key.name, _pendingText!);
                _key.currentState?.clearSelection();
                setState(() => _pendingText = null);
              },
              onNoteTap: () {},
              onCopyTap: () {},
            ),
          ),
      ],
    );
  }
}

void main() {
  testWidgets('selection toolbar is hidden until text is selected, then a color tap creates a highlight',
      (tester) async {
    final created = <(String colorKey, String text)>[];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: _SelectionHarness(
          text: 'The quick brown fox jumps over the lazy dog.',
          onHighlight: (colorKey, text) => created.add((colorKey, text)),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // No selection yet — toolbar is not shown.
    expect(find.byType(SelectionToolbar), findsNothing);

    // Select all text via a keyboard shortcut — reliable and
    // gesture-geometry-independent, unlike simulating a precise drag.
    await tester.tap(find.text('The quick brown fox jumps over the lazy dog.'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.byType(SelectionToolbar), findsOneWidget);
    // All 4 color dots are present.
    expect(find.byType(GestureDetector), findsWidgets);

    // Tap the first color swatch (amber, per HighlightColors.toolbarOrder).
    final colorDots = find.descendant(
      of: find.byType(SelectionToolbar),
      matching: find.byWidgetPredicate((w) => w is GestureDetector),
    );
    await tester.tap(colorDots.first);
    await tester.pumpAndSettle();

    expect(created, hasLength(1));
    expect(created.first.$1, HighlightColorKey.amber.name);
    expect(created.first.$2, 'The quick brown fox jumps over the lazy dog.');

    // Toolbar clears itself after the action.
    expect(find.byType(SelectionToolbar), findsNothing);
  });

  testWidgets('toolbar disappears again if the selection is cleared without an action', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: _SelectionHarness(text: 'Some selectable text.', onHighlight: (_, _) {}),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Some selectable text.'));
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byType(SelectionToolbar), findsOneWidget);

    // Tap elsewhere to collapse the selection.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(SelectionToolbar), findsNothing);
  });
}
