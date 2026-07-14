import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../core/auth/session_provider.dart';
import '../library/library_provider.dart';
import '../profile/profile_provider.dart';
import '../profile/reading_stats_provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  void initState() {
    super.initState();
    ProfileProvider.instance.loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.neutral,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildMenuList(context),
              const Spacer(),
              _buildReadingGoal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ProfileProvider.instance,
        SessionProvider.instance,
        LibraryProvider.instance,
      ]),
      builder: (context, _) {
        final profile = ProfileProvider.instance;
        final isGuest = profile.isGuest;
        final booksRead = LibraryProvider.instance.books.where((b) => b.isFinished == true).length;
        final avatarUrl = profile.avatarUrl;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : const AssetImage('assets/images/profile_avatar.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              style: const TextStyle(
                fontFamily: 'Literata',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 6),
            if (isGuest)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  SessionProvider.instance.requireAuth(
                    context,
                    pendingAction: () {},
                    reason: 'Sign in to sync your library and stats.',
                  );
                },
                child: const Text(
                  'Sign in to sync your progress',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            else
              Text(
                '$booksRead Book${booksRead == 1 ? '' : 's'} Read',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A6B63),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.search_rounded,
          label: 'Search Books',
          isActive: false,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.search);
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.group_rounded,
          label: 'Reading Clubs',
          isActive: true,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.readingClubs);
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.headphones_rounded,
          label: 'Audiobooks',
          isActive: false,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.audiobooks);
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.menu_book_rounded,
          label: 'E-Books',
          isActive: false,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.ebooks);
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(color: Color(0xFFF2ECE4), thickness: 1.2),
        ),
        _buildMenuItem(
          icon: Icons.settings_rounded,
          label: 'Settings',
          isActive: false,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.help_outline_rounded,
          label: 'Help',
          isActive: false,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.help);
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.tertiary.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF2E4E3F) : const Color(0xFF5C3826),
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? const Color(0xFF2E4E3F) : const Color(0xFF5C3826),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingGoal() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        LibraryProvider.instance,
        ReadingStatsProvider.instance,
      ]),
      builder: (context, _) {
        final booksRead = LibraryProvider.instance.books.where((b) => b.isFinished == true).length;
        final goal = ReadingStatsProvider.instance.goalTarget;
        final progress = goal > 0 ? (booksRead / goal).clamp(0.0, 1.0) : 0.0;
        final year = DateTime.now().year;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3ECE4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8DFD3), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'READING GOAL',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C481A),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE2D8CD),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8C481A)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${(progress * 100).round()}% of your $year goal reached.',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7A6B63),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
