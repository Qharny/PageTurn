import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

/// Listens to Supabase auth state changes and notifies the widget tree.
///
/// Provides:
///   • [currentUser]  — the current Supabase [User] or null
///   • [isAuthenticated] / [isAnonymous] — convenience flags
///   • [requireAuth]  — call this to gate any identity-sensitive action;
///                      shows the auth bottom sheet if needed, then runs
///                      the [pendingAction] on success.
class SessionProvider extends ChangeNotifier {
  static final SessionProvider instance = SessionProvider._internal();
  SessionProvider._internal() {
    _sub = AuthService.instance.authStateChanges.listen((state) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _sub;

  // ── Accessors ──────────────────────────────────────────────
  User? get currentUser => AuthService.instance.currentUser;
  bool get isAuthenticated => AuthService.instance.isAuthenticated;
  bool get isAnonymous => AuthService.instance.isAnonymous;
  bool get hasSession => currentUser != null;

  // ── Auth gate ──────────────────────────────────────────────

  /// Show the sign-in / sign-up bottom sheet if the user is not fully
  /// authenticated, then run [pendingAction] once they are.
  ///
  /// Usage:
  /// ```dart
  /// SessionProvider.instance.requireAuth(
  ///   context,
  ///   pendingAction: () => LibraryProvider.instance.addBook(book),
  /// );
  /// ```
  void requireAuth(
    BuildContext context, {
    required VoidCallback pendingAction,
    String? reason, // optional text shown in the sheet header
  }) {
    if (isAuthenticated) {
      pendingAction();
      return;
    }
    _showAuthSheet(context, onSuccess: pendingAction, reason: reason);
  }

  void _showAuthSheet(
    BuildContext context, {
    required VoidCallback onSuccess,
    String? reason,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AuthSheet(
        reason: reason,
        onSuccess: () {
          notifyListeners();
          onSuccess();
        },
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal auth bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AuthSheet extends StatefulWidget {
  const _AuthSheet({this.reason, required this.onSuccess});
  final String? reason;
  final VoidCallback onSuccess;

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  static const _brown = Color(0xFF5C3826);
  static const _bg = Color(0xFFF9F4EE);
  static const _primary = Color(0xFF8C481A);

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_tabs.index == 0) {
        // Sign In
        await AuthService.instance.signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      } else {
        // Sign Up — links to existing anonymous session
        await AuthService.instance.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );
      }
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _error = _friendlyError(e.toString());
        _loading = false;
      });
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login')) return 'Incorrect email or password.';
    if (raw.contains('already registered')) return 'That email is already in use.';
    if (raw.contains('weak-password')) return 'Password must be at least 6 characters.';
    if (raw.contains('network')) return 'Network error — check your connection.';
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 20, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDD4C4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Logo + headline
              const Text(
                'PageTurn',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _brown,
                ),
              ),
              if (widget.reason != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.reason!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF7A6B63),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8DC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    color: _brown,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF7A6B63),
                  labelStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  padding: const EdgeInsets.all(4),
                  tabs: const [Tab(text: 'Sign In'), Tab(text: 'Sign Up')],
                ),
              ),
              const SizedBox(height: 20),

              // Name field (sign-up only)
              AnimatedBuilder(
                animation: _tabs,
                builder: (_, child) {
                  if (_tabs.index != 1) return const SizedBox.shrink();
                  return Column(
                    children: [
                      _buildField(
                        controller: _nameCtrl,
                        label: 'Display name',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                    ],
                  );
                },
              ),

              // Email
              _buildField(
                controller: _emailCtrl,
                label: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter your email';
                  if (!v.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Password
              _buildField(
                controller: _passCtrl,
                label: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF7A6B63),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter your password';
                  if (_tabs.index == 1 && v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: _primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : AnimatedBuilder(
                          animation: _tabs,
                          builder: (_, child) => Text(
                            _tabs.index == 0 ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Continue as guest
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Continue without signing in',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Color(0xFF7A6B63),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: _brown),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF7A6B63), fontFamily: 'Inter'),
        prefixIcon: Icon(icon, color: const Color(0xFF8C481A), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8DFD3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8DFD3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.8),
        ),
      ),
    );
  }
}
