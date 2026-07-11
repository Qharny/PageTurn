import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/repository_locator.dart';
import '../../core/errors/app_exception.dart';
import '../../routes.dart';
import '../common/widgets/book_cover.dart';

/// Full "View All" page for the Explore screen's Trending Leaderboard.
/// Shows the complete ranked list of trending books.
class TrendingLeaderboardScreen extends StatefulWidget {
  const TrendingLeaderboardScreen({super.key});

  @override
  State<TrendingLeaderboardScreen> createState() => _TrendingLeaderboardScreenState();
}

class _TrendingLeaderboardScreenState extends State<TrendingLeaderboardScreen> {
  static const _ink = Color(0xFF1E1E1E);
  static const _mutedText = Color(0xFF7A6B63);
  static const _chocolateBrown = Color(0xFF5C3826);

  List<Book> _books = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final books = await RepositoryLocator.bookRepository.popularBooks();
      if (!mounted) return;
      setState(() {
        _books = books.take(10).toList();
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', color: _mutedText, fontSize: 13)),
        ),
      );
    }
    if (_books.isEmpty) {
      return const Center(
        child: Text('No trending books right now.',
            style: TextStyle(fontFamily: 'Inter', color: _mutedText, fontSize: 13)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: _books.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildRankRow(context, _books[index], index + 1),
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
              child: const Icon(Icons.arrow_back_rounded,
                  color: _chocolateBrown, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Leaderboard',
                  style: TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                Text(
                  'The most-read books right now',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: _mutedText,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.trending_up_rounded, color: AppTheme.primary, size: 24),
        ],
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFE0A526); // gold
      case 2:
        return const Color(0xFF9FA8B0); // silver
      case 3:
        return const Color(0xFFCD7F45); // bronze
      default:
        return const Color(0xFFBFB4A8);
    }
  }

  Widget _buildRankRow(BuildContext context, Book book, int rank) {
    final isTopThree = rank <= 3;
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.details, arguments: book),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _rankColor(rank).withValues(alpha: isTopThree ? 1.0 : 0.15),
              ),
              alignment: Alignment.center,
              child: Text(
                '$rank',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isTopThree ? Colors.white : _mutedText,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Cover
            SizedBox(
              width: 52,
              height: 74,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BookCover(
                  coverAsset: book.coverAsset,
                  coverUrl: book.coverUrl,
                  title: book.title,
                  fit: BoxFit.cover,
                  borderRadius: 0,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Title / author / rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 15,
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
                      fontSize: 12,
                      color: _mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFF4A836)),
                      const SizedBox(width: 3),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _chocolateBrown,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${book.reviewCount})',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFBFB4A8)),
          ],
        ),
      ),
    );
  }
}
