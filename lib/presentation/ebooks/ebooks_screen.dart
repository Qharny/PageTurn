import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../home/mock_books.dart';
import '../../routes.dart';

class EBooksScreen extends StatefulWidget {
  const EBooksScreen({super.key});

  @override
  State<EBooksScreen> createState() => _EBooksScreenState();
}

class _EBooksScreenState extends State<EBooksScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['All', 'Fiction', 'Non-Fiction', 'Biography'];

  final List<Book> _ebooks = [
    MockBooks.midnightLibrary,
    MockBooks.circe,
    MockBooks.becoming,
    MockBooks.dune,
    MockBooks.greatGatsby,
    MockBooks.thingsFallApart,
    MockBooks.alchemist,
    MockBooks.atomicHabits,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildCategoryTabs(),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _ebooks.length,
                itemBuilder: (context, index) => _buildBookCard(context, _ebooks[index]),
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
          const Expanded(
            child: Text(
              'E-Books',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C3826),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
            ),
            child: const Icon(Icons.search_rounded, color: Color(0xFF5C3826), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF8C481A) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF8C481A) : const Color(0xFFF2ECE4),
                  width: 1.2,
                ),
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF5C3826),
                ),
              ),
            ),
          );
        },
      ),
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
                child: Image.asset(
                  book.coverAsset,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFE0D4C8),
                    child: const Icon(Icons.book, size: 40, color: Color(0xFF7A6B63)),
                  ),
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
              color: Color(0xFF1E1E1E),
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
              color: Color(0xFF7A6B63),
            ),
          ),
        ],
      ),
    );
  }
}
