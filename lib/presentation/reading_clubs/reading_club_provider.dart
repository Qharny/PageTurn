import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../data/models/book_model.dart';

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
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final Book? sharedBook;

  ReadingClubMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.sharedBook,
  });
}

class ReadingClubMember {
  final String name;
  final String role;

  ReadingClubMember({
    required this.name,
    required this.role,
  });
}

class ReadingClubProvider extends ChangeNotifier {
  static final ReadingClubProvider instance = ReadingClubProvider._internal();
  ReadingClubProvider._internal() {
    loadClubs();
  }

  // ── State ──────────────────────────────────────────────────
  final List<ReadingClub> _clubs = [];
  final Set<String> _joinedClubs = {};
  final Map<String, List<ReadingClubMessage>> _chats = {};
  final Map<String, List<ReadingClubMember>> _clubMembersMap = {};
  final Map<String, String> _profileNames = {};
  bool _isLoading = false;

  RealtimeChannel? _activeChannel;

  // ── Getters ────────────────────────────────────────────────
  List<ReadingClub> get clubs => _clubs;
  Set<String> get joinedClubs => _joinedClubs;
  bool get isLoading => _isLoading;

  bool isJoined(String id) => _joinedClubs.contains(id);

  List<ReadingClubMessage> getMessages(String clubId) {
    return _chats[clubId] ?? [];
  }

  List<ReadingClubMember> getMembers(String clubId) {
    return _clubMembersMap[clubId] ?? [];
  }

  // ── Supabase Init Check ────────────────────────────────────
  bool get _isSupabaseInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Data Loading ───────────────────────────────────────────

