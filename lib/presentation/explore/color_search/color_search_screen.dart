import 'package:flutter/material.dart';

import '../../../data/models/book_model.dart';
import '../../../domain/entities/color_category.dart';
import '../../../routes.dart';
import '../../../theme.dart';
import '../../common/widgets/book_cover.dart';
import 'color_search_provider.dart';

/// Lets readers browse the catalog by cover color — pick a swatch, see the
/// real books whose cover art is dominated by that color. Colors are
/// computed from actual cover images (see `ColorSearchProvider`), not a
/// fabricated grouping.
class ColorSearchScreen extends StatefulWidget {
  const ColorSearchScreen({super.key});

  @override
  State<ColorSearchScreen> createState() => _ColorSearchScreenState();
}

class _ColorSearchScreenState extends State<ColorSearchScreen> {
  static const _ink = Color(0xFF1E1E1E);
  static const _mutedText = Color(0xFF7A6B63);
  static const _chocolateBrown = Color(0xFF5C3826);

  @override
  void initState() {
    super.initState();
    ColorSearchProvider.instance.loadIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: ColorSearchProvider.instance,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSwatchRow(),
                const SizedBox(height: 8),
                Expanded(child: _buildBody()),
              ],
            );
          },
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
              child: const Icon(Icons.arrow_back_rounded, color: _chocolateBrown, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse by Color',
                  style: TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                Text(
                  'Find your next read by cover aesthetic',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: _mutedText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatchRow() {
    final provider = ColorSearchProvider.instance;
    final counts = provider.countsByCategory;

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: ColorCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = ColorCategory.values[index];
          final count = counts[category] ?? 0;
          final isSelected = provider.selected == category;

          return GestureDetector(
            onTap: () => provider.selectCategory(category),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: category.swatch,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      width: isSelected ? 3 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isSelected ? 0.18 : 0.08),
                        blurRadius: isSelected ? 10 : 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: count > 0
                      ? Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: category == ColorCategory.white || category == ColorCategory.yellow
                                ? _ink
                                : Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  category.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primary : _mutedText,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final provider = ColorSearchProvider.instance;

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Inter', color: _mutedText, fontSize: 13)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: provider.refresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8C481A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Try Again', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final selected = provider.selected;
    if (selected == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.palette_outlined, size: 48, color: _mutedText),
              const SizedBox(height: 16),
              Text(
                provider.isLoading ? 'Analyzing covers…' : 'Pick a color to start browsing',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
              ),
            ],
          ),
        ),
      );
    }

    final books = provider.booksFor(selected);

    if (books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (provider.isLoading)
                const CircularProgressIndicator(color: AppTheme.primary)
              else
                const Icon(Icons.search_off_rounded, size: 40, color: _mutedText),
              const SizedBox(height: 16),
              Text(
                provider.isLoading
                    ? 'Still analyzing covers for ${selected.label.toLowerCase()}…'
                    : 'No ${selected.label.toLowerCase()} covers found yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) => _buildBookCard(context, books[index]),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.details, arguments: book),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BookCover(
                  coverAsset: book.coverAsset,
                  coverUrl: book.coverUrl,
                  title: book.title,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  borderRadius: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: _mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
