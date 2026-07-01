import 'package:flutter/material.dart';
import '../../theme.dart';
import '../home/mock_books.dart';
import '../../routes.dart';
import 'profile_provider.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
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

          // Settings icon — top right on banner
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
              child: const Icon(Icons.settings_rounded, color: Colors.white, size: 24),
            ),
          ),

          // Avatar — overlapping junction
          Positioned(
            top: bannerH - avatarR,
            left: 22,
            child: Container(
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
                child: Image.asset(
                  'assets/images/profile_avatar.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),

          // Edit profile pill — white strip, bottom right
          Positioned(
            top: bannerH + (overlapBelowBanner * 2 - 38) / 2,
            right: 20,
            child: OutlinedButton(
              onPressed: () => _showEditProfileSheet(context),
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
              child: const Text(
                'Edit Profile',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ProfileProvider.instance.name,
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _chocolateBrown,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ProfileProvider.instance.bio,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
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
                  onPressed: () {
                    ProfileProvider.instance.updateProfile(
                      name: nameController.text.trim(),
                      bio: bioController.text.trim(),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C481A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── STATS ROW ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      _Stat(label: 'Books Read', value: '28'),
      _Stat(label: 'Hours Read', value: '194'),
      _Stat(label: 'Streak', value: '14d'),
      _Stat(label: 'Clubs', value: '2'),
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
    final currentlyReading = [
      MockBooks.midnightLibrary,
      MockBooks.becoming,
      MockBooks.dune,
    ];
    final finished = [
      MockBooks.greatGatsby,
      MockBooks.atomicHabits,
    ];

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
                        child: Image.asset(
                          book.coverAsset,
                          width: 110,
                          height: 165,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 110,
                            height: 165,
                            color: const Color(0xFFE0D4C8),
                          ),
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
  }

  Widget _buildReadingGoalCard() {
    const booksRead = 28;
    const booksGoal = 50;
    const progress = booksRead / booksGoal;

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
            '${(progress * 100).round()}% complete · ${booksGoal - booksRead} more to reach your goal 🎯',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingBookCard(book) {
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
              child: Image.asset(
                book.coverAsset,
                width: 52,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 52,
                  height: 72,
                  color: const Color(0xFFE0D4C8),
                ),
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
    final activities = [
      _Activity(icon: Icons.menu_book_rounded, color: AppTheme.primary, label: 'Started reading', title: 'Dune', time: '2 hours ago'),
      _Activity(icon: Icons.headphones_rounded, color: const Color(0xFF1565C0), label: 'Listened to', title: 'Atomic Habits', time: 'Yesterday'),
      _Activity(icon: Icons.star_rounded, color: const Color(0xFFF4A836), label: 'Rated 5 stars', title: 'Becoming', time: '3 days ago'),
      _Activity(icon: Icons.group_rounded, color: const Color(0xFF2D6A4F), label: 'Joined club', title: 'The Classics Circle', time: '1 week ago'),
      _Activity(icon: Icons.check_circle_rounded, color: AppTheme.tertiary, label: 'Finished', title: 'The Great Gatsby', time: '2 weeks ago'),
      _Activity(icon: Icons.bookmark_rounded, color: const Color(0xFF6A1B9A), label: 'Saved', title: 'Circe', time: '2 weeks ago'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heatmap-style weekly reading strip
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
          ...activities.asMap().entries.map((e) => _buildActivityRow(e.value, e.key == activities.length - 1)),
        ],
      ),
    );
  }

  Widget _buildWeeklyReadingStrip() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final minutesRead = [45, 0, 120, 90, 60, 180, 30];
    final maxMinutes = minutesRead.reduce((a, b) => a > b ? a : b).toDouble();

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
              _buildMiniStat('525 min', 'This week'),
              _buildMiniStat('75 min', 'Daily avg'),
              _buildMiniStat('3h 0m', 'Best day'),
            ],
          ),
        ],
      ),
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
    final earned = [
      _Badge(
        icon: Icons.menu_book_rounded,
        label: 'Bookworm',
        sub: '10 books read',
        color: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFE65100),
      ),
      _Badge(
        icon: Icons.local_fire_department_rounded,
        label: 'On Fire',
        sub: '7-day streak',
        color: const Color(0xFFFFEBEA),
        iconColor: const Color(0xFFC62828),
      ),
      _Badge(
        icon: Icons.nightlight_rounded,
        label: 'Night Owl',
        sub: 'Read after midnight',
        color: const Color(0xFFEDE7F6),
        iconColor: const Color(0xFF4527A0),
      ),
      _Badge(
        icon: Icons.headphones_rounded,
        label: 'Listener',
        sub: '50h of audio',
        color: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1565C0),
      ),
      _Badge(
        icon: Icons.workspace_premium_rounded,
        label: 'Gold Member',
        sub: 'Premium subscriber',
        color: const Color(0xFFFFF8E1),
        iconColor: const Color(0xFFF57F17),
      ),
      _Badge(
        icon: Icons.public_rounded,
        label: 'Globe Trotter',
        sub: '5 genres explored',
        color: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF2E7D32),
      ),
    ];
    final locked = [
      _Badge(
        icon: Icons.diamond_rounded,
        label: 'Diamond Reader',
        sub: '100 books read',
        color: const Color(0xFFECEFF1),
        iconColor: const Color(0xFF006064),
      ),
      _Badge(
        icon: Icons.bolt_rounded,
        label: 'Speed Reader',
        sub: 'Finish in one sitting',
        color: const Color(0xFFECEFF1),
        iconColor: const Color(0xFFE65100),
      ),
      _Badge(
        icon: Icons.emoji_events_rounded,
        label: 'Champion',
        sub: 'Annual goal complete',
        color: const Color(0xFFECEFF1),
        iconColor: const Color(0xFFC62828),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      ),
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
  _Badge({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.iconColor,
  });
}
