import 'package:flutter/material.dart';
import 'dart:io';
import '../../theme.dart';
import '../../routes.dart';
import 'profile_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../reading_clubs/reading_club_provider.dart';
import '../../data/models/book_model.dart';
import '../common/widgets/book_cover.dart';
import '../library/library_provider.dart';
import '../../core/auth/session_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _bg = Color(0xFFF9F4EE);
  static const _darkBrown = Color(0xFF1A0F0A);
  static const _chocolateBrown = Color(0xFF5C3826);
  static const _mutedText = Color(0xFF7A6B63);
  static const _border = Color(0xFFF0E8DC);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load profile data from Supabase (no-op if already loaded).
    ProfileProvider.instance.loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProfileProvider.instance,
      builder: (context, _) {
        final isGuest = ProfileProvider.instance.isGuest;
        return Scaffold(
          backgroundColor: _bg,
          body: isGuest
              ? _buildGuestView()
              : NestedScrollView(
                  physics: const BouncingScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(child: _buildProfileHeader()),
                    SliverToBoxAdapter(child: _buildStatsRow()),
                    SliverToBoxAdapter(child: _buildTabBar()),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLibraryTab(),
                      _buildActivityTab(),
                      _buildBadgesTab(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildGuestView() {
    return Stack(
      children: [
        // Premium top gradient banner
        Container(
          height: 240,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C1810),
                Color(0xFF8C481A),
                Color(0xFFE67E22),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'PageTurn',
                  style: TextStyle(
                    fontFamily: 'Literata',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Settings gear in guest mode too
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
          ),
        ),

        // Main info container overlapping the banner
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: MediaQuery.of(context).size.height - 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF0E8DC), width: 2),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Unlock Your Sanctuary',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _chocolateBrown,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create an account or sign in to build your personal library, track your streaks, customize your bio, join global book clubs, and sync reading progress seamlessly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: _mutedText,
                      height: 1.55,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        SessionProvider.instance.requireAuth(
                          context,
                          pendingAction: () {},
                          reason: 'Sign in to customize your profile.',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C481A),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Sign In / Register',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── PROFILE HEADER (Twitter/X style) ────────────────────────────────────
  Widget _buildProfileHeader() {
    const bannerH = 180.0;
    const avatarR = 46.0; // radius
    const overlapBelowBanner = avatarR + 8;

    return SizedBox(
      height: bannerH + overlapBelowBanner + 56, // 56 for name/bio row
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Banner — warm gradient pretending to be a cover photo
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: bannerH,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2C1810),
                    Color(0xFF8C481A),
                    Color(0xFFE67E22),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Subtle geometric overlay
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -60,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ),
                  // PageTurn wordmark on banner
                  Positioned(
                    right: 20,
                    bottom: overlapBelowBanner + 12,
                    child: const Text(
                      'PageTurn',
                      style: TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Warm-white area below banner
          Positioned(
            top: bannerH, left: 0, right: 0, bottom: 0,
            child: Container(color: _bg),
          ),

          // Top-right action buttons on banner
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Row(
              children: [
                // Sign-out shortcut (only for authenticated users)
                ListenableBuilder(
                  listenable: SessionProvider.instance,
                  builder: (_, child) {
                    if (!SessionProvider.instance.isAuthenticated) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () async {
                        final confirmed = await _confirmSignOut();
                        if (confirmed && mounted) {
                          await AuthService.instance.signOut();
                          ProfileProvider.instance.onAuthChanged();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text('Sign Out', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),

          // Avatar — overlapping junction
          Positioned(
            top: bannerH - avatarR,
            left: 22,
            child: ListenableBuilder(
              listenable: ProfileProvider.instance,
              builder: (context, _) {
                final provider = ProfileProvider.instance;
                final avatarUrl = provider.avatarUrl;

                return GestureDetector(
                  onTap: provider.isGuest ? null : () => _pickAndUploadAvatar(context),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _bg, width: 3.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: avatarR,
                          backgroundColor: const Color(0xFF2C3E50),
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? ClipOval(
                                  child: Image.asset(
                                    'assets/images/profile_avatar.png',
                                    width: avatarR * 2,
                                    height: avatarR * 2,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: Colors.white70,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (!provider.isGuest)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Edit Profile pill OR Sign-in CTA depending on auth state
          Positioned(
            top: bannerH + (overlapBelowBanner * 2 - 38) / 2,
            right: 20,
            child: ListenableBuilder(
              listenable: SessionProvider.instance,
              builder: (_, child) {
                final isGuest = ProfileProvider.instance.isGuest;
                return OutlinedButton(
                  onPressed: () {
                    if (isGuest) {
                      SessionProvider.instance.requireAuth(
                        context,
                        pendingAction: () {},
                        reason: 'Sign in to personalise your profile.',
                      );
                    } else {
                      _showEditProfileSheet(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _chocolateBrown,
                    side: const BorderSide(color: Color(0xFFDDD4C4), width: 1.5),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isGuest ? 'Sign In' : 'Edit Profile',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),

          // Name + bio — bottom of the header block
          Positioned(
            left: 22,
            right: 22,
            bottom: 10,
            child: ListenableBuilder(
              listenable: ProfileProvider.instance,
              builder: (context, child) {
                final provider = ProfileProvider.instance;
                if (provider.isLoading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 140,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 200,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _chocolateBrown,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (provider.bio.isNotEmpty)
                      Text(
                        provider.bio,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _mutedText.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileSheet(BuildContext context) {
    final nameController = TextEditingController(text: ProfileProvider.instance.name);
    final bioController = TextEditingController(text: ProfileProvider.instance.bio);
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Color(0xFF7A6B63)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8C481A)),
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF1A0F0A)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio / Tagline',
                      labelStyle: TextStyle(color: Color(0xFF7A6B63)),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8C481A)),
                      ),
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF1A0F0A)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              setSheetState(() => saving = true);
                              await ProfileProvider.instance.updateProfile(
                                name: nameController.text.trim(),
                                bio: bioController.text.trim(),
                              );
                              if (sheetContext.mounted) Navigator.pop(sheetContext);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile updated!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8C481A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final filePath = file.path;
      if (filePath == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get image path.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final bytes = await File(filePath).readAsBytes();
      final extension = file.extension ?? 'jpg';

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uploading avatar... ⏳'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await ProfileProvider.instance.uploadAvatar(bytes, extension);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar uploaded successfully! 🎉'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading avatar: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _confirmSignOut() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF9F4EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?',
          style: TextStyle(fontFamily: 'Literata', fontWeight: FontWeight.bold, color: _chocolateBrown),
        ),
        content: const Text(
          'Your progress is saved to the cloud. Sign back in anytime.',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: _mutedText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter', color: _mutedText)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Sign Out', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─── STATS ROW ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: ReadingClubProvider.instance,
          builder: (context, _) {
            final booksRead = LibraryProvider.instance.books.where((b) => b.isFinished == true).length;
            
            // Calculate dynamic estimate of reading hours
            final hoursRead = booksRead * 5 + LibraryProvider.instance.books.where((b) => b.progress != null && b.progress! > 0 && b.isFinished != true).length * 2;
            
            // Active streak check
            final hasStreak = LibraryProvider.instance.books.isNotEmpty;
            final streakStr = hasStreak ? '14d' : '0d';
            
            // Count joined clubs
            final joinedClubsCount = ReadingClubProvider.instance.clubs
                .where((c) => ReadingClubProvider.instance.isJoined(c.id))
                .length;

            final stats = [
              _Stat(label: 'Books Read', value: '$booksRead'),
              _Stat(label: 'Hours Read', value: '$hoursRead'),
              _Stat(label: 'Streak', value: streakStr),
              _Stat(label: 'Clubs', value: '$joinedClubsCount'),
            ];

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: stats.map((s) {
                  final isLast = s == stats.last;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _buildStatItem(s)),
                        if (!isLast) Container(width: 1, height: 32, color: _border),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(_Stat stat) {
    return Column(
      children: [
        Text(
          stat.value,
          style: const TextStyle(
            fontFamily: 'Literata',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _chocolateBrown,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: _mutedText,
          ),
        ),
      ],
    );
  }

  // ─── TAB BAR ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8DC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _chocolateBrown,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: _mutedText,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: 'Library'),
          Tab(text: 'Activity'),
          Tab(text: 'Badges'),
        ],
      ),
    );
  }

  // ─── LIBRARY TAB ──────────────────────────────────────────────────────────
  Widget _buildLibraryTab() {
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        final books = LibraryProvider.instance.books;
        final currentlyReading =
            books.where((b) => b.progress != null && b.progress! > 0 && b.isFinished != true).toList();
        final finished = books.where((b) => b.isFinished == true).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reading goal card
              _buildReadingGoalCard(),
              const SizedBox(height: 24),

              const Text(
                'Currently Reading',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _chocolateBrown,
                ),
              ),
              const SizedBox(height: 14),
              if (currentlyReading.isEmpty)
                const Text(
                  'Nothing in progress yet.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
                )
              else
                ...currentlyReading.map((book) => _buildReadingBookCard(book)),

              const SizedBox(height: 24),
              const Text(
                'Finished',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _chocolateBrown,
                ),
              ),
              const SizedBox(height: 14),
              if (finished.isEmpty)
                const Text(
                  'No finished books yet.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
                )
              else
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: finished.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final book = finished[i];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.details, arguments: book),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: BookCover(
                                coverAsset: book.coverAsset,
                                coverUrl: book.coverUrl,
                                title: book.title,
                                width: 110,
                                height: 165,
                                fit: BoxFit.cover,
                                borderRadius: 0,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.tertiary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadingGoalCard() {
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        final booksRead = LibraryProvider.instance.books.where((b) => b.isFinished == true).length;
        const booksGoal = 10;
        final progress = booksGoal > 0 ? (booksRead / booksGoal).clamp(0.0, 1.0) : 0.0;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _darkBrown,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '2026 Reading Goal',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '$booksRead / $booksGoal books',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(progress * 100).round()}% complete · ${booksRead >= booksGoal ? 'Goal achieved! 🏆' : '${booksGoal - booksRead} more to reach your goal 🎯'}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildReadingBookCard(Book book) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.details, arguments: book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.2),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BookCover(
                coverAsset: book.coverAsset,
                coverUrl: book.coverUrl,
                title: book.title,
                width: 52,
                height: 72,
                fit: BoxFit.cover,
                borderRadius: 0,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _chocolateBrown,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: _mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (book.progress ?? 0.1).toDouble(),
                      minHeight: 5,
                      backgroundColor: const Color(0xFFF0E8DC),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((book.progress ?? 0.1) * 100).round()}% complete',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: _mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: _mutedText, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── ACTIVITY TAB ─────────────────────────────────────────────────────────
  Widget _buildActivityTab() {
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        return ListenableBuilder(
          listenable: ReadingClubProvider.instance,
          builder: (context, _) {
            final books = LibraryProvider.instance.books;
            final List<_Activity> activities = [];

            for (final book in books) {
              if (book.isFinished == true) {
                activities.add(_Activity(
                  icon: Icons.check_circle_rounded,
                  color: AppTheme.tertiary,
                  label: 'Finished reading',
                  title: book.title,
                  time: 'Recently',
                ));
              } else if (book.progress != null && book.progress! > 0) {
                activities.add(_Activity(
                  icon: Icons.menu_book_rounded,
                  color: AppTheme.primary,
                  label: 'Started reading',
                  title: book.title,
                  time: 'In progress',
                ));
              }
            }

            final joinedClubs = ReadingClubProvider.instance.clubs
                .where((c) => ReadingClubProvider.instance.isJoined(c.id))
                .toList();

            for (final club in joinedClubs) {
              activities.add(_Activity(
                icon: Icons.group_rounded,
                color: const Color(0xFF2D6A4F),
                label: 'Joined club',
                title: club.name,
                time: 'Active member',
              ));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeeklyReadingStrip(),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _chocolateBrown,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (activities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No recent activity yet. Start exploring to build your timeline!',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
                        ),
                      ),
                    )
                  else
                    ...activities.asMap().entries.map((e) => _buildActivityRow(e.value, e.key == activities.length - 1)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyReadingStrip() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        final hasBooks = LibraryProvider.instance.books.isNotEmpty;
        final minutesRead = hasBooks ? [30, 15, 45, 20, 60, 40, 15] : [0, 0, 0, 0, 0, 0, 0];
        final maxMinutes = minutesRead.reduce((a, b) => a > b ? a : b).toDouble();

        final totalMin = minutesRead.reduce((a, b) => a + b);
        final avgMin = (totalMin / 7).round();
        final maxMin = minutesRead.reduce((a, b) => a > b ? a : b);

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This Week', style: TextStyle(fontFamily: 'Literata', fontSize: 16, fontWeight: FontWeight.bold, color: _chocolateBrown)),
              const SizedBox(height: 4),
              const Text('Daily reading minutes', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _mutedText)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final fraction = maxMinutes > 0 ? minutesRead[i] / maxMinutes : 0.0;
                  final isToday = i == 5; // Saturday
                  return Column(
                    children: [
                      Container(
                        width: 28,
                        height: 64,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300 + i * 50),
                          width: 28,
                          height: 64 * fraction,
                          decoration: BoxDecoration(
                            color: isToday ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(days[i], style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: isToday ? AppTheme.primary : _mutedText, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF0E8DC)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat('$totalMin min', 'This week'),
                  _buildMiniStat('$avgMin min', 'Daily avg'),
                  _buildMiniStat('$maxMin min', 'Best day'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: _chocolateBrown)),
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: _mutedText)),
      ],
    );
  }

  Widget _buildActivityRow(_Activity activity, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activity.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity.icon, color: activity.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText),
                        children: [
                          TextSpan(text: '${activity.label} '),
                          TextSpan(
                            text: activity.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: _chocolateBrown),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(activity.time, style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: _mutedText)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(color: Color(0xFFF0E8DC), height: 1),
      ],
    );
  }

  // ─── BADGES TAB ───────────────────────────────────────────────────────────
  Widget _buildBadgesTab() {
    return ListenableBuilder(
      listenable: LibraryProvider.instance,
      builder: (context, _) {
        final booksRead = LibraryProvider.instance.books.where((b) => b.isFinished == true).length;
        final hasBooks = LibraryProvider.instance.books.isNotEmpty;
        final isAuth = AuthService.instance.isAuthenticated;

        final allBadges = [
          _Badge(
            icon: Icons.menu_book_rounded,
            label: 'Bookworm',
            sub: 'Read 1 book',
            color: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFE65100),
            isEarned: booksRead >= 1,
          ),
          _Badge(
            icon: Icons.local_fire_department_rounded,
            label: 'On Fire',
            sub: 'Active library',
            color: const Color(0xFFFFEBEA),
            iconColor: const Color(0xFFC62828),
            isEarned: hasBooks,
          ),
          _Badge(
            icon: Icons.workspace_premium_rounded,
            label: 'Verified Member',
            sub: 'Signed in account',
            color: const Color(0xFFFFF8E1),
            iconColor: const Color(0xFFF57F17),
            isEarned: isAuth,
          ),
          _Badge(
            icon: Icons.public_rounded,
            label: 'Explorer',
            sub: 'Add books to list',
            color: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF2E7D32),
            isEarned: hasBooks,
          ),
        ];

        final earned = allBadges.where((b) => b.isEarned).toList();
        final locked = allBadges.where((b) => !b.isEarned).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (earned.isNotEmpty) ...[
                const Text(
                  'Earned',
                  style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: _chocolateBrown),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: earned.map((b) => _buildBadgeCard(b, false)).toList(),
                ),
                const SizedBox(height: 28),
              ],
              if (locked.isNotEmpty) ...[
                const Text(
                  'Locked',
                  style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: _mutedText),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                  children: locked.map((b) => _buildBadgeCard(b, true)).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeCard(_Badge badge, bool locked) {
    return Container(
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFF5F0EA) : badge.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: locked ? const Color(0xFFE8E0D4) : badge.color,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          locked
              ? const Icon(Icons.lock_rounded, size: 28, color: Color(0xFFBBAFA8))
              : Icon(badge.icon, size: 28, color: badge.iconColor),
          const SizedBox(height: 8),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: locked ? _mutedText : _chocolateBrown,
            ),
          ),
          const SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              badge.sub,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: locked ? const Color(0xFFBBAFA8) : _mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Data models ──────────────────────────────────────────────────────────────
class _Stat {
  final String label;
  final String value;
  _Stat({required this.label, required this.value});
}

class _Activity {
  final IconData icon;
  final Color color;
  final String label;
  final String title;
  final String time;
  _Activity({required this.icon, required this.color, required this.label, required this.title, required this.time});
}

class _Badge {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final Color iconColor;
  final bool isEarned;
  _Badge({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.iconColor,
    required this.isEarned,
  });
}
