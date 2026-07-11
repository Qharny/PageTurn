import 'package:flutter/material.dart';

import '../../../theme.dart';

class FontSettingsSheet extends StatelessWidget {
  final double fontSize;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const FontSettingsSheet({
    super.key,
    required this.fontSize,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Text Size',
              style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5C3826)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.text_decrease_rounded, color: AppTheme.primary),
                  onPressed: onDecrease,
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    fontSize.toStringAsFixed(0),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase_rounded, color: AppTheme.primary),
                  onPressed: onIncrease,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
