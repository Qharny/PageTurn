import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

/// Thrown by [AuthService.signUp] when linking an email to an anonymous
/// session succeeds but the account is still anonymous afterward — Supabase
/// requires the confirmation link to be clicked before the upgrade completes.
class AuthConfirmationPendingException implements Exception {
  const AuthConfirmationPendingException();
  @override
  String toString() =>
      'We sent a confirmation link to your email. Please confirm it to finish signing up.';
}

/// Wraps Supabase Auth for the guest-first / lazy-auth pattern.
///
/// Flow:
///   1. App launch → [ensureSession]: signs in anonymously if no session exists.
///   2. Later, when the user triggers an identity-sensitive action,
///      the UI calls [signUp] or [signIn] which uses [linkIdentity] /
///      [signInWithPassword] to upgrade the anonymous session transparently.
///   3. [signOut] returns to an anonymous session (or you can navigate to home
///      to let [ensureSession] create a fresh one on next launch).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool get _isSupabaseInitialized {
    try {
      Supabase.instance;
      return true;
    } catch (_) {
      return false;
    }
  }

  SupabaseClient? get _client {
    if (!_isSupabaseInitialized) return null;
    return SupabaseService.client;
  }

  // ── Current user ──────────────────────────────────────────
  User? get currentUser => _client?.auth.currentUser;

  /// True when there is a real (non-anonymous) authenticated user.
  bool get isAuthenticated =>
      _isSupabaseInitialized && currentUser != null && !currentUser!.isAnonymous;

  /// True when the session is anonymous (launched without login).
  bool get isAnonymous =>
      _isSupabaseInitialized && currentUser != null && currentUser!.isAnonymous;

  // ── Auth state stream ──────────────────────────────────────
  Stream<AuthState> get authStateChanges =>
      _client?.auth.onAuthStateChange ?? const Stream.empty();

  // ── Session management ─────────────────────────────────────

  /// Call once at app launch (in SplashScreen) to ensure every user —
  /// even first-timers — has a Supabase session.
  ///
  /// - If a session already exists (returning user), does nothing.
  /// - If no session, signs in anonymously so the user gets a UUID
  ///   and a `profiles` row from the trigger, all without any friction.
  Future<void> ensureSession() async {
    final client = _client;
    if (client == null) return;
    if (client.auth.currentSession != null) return;
    await client.auth.signInAnonymously();
  }

  // ── Sign Up ────────────────────────────────────────────────

  /// Upgrades an anonymous session → permanent account.
  ///
  /// Uses [linkIdentity] when the current user is anonymous so all existing
  /// library / progress data is preserved under the same UUID.
  /// Falls back to a regular [signUp] if somehow there is no session.
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) return;
    if (isAnonymous) {
      // Link the existing anonymous user to an email identity.
      // The user's UUID stays the same — all their data is preserved.
      await client.auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      // Supabase keeps the session anonymous until the confirmation link
      // is clicked, even though the call above succeeded.
      if (isAnonymous) {
        throw const AuthConfirmationPendingException();
      }
    } else {
      await client.auth.signUp(email: email, password: password);
    }
  }

  // ── Sign In ────────────────────────────────────────────────

  /// Signs in with email + password.
  ///
  /// If the current session is anonymous the old anonymous account is
  /// effectively abandoned and the user gets their permanent account's UUID.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) return;
    await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Sign Out ───────────────────────────────────────────────

  /// Signs out the current user.  After this, call [ensureSession] (or let
  /// the SplashScreen do it) to create a new anonymous session.
  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }

  // ── Password reset ─────────────────────────────────────────
  Future<void> resetPassword({required String email}) async {
    final client = _client;
    if (client == null) return;
    await client.auth.resetPasswordForEmail(email);
  }
}
