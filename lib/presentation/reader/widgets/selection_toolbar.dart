import 'package:flutter/material.dart';

import '../../../core/theme/highlight_colors.dart';

/// Floating contextual toolbar shown while the reader has an active text
/// selection: 4 highlight color dots, a note action, and copy.
///
/// Positioning note: `SelectionArea`/`SelectableRegion` don't expose the
/// selection's on-screen geometry through their public API, so this can't
/// be precisely anchored "above/below the selection" the way a native text
/// editor would. It's pinned above the bottom chrome instead — a common,
/// robust mobile pattern (e.g. Notion mobile's selection bar) that also
/// trivially "respects screen edges" since its position never depends on
/// where the selection happens to be.
class SelectionToolbar extends StatelessWidget {
  final ValueChanged<HighlightColorKey> onColorTap;
  final VoidCallback onNoteTap;
  final VoidCallback onCopyTap;

  const SelectionToolbar({
    super.key,
    required this.onColorTap,
    required this.onNoteTap,
    required this.onCopyTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C1810),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final key in HighlightColors.toolbarOrder)
              GestureDetector(
                onTap: () => onColorTap(key),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HighlightColors.resolveKey(key),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            Container(width: 1, height: 22, color: Colors.white24),
            _ToolbarIconButton(icon: Icons.edit_note_rounded, tooltip: 'Add note', onTap: onNoteTap),
            _ToolbarIconButton(icon: Icons.copy_rounded, tooltip: 'Copy', onTap: onCopyTap),
          ],
        ),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}
