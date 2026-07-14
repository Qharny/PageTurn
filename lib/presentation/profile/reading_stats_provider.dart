import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

/// Real reading-time stats (hours read, daily streak, weekly chart, yearly
/// goal), backed by the Supabase `reading_sessions` table and the
/// `profiles.reading_goal_target` column.
///
/// Session logging (and therefore these stats) only applies to real
/// (non-anonymous) accounts — guests see zeroed-out stats until they sign up,
/// same gate used for club membership.
class ReadingStatsProvider extends ChangeNotifier {
  static final ReadingStatsProvider instance = ReadingStatsProvider._internal();
  ReadingStatsProvider._internal() {
    loadStats();
  }

  int _totalMinutes = 0;
  int _streakDays = 0;
  List<int> _weeklyMinutes = List.filled(7, 0); // oldest -> today
  int _goalTarget = 12;
  bool _isLoading = false;

  int get totalMinutes => _totalMinutes;
  int get hoursRead => _totalMinutes ~/ 60;
  int get streakDays => _streakDays;
  List<int> get weeklyMinutes => List.unmodifiable(_weeklyMinutes);
  int get goalTarget => _goalTarget;
  bool get isLoading => _isLoading;

  bool get _isSupabaseInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> loadStats() async {
    if (!_isSupabaseInitialized) return;
    final user = AuthService.instance.currentUser;
    if (user == null || AuthService.instance.isAnonymous) {
      _totalMinutes = 0;
      _streakDays = 0;
      _weeklyMinutes = List.filled(7, 0);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final sessionsRes = await SupabaseService.client
          .from('reading_sessions')
          .select('minutes, session_date')
          .eq('profile_id', user.id);

      final rows = (sessionsRes as List).cast<Map<String, dynamic>>();

      _totalMinutes = rows.fold<int>(0, (sum, r) => sum + (r['minutes'] as num).toInt());

      // Minutes per calendar day (UTC date string -> minutes).
      final minutesByDate = <String, int>{};
      for (final r in rows) {
        final date = r['session_date'] as String;
        final minutes = (r['minutes'] as num).toInt();
        minutesByDate[date] = (minutesByDate[date] ?? 0) + minutes;
      }

      final today = DateTime.now().toUtc();
      _weeklyMinutes = List.generate(7, (i) {
        final day = today.subtract(Duration(days: 6 - i));
        final key = _dateKey(day);
        return minutesByDate[key] ?? 0;
      });

      _streakDays = _computeStreak(minutesByDate.keys.toSet(), today);

      final profileRes = await SupabaseService.client
          .from('profiles')
          .select('reading_goal_target')
          .eq('id', user.id)
          .maybeSingle();
      if (profileRes != null && profileRes['reading_goal_target'] != null) {
        _goalTarget = profileRes['reading_goal_target'] as int;
      }
    } catch (e) {
      debugPrint('Error loading reading stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs a completed reading session. No-ops for guests/anonymous sessions.
  Future<void> logSession(String bookId, int minutes) async {
    if (!_isSupabaseInitialized || minutes < 1) return;
    if (!AuthService.instance.isAuthenticated) return;
    final user = AuthService.instance.currentUser!;

    try {
      await SupabaseService.client.from('reading_sessions').insert({
        'profile_id': user.id,
        'book_id': bookId,
        'minutes': minutes,
      });
      await loadStats();
    } catch (e) {
      debugPrint('Error logging reading session: $e');
    }
  }

  Future<bool> setGoalTarget(int target) async {
    if (!_isSupabaseInitialized || target < 1) return false;
    final user = AuthService.instance.currentUser;
    if (user == null || AuthService.instance.isAnonymous) return false;

    final previous = _goalTarget;
    _goalTarget = target;
    notifyListeners();

    try {
      await SupabaseService.client
          .from('profiles')
          .update({'reading_goal_target': target}).eq('id', user.id);
      return true;
    } catch (e) {
      debugPrint('Error updating reading goal: $e');
      _goalTarget = previous;
      notifyListeners();
      return false;
    }
  }

  int _computeStreak(Set<String> sessionDates, DateTime today) {
    var cursor = DateTime.utc(today.year, today.month, today.day);
    if (!sessionDates.contains(_dateKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (sessionDates.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Called by SessionProvider when auth state changes (e.g. sign in / out).
  void onAuthChanged() {
    loadStats();
  }
}
