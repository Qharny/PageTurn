import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../data/models/book_model.dart';
import '../home/mock_books.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  bool _isGridView = true;
  String _searchQuery = '';

  final List<String> _tabs = ['All', 'Reading', 'Finished', 'Want to Read'];

  final List<Book> _libraryBooks = [
    MockBooks.midnightLibrary,
    MockBooks.atomicHabits,
    MockBooks.dune,
    MockBooks.educated,
    MockBooks.greatGatsby,
  ];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Book> _getBooksForTab(int tabIndex) {
    var list = _libraryBooks;

    // Filter by Tab
    if (tabIndex == 1) {
      // Reading
      list = list.where((b) => b.progress != null && b.progress! > 0).toList();
    } else if (tabIndex == 2) {
      // Finished
      list = list.where((b) => b.isFinished == true).toList();
    } else if (tabIndex == 3) {
      // Want to Read
      list = list.where((b) => b.isFinished != true && (b.progress == null || b.progress == 0)).toList();
    }

    // Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((b) =>
              b.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              b.author.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return list;
  }

  Widget _buildTabPage(int tabIndex) {
    final books = _getBooksForTab(tabIndex);
    return books.isEmpty
        ? _buildEmptyState()
        : SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            physics: const BouncingScrollPhysics(),
            child: _isGridView
                ? _buildGridView(books)
                : _buildListView(books),
          );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 0,
                  height: 0,
                  child: Text(
                    'Manage your saved, reading, and completed books.',
                    style: TextStyle(fontSize: 0.01, color: Colors.transparent),
                  ),
                ),
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: _buildSearchBar(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildLayoutToggles(),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildTabsBar(),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(_tabs.length, (index) => _buildTabPage(index)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'library_fab',
        onPressed: () {},
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 3,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE9),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF9C8F84), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF5C3826),
              ),
              decoration: const InputDecoration(
                hintText: 'Search your library...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Color(0xFF9C8F84),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutToggles() {
    const activeColor = Color(0xFFD35400);
    const inactiveColor = Color(0xFF9C8F84);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE9),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isGridView = true),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isGridView ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: _isGridView ? Colors.white : inactiveColor,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _isGridView = false),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: !_isGridView ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_list_rounded,
                size: 20,
                color: !_isGridView ? Colors.white : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsBar() {
    return SizedBox(
      height: 38,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF5C3826),
        unselectedLabelColor: const Color(0xFF9C8F84),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        indicator: const _FixedUnderlineTabIndicator(
          borderSide: BorderSide(width: 3.0, color: Color(0xFFD35400)),
          width: 24.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        tabs: _tabs.map((tab) => Tab(text: tab, height: 38)).toList(),
      ),
    );
  }

  Widget _buildGridView(List<Book> books) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.58,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildGridBookCard(book);
      },
    );
  }

  Widget _buildGridBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Shadow & Border Radius
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: book.coverAsset.isNotEmpty
                        ? Image.asset(book.coverAsset, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                        : Container(
                            color: const Color(0xFF37474F),
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: Text(
                                book.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ),
                  ),
                ),
                // Progress Bar overlay
                if (book.progress != null && book.progress! > 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        backgroundColor: Colors.black26,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD35400)),
                        minHeight: 5,
                      ),
                    ),
                  ),
                // Finished Checkmark Badge overlay
                if (book.isFinished == true)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1.5)),
                      ),
                      padding: const EdgeInsets.all(3),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            style: const TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 13.5,
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
              color: Color(0xFF9C8F84),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Book> books) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildListBookCard(book);
      },
    );
  }

  Widget _buildListBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
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
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: book.coverAsset.isNotEmpty
                        ? Image.asset(book.coverAsset, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                        : Container(
                            color: const Color(0xFF37474F),
                            child: Center(
                              child: Text(
                                book.title.substring(0, 1),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                  ),
                  if (book.progress != null && book.progress! > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        child: LinearProgressIndicator(
                          value: book.progress,
                          backgroundColor: Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD35400)),
                          minHeight: 4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontFamilyFallback: ['serif'],
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF9C8F84),
                    ),
                  ),
                ],
              ),
            ),
            if (book.isFinished == true)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C8F84)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_outline_rounded, size: 48, color: Color(0xFF9C8F84)),
          const SizedBox(height: 16),
          const Text(
            'No books found',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C3826),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? 'Try a different search query' : 'Your books in this tab will appear here',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Color(0xFF9C8F84),
            ),
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

class _FixedUnderlineTabIndicator extends Decoration {
  final BorderSide borderSide;
  final double width;

  const _FixedUnderlineTabIndicator({
    required this.borderSide,
    required this.width,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FixedUnderlinePainter(this, onChanged);
  }
}

class _FixedUnderlinePainter extends BoxPainter {
  final _FixedUnderlineTabIndicator decoration;

  _FixedUnderlinePainter(this.decoration, VoidCallback? onChanged) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = offset & configuration.size!;
    final paint = decoration.borderSide.toPaint()..strokeCap = StrokeCap.round;
    final double xCenter = rect.left + rect.width / 2;
    final double yPos = rect.bottom - decoration.borderSide.width / 2 - 3.0;
    canvas.drawLine(
      Offset(xCenter - decoration.width / 2, yPos),
      Offset(xCenter + decoration.width / 2, yPos),
      paint,
    );
  }
}
