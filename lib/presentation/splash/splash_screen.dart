import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes.dart';
import '../../theme.dart';

/// Animated splash screen for PageTurn.
///
/// Shows the book Lottie animation over a speckled cream backdrop, the brand
/// wordmark, a tagline and a loading progress bar. Once the intro completes it
/// replaces itself with the home route.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Total time the splash is shown before routing onward.
  static const Duration _splashDuration = Duration(milliseconds: 3600);

  late final AnimationController _progressController;
  late final AnimationController _contentController;

  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: _splashDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _goToHome();
        }
      });

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeIn = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<double>(begin: 32, end: 0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOutBack),
    );

    _contentController.forward();
    _progressController.forward();
  }

  Future<void> _goToHome() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted) return;
    if (onboardingCompleted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Stack(
        children: [
          // Subtle paper-speckle texture behind everything.
          const Positioned.fill(
            child: CustomPaint(painter: _SpeckPainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Book animation.
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (_, child) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: child,
                    ),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Lottie.asset(
                      'assets/lottie/book.json',
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // Wordmark + underline.
                AnimatedBuilder(
                  animation: _contentController,
                  builder: (context, child) => Opacity(
                    opacity: _fadeIn.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideUp.value),
                      child: child,
                    ),
                  ),
                  child: const _Wordmark(),
                ),

                const Spacer(flex: 4),

                // Tagline.
                AnimatedBuilder(
                  animation: _fadeIn,
                  builder: (_, child) => Opacity(
                    opacity: _fadeIn.value,
                    child: child,
                  ),
                  child: const _Tagline(),
                ),

                const SizedBox(height: 24),

                // Loading progress bar.
                AnimatedBuilder(
                  animation: _fadeIn,
                  builder: (_, child) => Opacity(
                    opacity: (_fadeIn.value * 2).clamp(0.0, 1.0),
                    child: child,
                  ),
                  child: _ProgressBar(animation: _progressController),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "PageTurn" brand wordmark with a simple, short, rounded orange underline.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'PageTurn',
          style: TextStyle(
            fontFamily: 'Literata',
            fontFamilyFallback: ['serif'],
            fontSize: 35,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C3826), // brandBrown
            letterSpacing: 0.2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        // Underline
        Container(
          width: 50,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }
}

/// Tagline at the bottom: "Read. • Listen. • Discover."
class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'Literata',
      fontFamilyFallback: ['serif'],
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      color: Color(0xFF5C3826), // brandBrown
      letterSpacing: 0.2,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Read.', style: textStyle),
        _buildDot(),
        const Text('Listen.', style: textStyle),
        _buildDot(),
        const Text('Discover.', style: textStyle),
      ],
    );
  }

  Widget _buildDot() {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFD7CCC8), // Light brown dot matching UI style
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Thin rounded progress bar driven by [animation] (0 -> 1).
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const width = 180.0;
    return Center(
      child: SizedBox(
        width: width,
        height: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 4,
                    color: const Color(0xFFEBE5DC), // Match image track color
                  ),
                  FractionallySizedBox(
                    widthFactor: animation.value.clamp(0.0, 1.0),
                    child: Container(
                      height: 4,
                      color: AppTheme.primary, // Fill color: Orange
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Paints a sparse field of faint specks to mimic the textured paper backdrop.
class _SpeckPainter extends CustomPainter {
  const _SpeckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..color = AppTheme.secondary.withValues(alpha: 0.05);

    const speckCount = 90;
    for (var i = 0; i < speckCount; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.1 + 0.3;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpeckPainter oldDelegate) => false;
}