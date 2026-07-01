import 'package:flutter/material.dart';

class ReadingClub {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  int memberCount;
  final List<String> rules;
  final String moderator;

  ReadingClub({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.memberCount,
    required this.rules,
    required this.moderator,
  });
}

class ReadingClubMessage {
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isMe;

  ReadingClubMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isMe,
  });
}

class ReadingClubProvider extends ChangeNotifier {
  static final ReadingClubProvider instance = ReadingClubProvider._internal();
  ReadingClubProvider._internal() {
    // Populate some baseline chat messages
    _chats['classics'] = [
      ReadingClubMessage(
        sender: 'Amina Osei',
        text: 'Welcome to the classics circle! 📖 Who is ready for this month\'s pick?',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isMe: false,
      ),
      ReadingClubMessage(
        sender: 'Marcus Vance',
        text: 'I\'ve already read the first three chapters. The writing is incredibly dense but beautiful.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
      ),
    ];
    _chats['afrofuturism'] = [
      ReadingClubMessage(
        sender: 'Kofi Mensah',
        text: 'The world-building in this book is insane! 🚀',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: false,
      ),
    ];
    _chats['scifi'] = [
      ReadingClubMessage(
        sender: 'Marcus Vance',
        text: 'The space opera elements here are superb.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isMe: false,
      ),
    ];
    _chats['mystery'] = [
      ReadingClubMessage(
        sender: 'Sarah Jenkins',
        text: 'Do not spoil the solution to the mystery! 🤫 Let\'s post theories here.',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isMe: false,
      ),
    ];
    _chats['history'] = [
      ReadingClubMessage(
        sender: 'Elena Rostova',
        text: 'We start our journey in ancient Egypt tomorrow!',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isMe: false,
      ),
    ];
  }

  final List<ReadingClub> _clubs = [
    ReadingClub(
      id: 'classics',
      name: 'The Classics Circle',
      memberCount: 12420,
      description: 'Exploring timeless works from Dickens to Dostoevsky. Read alongside fellow classics enthusiasts, debate themes, and uncover historical contexts.',
      icon: Icons.menu_book_rounded,
      iconColor: const Color(0xFF2D6A4F),
      bgColor: const Color(0xFFE8F0EC),
      rules: [
        'Respect fellow members and their interpretations.',
        'No spoilers outside the designated discussion threads.',
        'Participate in the monthly live debate sessions.'
      ],
      moderator: 'Amina Osei',
    ),
    ReadingClub(
      id: 'afrofuturism',
      name: 'Afrofuturism Hub',
      memberCount: 8900,
      description: 'Where African imagination meets the future of literature. Discover science fiction, fantasy, and speculative fiction by African writers.',
      icon: Icons.rocket_launch_rounded,
      iconColor: const Color(0xFFD97706),
      bgColor: const Color(0xFFFDF0E9),
      rules: [
        'Focus on works by writers of the African continent and diaspora.',
        'Keep discussions constructive and encouraging.',
        'Support indie and emerging sci-fi authors.'
      ],
      moderator: 'Kofi Mensah',
    ),
    ReadingClub(
      id: 'scifi',
      name: 'Sci-Fi Collective',
      memberCount: 21300,
      description: 'For those who dream beyond the stars and between galaxies. Hard science, cyberpunk, space opera, and dystopian futures are all explored here.',
      icon: Icons.blur_on_rounded,
      iconColor: const Color(0xFF1565C0),
      bgColor: const Color(0xFFE3F2FD),
      rules: [
        'All sci-fi subgenres are welcome.',
        'Keep post titles clear of spoilers.',
        'No hate speech or gatekeeping.'
      ],
      moderator: 'Marcus Vance',
    ),
    ReadingClub(
      id: 'mystery',
      name: 'Mystery Minds',
      memberCount: 5740,
      description: 'Unraveling clues, suspects, and unexpected twists together. Dedicated to murder mysteries, thrillers, noir, and classic whodunits.',
      icon: Icons.search_rounded,
      iconColor: const Color(0xFF6A1B9A),
      bgColor: const Color(0xFFF3E5F5),
      rules: [
        'Do not spoil the solution to the mystery!',
        'Share your theories in the speculation channel.',
        'Suggest monthly read choices in the polls.'
      ],
      moderator: 'Sarah Jenkins',
    ),
    ReadingClub(
      id: 'history',
      name: 'Historical Horizons',
      memberCount: 3210,
      description: 'Journeying through history, one page at a time. From ancient civilizations to recent history, we explore novels and narrative non-fiction.',
      icon: Icons.history_edu_rounded,
      iconColor: const Color(0xFF4E342E),
      bgColor: const Color(0xFFEFEBE9),
      rules: [
        'Cite historical sources where appropriate.',
        'Discuss historical events objectively.',
        'Recommendations should have a historical core.'
      ],
      moderator: 'Elena Rostova',
    ),
  ];

  final Set<String> _joinedClubs = {'classics', 'mystery'};
  final Map<String, List<ReadingClubMessage>> _chats = {};

  List<ReadingClub> get clubs => _clubs;
  Set<String> get joinedClubs => _joinedClubs;

  bool isJoined(String id) => _joinedClubs.contains(id);

  List<ReadingClubMessage> getMessages(String clubId) {
    return _chats[clubId] ?? [];
  }

  void toggleJoin(String id) {
    if (_joinedClubs.contains(id)) {
      _joinedClubs.remove(id);
      final club = _clubs.firstWhere((c) => c.id == id);
      club.memberCount--;
    } else {
      _joinedClubs.add(id);
      final club = _clubs.firstWhere((c) => c.id == id);
      club.memberCount++;
    }
    notifyListeners();
  }

  void addMessage(String clubId, String sender, String text, {bool isMe = true}) {
    if (!_chats.containsKey(clubId)) {
      _chats[clubId] = [];
    }
    _chats[clubId]!.add(ReadingClubMessage(
      sender: sender,
      text: text,
      timestamp: DateTime.now(),
      isMe: isMe,
    ));
    notifyListeners();
  }
}
