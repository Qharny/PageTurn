import 'package:flutter/material.dart';
import '../../theme.dart';
import 'reading_club_provider.dart';
import '../../routes.dart';
import '../library/library_provider.dart';
import '../../core/auth/session_provider.dart';
import '../common/widgets/book_cover.dart';
import '../../data/models/book_model.dart';

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



  static const List<Color> _avatarPalette = [
    Color(0xFFD97706),
    Color(0xFF2D6A4F),
    Color(0xFF6A1B9A),
    Color(0xFF1565C0),
    Color(0xFFAD1457),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    ReadingClubProvider.instance.subscribeToChat(widget.club.id).then((_) {
      _scrollToBottom();
    });
    ReadingClubProvider.instance.loadMembers(widget.club.id);
  }

  void _handleTabChange() {
    setState(() {});
    if (_tabController.index == 1) {
      _scrollToBottom();
    }
  }

  Color _avatarColorFor(String name) {
    if (name.isEmpty) return _avatarPalette.first;
    return _avatarPalette[name.hashCode.abs() % _avatarPalette.length];
  }

  @override
  void dispose() {
    ReadingClubProvider.instance.unsubscribeFromChat();
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
    ReadingClubProvider.instance.addMessage(widget.club.id, text);
    _scrollToBottom();
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
      listenable: Listenable.merge([ReadingClubProvider.instance, SessionProvider.instance]),
      builder: (context, child) {
        final isJoined = ReadingClubProvider.instance.isJoined(widget.club.id);
        final isAuthenticated = SessionProvider.instance.isAuthenticated;
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
                      _buildChatTab(currentClub, isJoined, isAuthenticated),
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
                  SessionProvider.instance.requireAuth(
                    context,
                    pendingAction: () async {
                      final success = await ReadingClubProvider.instance.toggleJoin(club.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? (isJoined ? "Left ${club.name}" : "Joined ${club.name}! 🎉")
                                : "Couldn't update membership. Please try again.",
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    reason: 'Sign in to join reading clubs.',
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
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTabPill('About', 0),
          _buildTabPill('Group Chat', 1),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tabController.animateTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
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
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? _chocolateBrown : _mutedText,
            ),
          ),
        ),
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
          ListenableBuilder(
            listenable: ReadingClubProvider.instance,
            builder: (context, _) {
              final members = ReadingClubProvider.instance.getMembers(club.id);
              if (members.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('No other members have joined yet.',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: _mutedText)),
                );
              }
              return SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                            radius: 24,
                            child: Text(
                              member.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            member.name.split(' ')[0],
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: _chocolateBrown),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab(ReadingClub club, bool isJoined, bool isAuthenticated) {
    if (!isAuthenticated) {
      return _buildSignInRequiredState(club);
    }
    if (!isJoined) {
      return _buildLockedChatState(club);
    }

    final messages = ReadingClubProvider.instance.getMessages(club.id);

    // Auto-scroll to the bottom when messages list size changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

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
                    final prev = index > 0 ? messages[index - 1] : null;
                    final next = index < messages.length - 1 ? messages[index + 1] : null;
                    final isFirstInGroup = prev == null || prev.sender != message.sender || prev.isMe != message.isMe;
                    final isLastInGroup = next == null || next.sender != message.sender || next.isMe != message.isMe;
                    return _buildChatBubble(
                      message,
                      isFirstInGroup: isFirstInGroup,
                      isLastInGroup: isLastInGroup,
                    );
                  },
                ),
        ),
        _buildChatInput(),
      ],
    );
  }

  Widget _buildSignInRequiredState(ReadingClub club) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_person_rounded, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sign In to Chat',
              style: TextStyle(
                fontFamily: 'Literata',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _darkBrown,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have to sign in first to view and join the conversation in ${club.name}.',
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
                SessionProvider.instance.requireAuth(
                  context,
                  pendingAction: () {},
                  reason: 'Sign in to chat with the group.',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8C481A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
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
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppTheme.primary, size: 32),
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
                SessionProvider.instance.requireAuth(
                  context,
                  pendingAction: () async {
                    final success = await ReadingClubProvider.instance.toggleJoin(club.id);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Joined ${club.name}! 🎉"
                              : "Couldn't join the club. Please try again.",
                        ),
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

  /// Renders one bubble, grouping consecutive messages from the same sender
  /// like iMessage: the sender name only appears above the first bubble in a
  /// run, the avatar only appears next to the last (bottom-anchored) bubble,
  /// and the "tail" corner is only rounded-off on that last bubble.
  Widget _buildChatBubble(
    ReadingClubMessage message, {
    required bool isFirstInGroup,
    required bool isLastInGroup,
  }) {
    final isMe = message.isMe;
    final bubbleColor = isMe ? const Color(0xFF8C481A) : const Color(0xFFF3ECE1);
    final textColor = isMe ? Colors.white : _darkBrown;
    const roundCorner = Radius.circular(18);
    const tailCorner = Radius.circular(4);
    final borderRadius = isMe
        ? BorderRadius.only(
            topLeft: roundCorner,
            topRight: roundCorner,
            bottomLeft: roundCorner,
            bottomRight: isLastInGroup ? tailCorner : roundCorner,
          )
        : BorderRadius.only(
            topLeft: roundCorner,
            topRight: roundCorner,
            bottomRight: roundCorner,
            bottomLeft: isLastInGroup ? tailCorner : roundCorner,
          );

    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.68),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.sharedBook != null) ...[
            _buildSharedBookCard(message.sharedBook!),
            const SizedBox(height: 8),
          ],
          Text(
            message.text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );

    if (isMe) {
      return Padding(
        padding: EdgeInsets.only(bottom: isLastInGroup ? 10 : 3),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLastInGroup ? 14 : 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            child: isLastInGroup
                ? Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _avatarColorFor(message.sender).withValues(alpha: 0.16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      message.sender.isNotEmpty ? message.sender[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _avatarColorFor(message.sender),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstInGroup)
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 3),
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
                bubble,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      color: _bg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _showShareBookDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_link_rounded, color: AppTheme.primary, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Message the group...',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: _mutedText, fontSize: 14),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style: const TextStyle(fontFamily: 'Inter', color: _darkBrown, fontSize: 14),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareBookDialog() {
    final books = LibraryProvider.instance.books;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF9F4EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share a Book',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select a book from your library to share with the group.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF7A6B63),
                ),
              ),
              const SizedBox(height: 16),
              if (books.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No books in your library yet. Add some from Explore!',
                      style: TextStyle(fontFamily: 'Inter', color: Color(0xFF7A6B63)),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 32,
                          height: 48,
                          child: BookCover(
                            coverAsset: book.coverAsset,
                            coverUrl: book.coverUrl,
                            title: book.title,
                          ),
                        ),
                        title: Text(
                          book.title,
                          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: Text(
                          book.author,
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 11),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _shareBook(book);
                        },
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

  void _shareBook(Book book) {
    ReadingClubProvider.instance.addMessage(
      widget.club.id,
      'Recommended: "${book.title}" by ${book.author}',
      sharedBook: book,
    );
    _scrollToBottom();
  }

  Widget _buildSharedBookCard(Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.details, arguments: book);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF6EE),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEFE8DD), width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: BookCover(
                  coverAsset: book.coverAsset,
                  coverUrl: book.coverUrl,
                  title: book.title,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFF7A6B63),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.orange, size: 12),
                      const SizedBox(width: 2),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5C3826),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
