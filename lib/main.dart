import 'package:flutter/material.dart';
import 'dart:ui';
import 'theme.dart';
import 'routes.dart';
import 'presentation/common/custom_drawer.dart';

import 'presentation/home/home_screen.dart';
import 'presentation/library/library_screen.dart';
import 'presentation/explore/explore_screen.dart';
import 'presentation/profile/profile_screen.dart';
import 'presentation/library/library_provider.dart';
import 'presentation/reading_clubs/reading_club_provider.dart';
import 'data/models/book_model.dart';
import 'data/repositories/repository_locator.dart';
import 'core/errors/app_exception.dart';
import 'presentation/home/mock_books.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RepositoryLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PageTurn',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    ExploreScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.neutral,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      drawer: const CustomDrawer(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: () => _showAddBottomSheet(context),
        tooltip: 'Add',
        elevation: 3,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddBottomSheetContent(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final items = [
      _BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
      _BottomNavItem(icon: Icons.bookmark_rounded, label: 'Library'),
      _BottomNavItem(icon: Icons.explore_rounded, label: 'Explore'),
      _BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(1.2), // The gradient border width
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.60),
                  Colors.white.withValues(alpha: 0.15),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22.8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 65.6, // 68 minus border margins (1.2 * 2 = 2.4)
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.08),
                        Colors.white.withValues(alpha: 0.04),
                        Colors.white.withValues(alpha: 0.14),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(22.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(items.length, (index) {
                      final isActive = _currentIndex == index;
                      final item = items[index];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.primary.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isActive
                                      ? AppTheme.primary.withValues(alpha: 0.35)
                                      : Colors.transparent,
                                  width: 1.0,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.12),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                item.icon,
                                color: isActive ? AppTheme.primary : const Color(0xFF7A6B63),
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                color: isActive ? AppTheme.primary : const Color(0xFF8E7D73),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final String label;

  _BottomNavItem({required this.icon, required this.label});
}

class _AddBottomSheetContent extends StatefulWidget {
  const _AddBottomSheetContent();

  @override
  State<_AddBottomSheetContent> createState() => _AddBottomSheetContentState();
}

class _AddBottomSheetContentState extends State<_AddBottomSheetContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Book Form State
  final _bookFormKey = GlobalKey<FormState>();
  final _bookTitleController = TextEditingController();
  final _bookAuthorController = TextEditingController();
  final _bookLengthController = TextEditingController();

  // Club Form State
  final _clubFormKey = GlobalKey<FormState>();
  final _clubNameController = TextEditingController();
  final _clubDescController = TextEditingController();
  final _clubModeratorController = TextEditingController();

  // Chosen icon/color index for club
  int _selectedStyleIndex = 0;

  final List<Map<String, dynamic>> _clubStyles = [
    {
      'icon': Icons.rocket_launch_rounded,
      'color': const Color(0xFFD97706),
    },
    {
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF2D6A4F),
    },
    {
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFF6A1B9A),
    },
    {
      'icon': Icons.auto_stories_rounded,
      'color': const Color(0xFF1565C0),
    },
  ];

  // Set of successfully added catalog book IDs (to display checkmark animation)
  final Set<String> _addedCatalogIds = {};

  // Google Books quick-add search state
  final _googleSearchController = TextEditingController();
  List<Book> _googleResults = [];
  bool _googleSearchLoading = false;
  String? _googleSearchError;
  final Set<String> _addedGoogleIds = {};

  // Local EPUB import state
  bool _importing = false;
  String? _importError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bookTitleController.dispose();
    _bookAuthorController.dispose();
    _bookLengthController.dispose();
    _clubNameController.dispose();
    _clubDescController.dispose();
    _clubModeratorController.dispose();
    _googleSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F5EF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDD4C4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add to PageTurn',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5C3826),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF7A6B63)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.primary,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: const Color(0xFF7A6B63),
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                  indicatorWeight: 3,
                  dividerColor: const Color(0xFFF2ECE4),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Catalog'),
                    Tab(text: 'Custom Book'),
                    Tab(text: 'Reading Club'),
                    Tab(text: 'Find Online'),
                    Tab(text: 'Import EPUB'),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    height: 330,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCatalogTab(),
                        _buildCustomBookTab(),
                        _buildReadingClubTab(),
                        _buildGoogleSearchTab(),
                        _buildImportEpubTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogTab() {
    final allMockBooks = [
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

    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        final libraryIds = LibraryProvider.instance.books.map((b) => b.id).toSet();
        final availableBooks = allMockBooks.where((b) => !libraryIds.contains(b.id)).toList();

        if (availableBooks.isEmpty) {
          return const Center(
            child: Text(
              'All catalog books are already in your library!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF7A6B63),
                fontSize: 14,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quickly save popular picks to your library:',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF7A6B63),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: availableBooks.length,
                itemBuilder: (context, index) {
                  final book = availableBooks[index];
                  final isAdded = _addedCatalogIds.contains(book.id);

                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (!isAdded) {
                              setState(() {
                                _addedCatalogIds.add(book.id);
                              });
                              LibraryProvider.instance.addBook(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Added "${book.title}" to library.'),
                                  backgroundColor: const Color(0xFF5C3826),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              final navigator = Navigator.of(context);
                              Future.delayed(const Duration(milliseconds: 600), () {
                                if (mounted) {
                                  navigator.pop();
                                }
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                height: 146,
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    book.coverAsset,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF2C3E50),
                                      child: Center(
                                        child: Text(
                                          book.title,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (isAdded)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3826),
                          ),
                        ),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFF7A6B63),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomBookTab() {
    return Form(
      key: _bookFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          TextFormField(
            controller: _bookTitleController,
            decoration: _buildInputDecoration('Book Title', Icons.book_rounded),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter title' : null,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bookAuthorController,
            decoration: _buildInputDecoration('Author', Icons.person_rounded),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter author' : null,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bookLengthController,
            keyboardType: TextInputType.number,
            decoration: _buildInputDecoration('Length (pages)', Icons.format_list_numbered_rounded),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Please enter page count';
              }
              if (int.tryParse(val) == null) {
                return 'Must be a valid number';
              }
              return null;
            },
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_bookFormKey.currentState!.validate()) {
                final customBook = Book(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: _bookTitleController.text.trim(),
                  author: _bookAuthorController.text.trim(),
                  coverAsset: '',
                  rating: 5.0,
                  reviewCount: '0',
                  length: '${_bookLengthController.text.trim()}p',
                  audioDuration: '0h 00m',
                  language: 'Eng',
                  description: 'A custom book added by user.',
                  tags: const [
                    BookTag(text: 'Custom', backgroundColorValue: 0xFFEDE7F6, textColorValue: 0xFF5E35B1),
                  ],
                  reviews: const [],
                );

                LibraryProvider.instance.addBook(customBook);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${customBook.title}" to library.'),
                    backgroundColor: const Color(0xFF5C3826),
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 1,
            ),
            child: const Text(
              'Add to Library',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingClubTab() {
    return Form(
      key: _clubFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          TextFormField(
            controller: _clubNameController,
            decoration: _buildInputDecoration('Club Name', Icons.group_rounded),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter club name' : null,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _clubDescController,
            decoration: _buildInputDecoration('Description', Icons.description_rounded),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _clubModeratorController,
            decoration: _buildInputDecoration('Moderator (optional)', Icons.admin_panel_settings_rounded),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select Club Style:',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF7A6B63),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_clubStyles.length, (index) {
              final style = _clubStyles[index];
              final isSelected = _selectedStyleIndex == index;
              final icon = style['icon'] as IconData;
              final color = style['color'] as Color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStyleIndex = index;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 2.2,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_clubFormKey.currentState!.validate()) {
                final chosenStyle = _clubStyles[_selectedStyleIndex];
                final newClub = ReadingClub(
                  id: 'club_${DateTime.now().millisecondsSinceEpoch}',
                  name: _clubNameController.text.trim(),
                  description: _clubDescController.text.trim(),
                  icon: chosenStyle['icon'] as IconData,
                  iconColor: chosenStyle['color'] as Color,
                  bgColor: (chosenStyle['color'] as Color).withValues(alpha: 0.12),
                  memberCount: 1,
                  rules: const [
                    'Respect fellow members and their interpretations.',
                    'No spoilers outside the designated discussion threads.',
                    'Keep discussions constructive and encouraging.'
                  ],
                  moderator: _clubModeratorController.text.trim().isNotEmpty
                      ? _clubModeratorController.text.trim()
                      : 'Kabutey',
                );

                ReadingClubProvider.instance.addClub(newClub);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Created reading club "${newClub.name}".'),
                    backgroundColor: const Color(0xFF5C3826),
                  ),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 1,
            ),
            child: const Text(
              'Create Club',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runGoogleSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _googleSearchLoading = true;
      _googleSearchError = null;
    });
    try {
      final results = await RepositoryLocator.bookRepository.searchGoogleBooks(query.trim());
      if (!mounted) return;
      setState(() {
        _googleResults = results;
        _googleSearchLoading = false;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _googleSearchError = e.message;
        _googleSearchLoading = false;
      });
    }
  }

  Widget _buildGoogleSearchTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _googleSearchController,
          decoration: _buildInputDecoration('Search title or author', Icons.search_rounded),
          style: const TextStyle(fontSize: 14),
          textInputAction: TextInputAction.search,
          onSubmitted: _runGoogleSearch,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _runGoogleSearch(_googleSearchController.text),
            child: const Text('Search', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
        ),
        Expanded(
          child: _googleSearchLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : _googleSearchError != null
                  ? Center(
                      child: Text(_googleSearchError!,
                          style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13)),
                    )
                  : _googleResults.isEmpty
                      ? const Center(
                          child: Text('Search Google Books to quick-add a title.',
                              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13)),
                        )
                      : ListView.builder(
                          itemCount: _googleResults.length,
                          itemBuilder: (context, index) {
                            final book = _googleResults[index];
                            final isAdded = _addedGoogleIds.contains(book.id);
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: SizedBox(
                                width: 40,
                                height: 56,
                                child: book.coverUrl != null
                                    ? Image.network(book.coverUrl!, fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(Icons.book_rounded, color: Color(0xFF7A6B63)))
                                    : const Icon(Icons.book_rounded, color: Color(0xFF7A6B63)),
                              ),
                              title: Text(book.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(book.author,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Color(0xFF7A6B63))),
                              trailing: isAdded
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32))
                                  : IconButton(
                                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary),
                                      onPressed: () {
                                        setState(() => _addedGoogleIds.add(book.id));
                                        LibraryProvider.instance.addBook(book);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Added "${book.title}" to library.')),
                                        );
                                      },
                                    ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Future<void> _importEpub() async {
    setState(() {
      _importing = true;
      _importError = null;
    });
    try {
      final book = await RepositoryLocator.bookRepository.importLocalEpub();
      if (!mounted) return;
      setState(() => _importing = false);
      if (book == null) return; // user cancelled the picker
      LibraryProvider.instance.addBook(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported "${book.title}" to your library.')),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _importing = false;
        _importError = e.message;
      });
    }
  }

  Widget _buildImportEpubTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.upload_file_rounded, size: 40, color: Color(0xFF7A6B63)),
        const SizedBox(height: 12),
        const Text(
          'Import an EPUB file from your device.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63), fontSize: 13),
        ),
        if (_importError != null) ...[
          const SizedBox(height: 12),
          Text(_importError!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Inter', color: Colors.red, fontSize: 12)),
        ],
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _importing ? null : _importEpub,
          icon: _importing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.folder_open_rounded, size: 18),
          label: Text(_importing ? 'Importing…' : 'Choose EPUB File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String labelText, IconData prefixIcon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Color(0xFF7A6B63), fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF7A6B63), size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2DDD5), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