  /// Fetches all book clubs and the current user's memberships from Supabase.
  Future<void> loadClubs() async {
    if (!_isSupabaseInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch clubs
      final clubsRes = await SupabaseService.client
          .from('clubs')
          .select('*, profiles!clubs_moderator_id_fkey(name)');

      _clubs.clear();
      for (final item in (clubsRes as List)) {
        final rulesList = (item['rules'] as List<dynamic>?)
                ?.map((r) => r.toString())
                .toList() ??
            [];

        final moderatorName = item['profiles'] != null && item['profiles']['name'] != null
            ? item['profiles']['name'] as String
            : 'Moderator';

        final clubId = item['id'] as String;
        final count = await _fetchMemberCount(clubId);

        _clubs.add(ReadingClub(
          id: clubId,
          name: item['name'] as String,
          description: item['description'] as String? ?? '',
          icon: _mapIcon(item['icon'] as String? ?? 'groups'),
          iconColor: _mapColor(item['icon_color'] as String? ?? '#8C481A'),
          bgColor: _mapColor(item['bg_color'] as String? ?? '#F9F4EE'),
          memberCount: count,
          rules: rulesList,
          moderator: moderatorName,
        ));
      }

      // 2. Fetch memberships for current user
      final user = AuthService.instance.currentUser;
      _joinedClubs.clear();
      if (user != null) {
        final memberRes = await SupabaseService.client
            .from('club_members')
            .select('club_id')
            .eq('profile_id', user.id);

        for (final item in (memberRes as List)) {
          _joinedClubs.add(item['club_id'] as String);
        }
      }
    } catch (e) {
      debugPrint('Error loadClubs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches real-time member count for a club.
  Future<int> _fetchMemberCount(String clubId) async {
    if (!_isSupabaseInitialized) return 0;
    try {
      final res = await SupabaseService.client
          .from('club_members')
          .select('profile_id')
          .eq('club_id', clubId);
      return (res as List).length;
    } catch (_) {
      return 0;
    }
  }

  /// Loads member profiles for a specific club.
  Future<void> loadMembers(String clubId) async {
    if (!_isSupabaseInitialized) return;
    try {
      final res = await SupabaseService.client
          .from('club_members')
          .select('*, profiles!club_members_profile_id_fkey(name)')
          .eq('club_id', clubId);

      final List<ReadingClubMember> list = [];
      for (final item in (res as List)) {
        final profileName = item['profiles'] != null && item['profiles']['name'] != null
            ? item['profiles']['name'] as String
            : 'Reader';
        final isMe = item['profile_id'] == AuthService.instance.currentUser?.id;
        list.add(ReadingClubMember(
          name: isMe ? 'You' : profileName,
          role: isMe ? 'Moderator' : 'Reader',
        ));
      }
      _clubMembersMap[clubId] = list;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading members: $e');
    }
  }

  // ── Realtime Group Chat Subscriptions ──────────────────────

  /// Subscribes to the Postgres Realtime stream for messages in the given club.
  Future<void> subscribeToChat(String clubId) async {
    if (!_isSupabaseInitialized) return;
    await unsubscribeFromChat();

    // 1. Fetch initial message history
    try {
      final res = await SupabaseService.client
          .from('club_messages')
          .select('*, profiles!club_messages_sender_id_fkey(name)')
          .eq('club_id', clubId)
          .order('created_at', ascending: true);

      final List<ReadingClubMessage> list = [];
      for (final item in (res as List)) {
        final senderName = item['profiles'] != null && item['profiles']['name'] != null
            ? item['profiles']['name'] as String
            : 'Reader';
        final isMe = item['sender_id'] == AuthService.instance.currentUser?.id;

        Book? sharedBook;
        if (item['shared_book'] != null) {
          try {
            sharedBook = Book.fromJson(Map<String, dynamic>.from(item['shared_book']));
          } catch (_) {}
        }

        list.add(ReadingClubMessage(
          id: item['id'] as String,
          sender: isMe ? 'Me' : senderName,
          text: item['text'] as String? ?? '',
          timestamp: DateTime.parse(item['created_at'] as String),
          isMe: isMe,
          sharedBook: sharedBook,
        ));
      }
      _chats[clubId] = list;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }

    // 2. Subscribe to realtime stream
    try {
      _activeChannel = SupabaseService.client
          .channel('public:club_messages:club_id=eq.$clubId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'club_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'club_id',
              value: clubId,
            ),
            callback: (payload) async {
              final newRecord = payload.newRecord;
              final senderId = newRecord['sender_id'] as String;
              final senderName = await _getSenderName(senderId);
              final isMe = senderId == AuthService.instance.currentUser?.id;

              Book? sharedBook;
              if (newRecord['shared_book'] != null) {
                try {
                  sharedBook = Book.fromJson(Map<String, dynamic>.from(newRecord['shared_book']));
                } catch (_) {}
              }

              final msg = ReadingClubMessage(
                id: newRecord['id'] as String,
                sender: isMe ? 'Me' : senderName,
                text: newRecord['text'] as String? ?? '',
                timestamp: DateTime.parse(newRecord['created_at'] as String),
                isMe: isMe,
                sharedBook: sharedBook,
              );

              if (!_chats.containsKey(clubId)) {
                _chats[clubId] = [];
              }
              // Prevent duplicates (local echo vs. realtime stream)
              if (!_chats[clubId]!.any((m) => m.id == msg.id)) {
                _chats[clubId]!.add(msg);
                notifyListeners();
              }
            },
          );
      _activeChannel!.subscribe();
    } catch (e) {
      debugPrint('Error subscribing to realtime: $e');
    }
  }

  /// Removes current realtime subscription channel.
  Future<void> unsubscribeFromChat() async {
    if (!_isSupabaseInitialized) return;
    if (_activeChannel != null) {
      try {
        await SupabaseService.client.removeChannel(_activeChannel!);
      } catch (_) {}
      _activeChannel = null;
    }
  }

  // ── Actions ────────────────────────────────────────────────

  /// Joins or leaves a club in Supabase, updating the membership table.
  ///
  /// Requires a real (non-anonymous) session — every launch gets a guest
  /// anonymous Supabase session via `AuthService.ensureSession`, so checking
  /// `currentUser != null` alone would let guests join clubs and chat.
  Future<void> toggleJoin(String clubId) async {
    if (!_isSupabaseInitialized) return;
    if (!AuthService.instance.isAuthenticated) return;
    final user = AuthService.instance.currentUser!;

    final alreadyJoined = _joinedClubs.contains(clubId);
    try {
      if (alreadyJoined) {
        await SupabaseService.client
            .from('club_members')
            .delete()
            .eq('club_id', clubId)
            .eq('profile_id', user.id);
        _joinedClubs.remove(clubId);
      } else {
        await SupabaseService.client
            .from('club_members')
            .insert({
              'club_id': clubId,
              'profile_id': user.id,
            });
        _joinedClubs.add(clubId);
      }

      // Re-fetch member count and members list
      final newCount = await _fetchMemberCount(clubId);
      final index = _clubs.indexWhere((c) => c.id == clubId);
      if (index != -1) {
        _clubs[index].memberCount = newCount;
      }
      loadMembers(clubId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling club membership: $e');
    }
  }

  /// Sends a message into the chat, optionally with a shared book.
  /// Requires a real (non-anonymous) session — see [toggleJoin].
  Future<void> addMessage(String clubId, String text, {Book? sharedBook}) async {
    if (!_isSupabaseInitialized) return;
    if (!AuthService.instance.isAuthenticated) return;
    final user = AuthService.instance.currentUser!;

    try {
      final res = await SupabaseService.client
          .from('club_messages')
          .insert({
            'club_id': clubId,
            'sender_id': user.id,
            'text': text,
            if (sharedBook != null) 'shared_book': sharedBook.toJson(),
          })
          .select()
          .single();

      final msg = ReadingClubMessage(
        id: res['id'] as String,
        sender: 'Me',
        text: text,
        timestamp: DateTime.parse(res['created_at'] as String),
        isMe: true,
        sharedBook: sharedBook,
      );

      if (!_chats.containsKey(clubId)) {
        _chats[clubId] = [];
      }
      if (!_chats[clubId]!.any((m) => m.id == msg.id)) {
        _chats[clubId]!.add(msg);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error posting message: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────

  Future<String> _getSenderName(String senderId) async {
    if (!_isSupabaseInitialized) return 'Reader';
    if (senderId == AuthService.instance.currentUser?.id) {
      return 'Me';
    }
    if (_profileNames.containsKey(senderId)) {
      return _profileNames[senderId]!;
    }
    try {
      final res = await SupabaseService.client
          .from('profiles')
          .select('name')
          .eq('id', senderId)
          .maybeSingle();
      if (res != null && res['name'] != null) {
        final name = res['name'] as String;
        _profileNames[senderId] = name;
        return name;
      }
    } catch (_) {}
    return 'Reader';
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'menu_book':
        return Icons.menu_book_rounded;
      case 'rocket_launch':
        return Icons.rocket_launch_rounded;
      case 'blur_on':
        return Icons.blur_on_rounded;
      case 'search':
        return Icons.search_rounded;
      case 'history_edu':
        return Icons.history_edu_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  Color _mapColor(String hex) {
    try {
      final cleanHex = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleanHex', radix: 16));
    } catch (_) {
      return Colors.brown;
    }
  }

  /// Creates a new reading club in Supabase and appends it locally.
  Future<void> addClub(ReadingClub club) async {
    if (!_isSupabaseInitialized) return;
    try {
      final user = AuthService.instance.currentUser;
      
      // Map IconData back to string name
      String iconName = 'groups';
      if (club.icon == Icons.menu_book_rounded) {
        iconName = 'menu_book';
      } else if (club.icon == Icons.rocket_launch_rounded) {
        iconName = 'rocket_launch';
      } else if (club.icon == Icons.blur_on_rounded) {
        iconName = 'blur_on';
      } else if (club.icon == Icons.search_rounded) {
        iconName = 'search';
      } else if (club.icon == Icons.history_edu_rounded) {
        iconName = 'history_edu';
      }

      // Convert Color to Hex string (e.g. #FFFFFF)
      final iconColorHex = '#${club.iconColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      final bgColorHex = '#${club.bgColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

      await SupabaseService.client.from('clubs').insert({
        'id': club.id,
        'name': club.name,
        'description': club.description,
        'icon': iconName,
        'icon_color': iconColorHex,
        'bg_color': bgColorHex,
        'moderator_id': user?.id,
        'rules': club.rules,
      });

      _clubs.add(club);
      notifyListeners();
    } catch (e) {
      debugPrint('Error addClub: $e');
    }
  }

  /// Hook for when auth state transitions (resets provider cache and reloads).
  void onAuthChanged() {
    _joinedClubs.clear();
    _chats.clear();
    _clubMembersMap.clear();
    _profileNames.clear();
    unsubscribeFromChat();
    loadClubs();
  }
}
