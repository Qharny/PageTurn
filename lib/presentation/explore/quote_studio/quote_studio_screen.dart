import 'package:flutter/material.dart';

import '../../../theme.dart';

/// Arguments for [QuoteStudioScreen] — a highlight's text plus the book it
/// came from.
class QuoteStudioArgs {
  static const String routeName = '/quote-studio';

  final String quoteText;
  final String bookTitle;
  final String bookAuthor;

  const QuoteStudioArgs({required this.quoteText, required this.bookTitle, required this.bookAuthor});
}

/// Quote Studio did not exist anywhere in this codebase before this task —
/// both `quote_studio_screen.dart` and `widgets/quote_template_picker.dart`
/// were empty, unreferenced stub files with no route (see the reader audit).
/// This is deliberately minimal: it proves the "send a highlight to Quote
/// Studio" navigation/argument-passing works end-to-end, with a simple
/// preview card. Template picking, styling, and image export are a
/// separate, larger feature this task does not build.
class QuoteStudioScreen extends StatelessWidget {
  final QuoteStudioArgs args;

  const QuoteStudioScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildQuoteCard(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Quote Studio',
            style: TextStyle(fontFamily: 'Literata', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5C3826)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF2C1810),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded, color: AppTheme.primary, size: 32),
          const SizedBox(height: 16),
          Text(
            args.quoteText.isEmpty ? 'Select a highlight to preview it here.' : args.quoteText,
            style: const TextStyle(fontFamily: 'Literata', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, height: 1.4),
          ),
          const SizedBox(height: 20),
          Text(
            '— ${args.bookAuthor}, "${args.bookTitle}"',
            style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFFD8C9BC)),
          ),
        ],
      ),
    );
  }
}
