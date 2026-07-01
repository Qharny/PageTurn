import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../data/models/book_model.dart';
import 'mock_books.dart';
import '../common/widgets/book_cover.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  String _remainingTime = '12h 00m 00s';

  static const List<Book> _allBooks = [
    MockBooks.echoOfStarlight,
    MockBooks.midnightLibrary,
    MockBooks.becoming,
    MockBooks.circe,
    MockBooks.alchemist,
    MockBooks.projectHailMary,
    MockBooks.homegoing,
    MockBooks.thingsFallApart,
    MockBooks.thinkingFastSlow,
    MockBooks.educated,
    MockBooks.normalPeople,
    MockBooks.klaraSun,
    MockBooks.dune,
    MockBooks.atomicHabits,
    MockBooks.greatGatsby,
  ];

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemainingTime() {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    const twelveHoursMs = 12 * 60 * 60 * 1000;
    final nextBoundaryMs = ((nowMs ~/ twelveHoursMs) + 1) * twelveHoursMs;
    final difference = nextBoundaryMs - nowMs;
    
    if (difference <= 0) {
      _remainingTime = '00h 00m 00s';
    } else {
      final duration = Duration(milliseconds: difference);
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      setState(() {
        _remainingTime = '${hours}h ${minutes}m ${seconds}s';
      });
    }
  }

  Book _getBookOfTheDay() {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    const twelveHoursMs = 12 * 60 * 60 * 1000;
    final period = nowMs ~/ twelveHoursMs;
    final index = period % _allBooks.length;
    return _allBooks[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Stack(
        children: [
          // Speckled paper texture background
          const Positioned.fill(
            child: CustomPaint(painter: _SpeckPainter()),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildBookOfTheDay(context),
                  const SizedBox(height: 32),
                  _buildContinueReading(context),
                  const SizedBox(height: 32),
                  _buildTrendingNow(context),
                  const SizedBox(height: 32),
                  _buildAfricanSpotlight(context),
                  const SizedBox(height: 32),
                  _buildRecommendedForYou(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF5C3826), size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Text(
            'PageTurn',
            style: TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3826),
              letterSpacing: 0.2,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF5C3826), size: 26),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/profile_avatar.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookOfTheDay(BuildContext context) {
    final book = _getBookOfTheDay();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: BookCover(
                  coverAsset: book.coverAsset,
                  title: book.title,
                  fit: BoxFit.contain,
                  borderRadius: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BOOK OF THE DAY',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        _remainingTime,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C3826),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF7A6B63),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
                      },
                      child: const Text(
                        'Read Now',
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF5C3826),
                        side: const BorderSide(color: Color(0xFFE2DDD5), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Save for later',
                        style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReading(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Continue Reading',
              style: TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C3826),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'SEE ALL',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: [
              _buildContinueReadingCard(
                context,
                book: MockBooks.becoming,
                progress: 0.45,
                progressText: '120/300 pages',
              ),
              const SizedBox(width: 16),
              _buildContinueReadingCardPlaceholder(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context, {
    required Book book,
    required double progress,
    required String progressText,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: BookCover(
                coverAsset: book.coverAsset,
                title: book.title,
                fit: BoxFit.cover,
                borderRadius: 8,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontFamilyFallback: ['serif'],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF7A6B63),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      Text(
                        progressText,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFFF5EFEB),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueReadingCardPlaceholder() {
    return Container(
      width: 80,
      height: 94,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EBE3).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2DDD5), width: 1.5),
      ),
      child: const Center(
        child: Icon(Icons.add_rounded, color: Color(0xFF7A6B63), size: 24),
      ),
    );
  }

  Widget _buildTrendingNow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Trending Now',
              style: TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C3826),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.trending_up_rounded, color: Color(0xFF5C3826), size: 24),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCoverCard(
                context,
                book: MockBooks.echoOfStarlight,
              ),
              const SizedBox(width: 16),
              _buildBookCoverCard(
                context,
                book: MockBooks.circe,
              ),
              const SizedBox(width: 16),
              _buildBookCoverCard(
                context,
                book: MockBooks.alchemist,
              ),
              const SizedBox(width: 16),
              // Render Project Hail Mary as Custom Cover in Code!
              _buildCustomCoverCard(
                context,
                book: MockBooks.projectHailMary,
                startColor: const Color(0xFFFFECB3),
                endColor: const Color(0xFFFFB300),
                coverChild: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 28),
                    const SizedBox(height: 12),
                    Text(
                      'HAIL MARY'.replaceAll(' ', '\n'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookCoverCard(
    BuildContext context, {
    required Book book,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: BookCover(
                coverAsset: book.coverAsset,
                title: book.title,
                fit: BoxFit.cover,
                borderRadius: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C3826),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Color(0xFF7A6B63),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCoverCard(
    BuildContext context, {
    required Book book,
    required Color startColor,
    required Color endColor,
    required Widget coverChild,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(child: coverChild),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5C3826),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              book.author,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: Color(0xFF7A6B63),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAfricanSpotlight(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spotlight Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFBEFE3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFE67E22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.public_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'African Spotlight',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontFamilyFallback: ['serif'],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                  ),
                  Text(
                    'CURATED EXCELLENCE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE67E22),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Spotlight Books
        _buildSpotlightBookRow(
          context,
          book: MockBooks.homegoing,
          description: 'A novel of breathtaking sweep and emotional power that traces three...',
        ),
        const SizedBox(height: 16),
        _buildSpotlightBookRow(
          context,
          book: MockBooks.thingsFallApart,
          description: 'The quintessential African novel that depicts the clash between...',
        ),
      ],
    );
  }

  Widget _buildSpotlightBookRow(
    BuildContext context, {
    required Book book,
    required String description,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: BookCover(
                coverAsset: book.coverAsset,
                title: book.title,
                fit: BoxFit.cover,
                borderRadius: 8,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontFamilyFallback: ['serif'],
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF7A6B63),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedForYou(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended for You',
          style: TextStyle(
            fontFamily: 'Literata',
            fontFamilyFallback: ['serif'],
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C3826),
          ),
        ),
        const SizedBox(height: 16),
        // Grid constructed manually using Columns/Rows to avoid nested scroll issues
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCustomCoverCard(
                    context,
                    book: MockBooks.thinkingFastSlow,
                    startColor: const Color(0xFF78909C),
                    endColor: const Color(0xFF37474F),
                    coverChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 28),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'THINKING\nFAST & SLOW',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Literata',
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCustomCoverCard(
                    context,
                    book: MockBooks.educated,
                    startColor: const Color(0xFFECEFF1),
                    endColor: const Color(0xFFB0BEC5),
                    coverChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: -math.pi / 4,
                          child: const Icon(Icons.edit_rounded, color: Color(0xFF2C3E50), size: 28),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'EDUCATED',
                          style: TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildCustomCoverCard(
                    context,
                    book: MockBooks.normalPeople,
                    startColor: const Color(0xFFE8F5E9),
                    endColor: const Color(0xFF2E7D32),
                    coverChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.sailing_rounded, color: Colors.white, size: 28),
                        SizedBox(height: 10),
                        Text(
                          'NORMAL\nPEOPLE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCustomCoverCard(
                    context,
                    book: MockBooks.klaraSun,
                    startColor: const Color(0xFFFFFDE7),
                    endColor: const Color(0xFFFBC02D),
                    coverChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 28),
                        SizedBox(height: 10),
                        Text(
                          'KLARA & THE SUN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3826),
                            letterSpacing: 0.5,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _SpeckPainter extends CustomPainter {
  const _SpeckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..color = AppTheme.secondary.withValues(alpha: 0.05);

    const speckCount = 90;
    for (var i = 0; i < speckCount; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.1 + 0.3;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeckPainter oldDelegate) => false;
}
