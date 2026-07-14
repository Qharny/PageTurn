import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../data/models/book_model.dart';
import '../../data/repositories/repository_locator.dart';
import '../../core/errors/app_exception.dart';
import '../common/widgets/book_cover.dart';
import '../library/library_provider.dart';
import '../profile/profile_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  String _remainingTime = '12h 00m 00s';

  List<Book> _popular = [];
  List<Book> _spotlight = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final popular = await RepositoryLocator.bookRepository.popularBooks();
      List<Book> spotlight = [];
      try {
        spotlight = await RepositoryLocator.bookRepository.browseByTopic('african');
      } on AppException {
        spotlight = [];
      }
      debugPrint('TTS_DEBUG_HOME popular=${popular.length} spotlight=${spotlight.length}');
      if (!mounted) return;
      setState(() {
        _popular = popular;
        _spotlight = spotlight;
        _loading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      debugPrint('TTS_DEBUG_HOME unexpected error: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong loading your home feed.';
        _loading = false;
      });
    }
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

  Book? _getBookOfTheDay() {
    if (_popular.isEmpty) return null;
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    const twelveHoursMs = 12 * 60 * 60 * 1000;
    final period = nowMs ~/ twelveHoursMs;
    final index = period % _popular.length;
    return _popular[index];
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
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13)),
                              const SizedBox(height: 12),
                              TextButton(onPressed: _loadHomeData, child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
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
              ListenableBuilder(
                listenable: ProfileProvider.instance,
                builder: (context, _) {
                  final avatarUrl = ProfileProvider.instance.avatarUrl;
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: avatarUrl != null
                            ? NetworkImage(avatarUrl) as ImageProvider
                            : const AssetImage('assets/images/profile_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookOfTheDay(BuildContext context) {
    final book = _getBookOfTheDay();
    if (book == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) => _buildBookOfTheDayCard(context, book),
    );
  }

  Widget _buildBookOfTheDayCard(BuildContext context, Book book) {
    final isSaved = LibraryProvider.instance.isBookmarked(book.id);
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
                  coverUrl: book.coverUrl,
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
              book.description.isNotEmpty ? book.description : 'A free public-domain classic from Project Gutenberg.',
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
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isSaved ? AppTheme.primary : const Color(0xFF5C3826),
                        side: BorderSide(
                          color: isSaved ? AppTheme.primary : const Color(0xFFE2DDD5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        LibraryProvider.instance.toggleBookmark(book);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSaved ? 'Removed from your library' : 'Saved for later'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isSaved ? 'Saved' : 'Save for later',
                        style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
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
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        final readingBooks = LibraryProvider.instance.books
            .where((b) => b.progress != null && b.progress! > 0 && b.isFinished != true)
            .toList();

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
                if (readingBooks.isNotEmpty)
                  TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.continueReading),
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
                  if (readingBooks.isEmpty) ...[
                    _buildNoBooksInProgressCard(context),
                  ] else ...[
                    ...readingBooks.map((book) {
                      final pagesText = book.length.replaceAll('p', '');
                      final totalPages = int.tryParse(pagesText) ?? 300;
                      final readPages = (totalPages * (book.progress ?? 0)).toInt();
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildContinueReadingCard(
                          context,
                          book: book,
                          progress: book.progress ?? 0.0,
                          progressText: '$readPages/$totalPages pages',
                        ),
                      );
                    }),
                    _buildContinueReadingCardPlaceholder(),
                  ],
                ],
              ),
            ),
          ],
        );
      },
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
                coverUrl: book.coverUrl,
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

  Widget _buildNoBooksInProgressCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.ebooks),
      child: Container(
        width: 270,
        height: 94,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EBE3).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2DDD5), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.auto_stories_rounded, color: Color(0xFF7A6B63), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Nothing in progress yet',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to browse the catalog',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: const Color(0xFF7A6B63).withValues(alpha: 0.8),
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
              for (final book in _popular.take(4)) ...[
                _buildBookCoverCard(context, book: book),
                const SizedBox(width: 16),
              ],
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
                coverUrl: book.coverUrl,
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

  Widget _buildAfricanSpotlight(BuildContext context) {
    if (_spotlight.isEmpty) return const SizedBox.shrink();
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
        for (final book in _spotlight.take(2)) ...[
          _buildSpotlightBookRow(
            context,
            book: book,
            description: book.description.isNotEmpty
                ? book.description
                : 'A celebrated work of African literature, free to read.',
          ),
          const SizedBox(height: 16),
        ],
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
                coverUrl: book.coverUrl,
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
    final recommended = _popular.skip(4).take(4).toList();
    if (recommended.isEmpty) return const SizedBox.shrink();
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
        for (var i = 0; i < recommended.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildGridCoverCard(context, book: recommended[i])),
              if (i + 1 < recommended.length) ...[
                const SizedBox(width: 16),
                Expanded(child: _buildGridCoverCard(context, book: recommended[i + 1])),
              ] else
                const Spacer(),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildGridCoverCard(BuildContext context, {required Book book}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.72,
            child: Container(
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
                coverUrl: book.coverUrl,
                title: book.title,
                fit: BoxFit.cover,
                borderRadius: 12,
              ),
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
