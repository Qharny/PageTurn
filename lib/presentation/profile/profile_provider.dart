import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_service.dart';

/// Manages the current user's profile, backed by the Supabase `profiles` table.
///
/// Works in both guest/anonymous mode (local defaults) and authenticated mode
/// (fetches & persists to Supabase).
class ProfileProvider extends ChangeNotifier {
  static final ProfileProvider instance = ProfileProvider._internal();
  ProfileProvider._internal();

  // ── State ──────────────────────────────────────────────────
  String _name = 'Reader';
  String _bio = 'Tap "Edit Profile" to add your bio.';
  String? _avatarUrl;
  bool _isLoading = false;
  bool _hasLoadedOnce = false;

  // ── Getters ────────────────────────────────────────────────
  String get name => _name;
  String get bio => _bio;
  String? get avatarUrl => _avatarUrl;
  bool get isLoading => _isLoading;

  /// True when there is no real (non-anonymous) user — the profile is local only.
  bool get isGuest => !AuthService.instance.isAuthenticated;

  // ── Load from Supabase ─────────────────────────────────────

  /// Fetches the profile row for the current user.
  /// Safe to call on every profile screen visit — debounced by [_hasLoadedOnce].
  Future<void> loadProfile({bool forceRefresh = false}) async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    // For anonymous users, skip the network fetch to keep it lightweight.
    if (AuthService.instance.isAnonymous && !forceRefresh) {
      _name = 'Guest Reader';
      _bio = 'Sign in to sync your reading progress across devices.';
      notifyListeners();
      return;
    }

    if (_hasLoadedOnce && !forceRefresh) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        _name = (data['name'] as String?)?.isNotEmpty == true
            ? data['name'] as String
            : _nameFromEmail(user.email);
        _bio = (data['bio'] as String?) ?? '';
        _avatarUrl = data['avatar_url'] as String?;
      } else {
        // Row doesn't exist yet (trigger might not have fired) — upsert defaults.
        _name = _nameFromEmail(user.email);
        _bio = '';
        await _upsert();
      }
      _hasLoadedOnce = true;
    } catch (_) {
      // Fail silently — keep whatever is in memory.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Update ─────────────────────────────────────────────────

  /// Updates name/bio locally and persists to Supabase for authenticated users.
  Future<void> updateProfile({required String name, required String bio}) async {
    _name = name.isEmpty ? _name : name;
    _bio = bio;
    notifyListeners();

    if (!isGuest) {
      await _upsert();
    }
  }

  /// Uploads avatar image bytes to Supabase Storage under 'avatars' bucket,
  /// obtains the public URL, updates the profile row, and refreshes the state.
  Future<void> uploadAvatar(Uint8List bytes, String extension) async {
    final user = AuthService.instance.currentUser;
    if (user == null || isGuest) return;

    _isLoading = true;
    notifyListeners();

    try {
      final path = '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      // Upload to the 'avatars' storage bucket
      await SupabaseService.client.storage.from('avatars').uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );

      // Get public URL
      final publicUrl = SupabaseService.client.storage.from('avatars').getPublicUrl(path);

      _avatarUrl = publicUrl;
      await _upsert();
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Helpers ────────────────────────────────────────────────
  Future<void> _upsert() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;
    try {
      await SupabaseService.client.from('profiles').upsert({
        'id': user.id,
        'name': _name,
        'bio': _bio,
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
      });
    } catch (_) {
      // Network failure — changes already applied locally.
    }
  }

  String _nameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Reader';
    return email.split('@').first;
  }

  /// Called by SessionProvider when auth state changes (e.g. sign in / out).
  void onAuthChanged() {
    _hasLoadedOnce = false;
    _name = 'Reader';
    _bio = '';
    _avatarUrl = null;
    notifyListeners();
    loadProfile();
  }
}
