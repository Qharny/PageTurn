import 'package:flutter/material.dart';
import 'dart:ui';
import '../../data/models/book_model.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../home/mock_books.dart';
import '../reading_clubs/reading_club_provider.dart';
import '../reading_clubs/club_detail_screen.dart';

const Book mockGildedSpine = Book(
  id: 'gilded_spine',
  title: 'The Gilded Spine',
  author: 'Ariel S. Vance',
  coverAsset: 'assets/images/cover_gilded_spine.png',
  rating: 4.8,
  reviewCount: '2.5k',
  length: '384p',
  audioDuration: '10h 15m',
  language: 'Eng',
  description: 'In an age where gears and magic intertwine, a clockwork librarian discovers a legendary book hidden deep within the Grand Archives—one containing the blueprint to the universe itself.',
  tags: [
    BookTag(text: 'Steampunk', backgroundColorValue: 0xFFFDF0E9, textColorValue: 0xFFE67E22),
    BookTag(text: 'Fantasy', backgroundColorValue: 0xFFECEFF1, textColorValue: 0xFF455A64),
  ],
  reviews: [
    BookReview(
      reviewerName: 'Arthur P.',
      reviewerAvatarUrl: '',
      rating: 5,
      comment: 'An absolute masterpiece of steampunk worldbuilding. The characters feel alive!',
    ),
  ],
);

const Book mockShatteredEchoes = Book(
  id: 'shattered_echoes',
  title: 'Shattered Echoes',
  author: 'Julian Thorne',
  coverAsset: 'assets/images/cover_shattered_echoes.png',
  rating: 4.6,
  reviewCount: '1.8k',
  length: '312p',
  audioDuration: '9h 40m',
  language: 'Eng',
  description: 'A psychological thriller about an artist whose digital creations begin reflecting a parallel reality, starting with a cracked vase on his phone screen that appears in his real room.',
  tags: [
    BookTag(text: 'Thriller', backgroundColorValue: 0xFFFFEBEA, textColorValue: 0xFFC0392B),
    BookTag(text: 'Mystery', backgroundColorValue: 0xFFE3F2FD, textColorValue: 0xFF1E88E5),
  ],
  reviews: [
    BookReview(
      reviewerName: 'Nadia K.',
      reviewerAvatarUrl: '',
      rating: 4,
      comment: 'Creepy, atmospheric, and highly original. I couldn\'t put it down.',
    ),
  ],
);

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildTrendingLeaderboard(context),
            const SizedBox(height: 32),
            _buildReadingClubs(context),
            const SizedBox(height: 32),
            _buildGenreSpotlight(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF5C3826), size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        const Text(
          'Explore',
          style: TextStyle(
            fontFamily: 'Literata',
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3826),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/images/profile_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingLeaderboard(BuildContext context) {
    final trendingBooks = [
      mockGildedSpine,
      mockShatteredEchoes,
      MockBooks.echoOfStarlight,
      MockBooks.midnightLibrary,
      MockBooks.circe,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Trending\nLeaderboard',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                height: 1.1,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 330,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: trendingBooks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final book = trendingBooks[index];
              final rank = index + 1;
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.details, arguments: book);
                },
                child: SizedBox(
                  width: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                book.coverAsset,
                                fit: BoxFit.cover,
                                width: 170,
                                height: 240,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.book, size: 40),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Rank Badge
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: rank == 1
                                    ? AppTheme.primary
                                    : Colors.white.withValues(alpha: 0.95),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: rank == 1 ? Colors.white : const Color(0xFF1E1E1E),
                                ),
                              ),
                            ),
                          ),
                          // Trending Pill
                          if (rank == 1)
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.trending_up_rounded,
                                          size: 12,
                                          color: Color(0xFF8C481A),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'TRENDING',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8C481A),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Literata',
                          fontSize: 16,
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
                          fontSize: 12,
                          color: Color(0xFF7A6B63),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatMemberCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k members';
    }
    return '$count members';
  }

  Widget _buildReadingClubs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reading Clubs',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.readingClubs),
              child: const Text('See All', style: TextStyle(fontFamily: 'Inter', color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListenableBuilder(
          listenable: ReadingClubProvider.instance,
          builder: (context, child) {
            final clubs = ReadingClubProvider.instance.clubs.take(2).toList();
            return Column(
              children: clubs.map((club) {
                final isJoined = ReadingClubProvider.instance.isJoined(club.id);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReadingClubDetailScreen(club: club),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: club.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            club.icon,
                            color: club.iconColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                club.name,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E1E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatMemberCount(club.memberCount),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF7A6B63),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            ReadingClubProvider.instance.toggleJoin(club.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isJoined ? "Left ${club.name}" : "Joined ${club.name}! 🎉",
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isJoined ? const Color(0xFFF2ECE4) : const Color(0xFF8C481A),
                            foregroundColor: isJoined ? const Color(0xFF8C481A) : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isJoined ? const BorderSide(color: Color(0xFFD8D3C8), width: 1) : BorderSide.none,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            isJoined ? 'Joined' : 'Join',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGenreSpotlight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Genre Spotlight',
          style: TextStyle(
            fontFamily: 'Literata',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGenreCard(
                title: 'Sci-Fi',
                badgeText: 'TRENDING NOW',
                imageAsset: 'assets/images/genre_scifi.png',
                height: 220,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGenreCard(
                title: 'Historical',
                badgeText: 'CURATED',
                imageAsset: 'assets/images/genre_historical.png',
                height: 220,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWideGenreCard(
          title: 'Mystery & Noir',
          subtitle: 'Discover the hidden secrets...',
          imageAsset: 'assets/images/genre_mystery.png',
          height: 150,
        ),
      ],
    );
  }

  Widget _buildGenreCard({
    required String title,
    required String badgeText,
    required String imageAsset,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.blueGrey);
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideGenreCard({
    required String title,
    required String subtitle,
    required String imageAsset,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.brown[300]);
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8C481A),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


