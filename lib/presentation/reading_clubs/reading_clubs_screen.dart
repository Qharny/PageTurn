import 'package:flutter/material.dart';
import '../../theme.dart';

class ReadingClubsScreen extends StatelessWidget {
  const ReadingClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clubs = [
      _Club(
        name: 'The Classics Circle',
        members: '12.4k members',
        description: 'Exploring timeless works from Dickens to Dostoevsky.',
        icon: Icons.menu_book_rounded,
        iconColor: const Color(0xFF2D6A4F),
        bgColor: const Color(0xFFE8F0EC),
        joined: true,
      ),
      _Club(
        name: 'Afrofuturism Hub',
        members: '8.9k members',
        description: 'Where African imagination meets the future of literature.',
        icon: Icons.rocket_launch_rounded,
        iconColor: const Color(0xFFD97706),
        bgColor: const Color(0xFFFDF0E9),
        joined: false,
      ),
      _Club(
        name: 'Sci-Fi Collective',
        members: '21.3k members',
        description: 'For those who dream beyond the stars and between galaxies.',
        icon: Icons.blur_on_rounded,
        iconColor: const Color(0xFF1565C0),
        bgColor: const Color(0xFFE3F2FD),
        joined: false,
      ),
      _Club(
        name: 'Mystery Minds',
        members: '5.7k members',
        description: 'Unraveling clues, suspects, and unexpected twists together.',
        icon: Icons.search_rounded,
        iconColor: const Color(0xFF6A1B9A),
        bgColor: const Color(0xFFF3E5F5),
        joined: true,
      ),
      _Club(
        name: 'Historical Horizons',
        members: '3.2k members',
        description: 'Journeying through history, one page at a time.',
        icon: Icons.history_edu_rounded,
        iconColor: const Color(0xFF4E342E),
        bgColor: const Color(0xFFEFEBE9),
        joined: false,
      ),
    ];

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
                    ...clubs.map((club) => _buildClubCard(club)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildClubCard(_Club club) {
    return Container(
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
                      club.members,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Color(0xFF7A6B63),
                      ),
                    ),
                  ],
                ),
              ),
              club.joined
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
                      onPressed: () {},
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
    );
  }
}

class _Club {
  final String name;
  final String members;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final bool joined;

  _Club({
    required this.name,
    required this.members,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.joined,
  });
}
