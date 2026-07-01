import 'package:flutter/material.dart';
import '../../theme.dart';
import 'reading_club_provider.dart';
import 'club_detail_screen.dart';

class ReadingClubsScreen extends StatelessWidget {
  const ReadingClubsScreen({super.key});

  String _formatMemberCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k members';
    }
    return '$count members';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ReadingClubProvider.instance,
      builder: (context, child) {
        final clubs = ReadingClubProvider.instance.clubs;
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Find Your\nReading Tribe',
                          style: TextStyle(
                            fontFamily: 'Literata',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Join a club and read alongside thousands of fellow book lovers.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF7A6B63),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
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
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3826), size: 20),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Reading Clubs',
            style: TextStyle(
              fontFamily: 'Literata',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C3826),
            ),
          ),
        ],
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
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: club.bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Icon(club.icon, color: club.iconColor, size: 26),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 3),
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
                isJoined
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.tertiary.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Joined',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF2E4E3F),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          ReadingClubProvider.instance.toggleJoin(club.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Joined ${club.name}! 🎉"),
                              behavior: SnackBarBehavior.floating,
                            ),
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
                          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              club.description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Color(0xFF7A6B63),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
