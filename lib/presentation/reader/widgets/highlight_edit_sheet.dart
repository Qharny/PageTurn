import 'package:flutter/material.dart';

import '../../../core/theme/highlight_colors.dart';
import '../../../domain/entities/annotation.dart';
import '../../../theme.dart';

/// Sheet opened by tapping an existing painted highlight/note: change
/// color, view/edit the note, or delete. Every mutation keeps the sheet
/// open (rather than popping) if it fails, so the user doesn't silently
/// lose an in-progress edit.
class HighlightEditSheet extends StatefulWidget {
  final Annotation annotation;
  final Future<String?> Function(String colorKey) onChangeColor;
  final Future<String?> Function(String? noteText) onSaveNote;
  final Future<String?> Function() onDelete;

  const HighlightEditSheet({
    super.key,
    required this.annotation,
    required this.onChangeColor,
    required this.onSaveNote,
    required this.onDelete,
  });

  @override
  State<HighlightEditSheet> createState() => _HighlightEditSheetState();
}

class _HighlightEditSheetState extends State<HighlightEditSheet> {
  late final TextEditingController _noteController =
      TextEditingController(text: widget.annotation.noteText ?? '');
  late String? _colorKey = widget.annotation.colorKey;
  late bool _editingNote = (widget.annotation.noteText ?? '').isEmpty;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _applyColor(HighlightColorKey key) async {
    if (_colorKey == key.name) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onChangeColor(key.name);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      if (error == null) _colorKey = key.name;
    });
  }

  Future<void> _saveNote() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final text = _noteController.text.trim();
    final error = await widget.onSaveNote(text.isEmpty ? null : text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return; // keep the sheet open with the typed text intact
    }
    setState(() {
      _busy = false;
      _editingNote = text.isEmpty;
    });
  }

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onDelete();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final annotation = widget.annotation;
    final hasSavedNote = !_editingNote && (annotation.noteText ?? '').isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: const Color(0xFFDDD4C4), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            if ((annotation.selectedText ?? '').isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_colorKey != null ? HighlightColors.resolve(_colorKey!) : const Color(0xFFF7F1E8))
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '"${annotation.selectedText}"',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Inter', fontStyle: FontStyle.italic, fontSize: 13, color: Color(0xFF2C1810)),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Color',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7A6B63)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final key in HighlightColors.toolbarOrder)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: _busy ? null : () => _applyColor(key),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: HighlightColors.resolveKey(key),
                          border: Border.all(
                            color: _colorKey == key.name ? const Color(0xFF2C1810) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Note',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF7A6B63)),
            ),
            const SizedBox(height: 8),
            if (_editingNote)
              TextField(
                controller: _noteController,
                autofocus: (annotation.noteText ?? '').isEmpty,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Write your thought…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else if (hasSavedNote)
              GestureDetector(
                onTap: () => setState(() => _editingNote = true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF7F1E8), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    annotation.noteText!,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF2C1810)),
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.red)),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _delete,
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ),
                if (_editingNote) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Note'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
