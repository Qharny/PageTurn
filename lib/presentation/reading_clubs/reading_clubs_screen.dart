import 'package:flutter/material.dart';
import '../../theme.dart';
import 'reading_club_provider.dart';
import 'club_detail_screen.dart';
import '../../core/auth/session_provider.dart';

class ReadingClubsScreen extends StatefulWidget {
  const ReadingClubsScreen({super.key});

  @override
  State<ReadingClubsScreen> createState() => _ReadingClubsScreenState();
}

class _ReadingClubsScreenState extends State<ReadingClubsScreen> {
  static const _ink = Color(0xFF1E1E1E);
  static const _chocolateBrown = Color(0xFF5C3826);
  static const _mutedText = Color(0xFF7A6B63);

  // 0 = All, 1 = Joined
  int _filter = 0;

  static const List<String> _avatarPool = [
    'A', 'M', 'K', 'S', 'E', 'J', 'T', 'R', 'L', 'N'
  ];

  String _formatMemberCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k members';
    }
    return '$count members';
  }

  List<String> _avatarsFor(ReadingClub club) {
    final base = club.id.hashCode.abs();
    return List.generate(3, (i) => _avatarPool[(base + i * 3) % _avatarPool.length]);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReadingClubProvider.instance,
      builder: (context, child) {
        final provider = ReadingClubProvider.instance;
        final allClubs = provider.clubs;
        final joinedCount = allClubs.where((c) => provider.isJoined(c.id)).length;
        final clubs = _filter == 0
            ? allClubs
            : allClubs.where((c) => provider.isJoined(c.id)).toList();

        return Scaffold(
          backgroundColor: AppTheme.neutral,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find Your\nReading Tribe',
                          style: TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: _ink,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join a club and read alongside thousands of fellow book lovers.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: _mutedText,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFilterBar(allClubs.length, joinedCount),
                        const SizedBox(height: 20),
                        if (clubs.isEmpty)
                          _buildEmptyState()
                        else
                          ...clubs.map((club) => _buildClubCard(context, club)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          const Text(
            'Reading Clubs',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _chocolateBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(int allCount, int joinedCount) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildFilterTab('All', allCount, 0),
          _buildFilterTab('Joined', joinedCount, 1),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, int count, int index) {
    final isSelected = _filter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _chocolateBrown : _mutedText,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : const Color(0xFFE2DACF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.primary : _mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_rounded,
                  color: AppTheme.primary, size: 34),
            ),
            const SizedBox(height: 16),
            const Text(
              'No clubs joined yet',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _chocolateBrown,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap “All” to discover and join a club.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubCard(BuildContext context, ReadingClub club) {
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF0EAE0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: club.bgColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: Icon(club.icon, color: club.iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Led by ${club.moderator}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: _mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildJoinButton(context, club, isJoined),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              club.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: _mutedText,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildAvatarStack(club),
                const SizedBox(width: 10),
                Text(
                  _formatMemberCount(club.memberCount),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _chocolateBrown,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: _mutedText, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinButton(BuildContext context, ReadingClub club, bool isJoined) {
    if (isJoined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.tertiary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, size: 14, color: Color(0xFF2E4E3F)),
            SizedBox(width: 4),
            Text(
              'Joined',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF2E4E3F),
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: () {
        SessionProvider.instance.requireAuth(
          context,
          pendingAction: () {
            ReadingClubProvider.instance.toggleJoin(club.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Joined ${club.name}! 🎉"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          reason: 'Sign in to join reading clubs.',
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8C481A),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: const Text(
        'Join',
        style: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildAvatarStack(ReadingClub club) {
    final initials = _avatarsFor(club);
    const size = 28.0;
    const step = 18.0;
    final avatarColor = Color.lerp(club.bgColor, club.iconColor, 0.2)!;

    return SizedBox(
      width: size + step * (initials.length - 1),
      height: size,
      child: Stack(
        children: [
          for (int i = 0; i < initials.length; i++)
            Positioned(
              left: i * step,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarColor,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials[i],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: club.iconColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
