import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme.dart';
import 'reading_club_provider.dart';

class ReadingClubDetailScreen extends StatefulWidget {
  final ReadingClub club;

  const ReadingClubDetailScreen({
    super.key,
    required this.club,
  });

  @override
  State<ReadingClubDetailScreen> createState() => _ReadingClubDetailScreenState();
}

class _ReadingClubDetailScreenState extends State<ReadingClubDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _bg = Color(0xFFF9F4EE);
  static const _darkBrown = Color(0xFF1A0F0A);
  static const _chocolateBrown = Color(0xFF5C3826);
  static const _mutedText = Color(0xFF7A6B63);

  final List<Map<String, String>> _mockMembers = [
    {'name': 'Sarah Jenkins', 'role': 'Moderator'},
    {'name': 'Marcus Vance', 'role': 'Gold Reader'},
    {'name': 'Amina Osei', 'role': 'Classics Lover'},
    {'name': 'Kofi Mensah', 'role': 'Speed Reader'},
    {'name': 'Elena Rostova', 'role': 'Historian'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    ReadingClubProvider.instance.addMessage(widget.club.id, 'Me', text, isMe: true);
    _scrollToBottom();

    // Schedule a mock automatic reply after 1.5 seconds
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final mockReplies = [
          "That's a really interesting point! 💡",
          "I totally agree. I noticed that too in chapter 3.",
          "Welcome to the chat! Glad to have your perspective.",
          "I'm still on chapter 1, but I can't wait to catch up!",
          "Great observation! Let's keep discussing."
        ];
        final replyText = mockReplies[DateTime.now().second % mockReplies.length];
        final randomSender = _mockMembers[DateTime.now().millisecond % _mockMembers.length]['name']!;
        ReadingClubProvider.instance.addMessage(widget.club.id, randomSender, replyText, isMe: false);
        _scrollToBottom();
      }
    });
  }

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
        final isJoined = ReadingClubProvider.instance.isJoined(widget.club.id);
        final currentClub = ReadingClubProvider.instance.clubs.firstWhere((c) => c.id == widget.club.id);

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, currentClub, isJoined),
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAboutTab(currentClub),
                      _buildChatTab(currentClub, isJoined),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ReadingClub club, bool isJoined) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  child: const Icon(Icons.arrow_back_rounded, color: _chocolateBrown, size: 20),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ReadingClubProvider.instance.toggleJoin(club.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isJoined ? "Left ${club.name}" : "Joined ${club.name}! 🎉",
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined ? Colors.white : const Color(0xFF8C481A),
                  foregroundColor: isJoined ? _chocolateBrown : Colors.white,
                  elevation: 0,
                  side: isJoined ? const BorderSide(color: Color(0xFFDDD4C4), width: 1.5) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isJoined ? 'Joined' : 'Join Club',
                  style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: club.bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(club.icon, color: club.iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(
                        fontFamily: 'Literata',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatMemberCount(club.memberCount),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0E8DC), width: 1.5)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: _chocolateBrown,
        unselectedLabelColor: _mutedText,
        indicatorColor: AppTheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Group Chat'),
        ],
      ),
    );
  }

  Widget _buildAboutTab(ReadingClub club) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Club',
            style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: _darkBrown),
          ),
          const SizedBox(height: 10),
          Text(
            club.description,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: _chocolateBrown, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Moderator',
            style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: _darkBrown),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFD97706),
                  radius: 20,
                  child: Icon(Icons.person_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.moderator,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: _darkBrown),
                    ),
                    const Text(
                      'Club Leader & Moderator',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: _mutedText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rules & Guidelines',
            style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: _darkBrown),
          ),
          const SizedBox(height: 10),
          ...club.rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: _chocolateBrown, height: 1.3),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          const Text(
            'Members',
            style: TextStyle(fontFamily: 'Literata', fontSize: 18, fontWeight: FontWeight.bold, color: _darkBrown),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mockMembers.length,
              itemBuilder: (context, index) {
                final member = _mockMembers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                        radius: 24,
                        child: Text(
                          member['name']!.substring(0, 1),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        member['name']!.split(' ')[0],
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: _chocolateBrown),
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

  Widget _buildChatTab(ReadingClub club, bool isJoined) {
    if (!isJoined) {
      return _buildLockedChatState(club);
    }

    final messages = ReadingClubProvider.instance.getMessages(club.id);

    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(
                  child: Text(
                    'Start the conversation! 💬',
                    style: TextStyle(fontFamily: 'Inter', color: _mutedText),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildChatBubble(message);
                  },
                ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildLockedChatState(ReadingClub club) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6F0),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFEBE0), width: 2),
              ),
              child: const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 36),
            ),
            const SizedBox(height: 24),
            const Text(
              'Group Chat is Locked',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkBrown,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Join ${club.name} to unlock the live group chat and read alongside other members.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'Join Club to Unlock',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ReadingClubMessage message) {
    final align = message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.isMe ? const Color(0xFF8C481A) : Colors.white;
    final textColor = message.isMe ? Colors.white : _darkBrown;
    final borderRadius = message.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomRight: Radius.circular(14),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!message.isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                message.sender,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _mutedText,
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: borderRadius,
              border: message.isMe ? null : Border.all(color: const Color(0xFFF2ECE4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0E8DC), width: 1.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(fontFamily: 'Inter', color: _mutedText),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontFamily: 'Inter', color: _darkBrown),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }
}
