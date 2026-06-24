import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes.dart';
import '../../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Stack(
        children: [
          // Speckled paper texture background
          const Positioned.fill(
            child: CustomPaint(painter: _SpeckPainter()),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildPageOne(screenHeight),
                      _buildPageTwo(screenHeight),
                      _buildPageThree(screenHeight),
                    ],
                  ),
                ),
                _buildDotIndicator(),
                SizedBox(height: screenHeight * 0.03),
                _buildBottomButtons(),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    if (_currentPage == 0) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        child: const Text(
          'PageTurn',
          style: TextStyle(
            fontFamily: 'Literata',
            fontFamilyFallback: ['serif'],
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF5C3826),
          ),
        ),
      );
    } else if (_currentPage == 1) {
      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PageTurn',
              style: TextStyle(
                fontFamily: 'Literata',
                fontFamilyFallback: ['serif'],
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C3826),
              ),
            ),
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'SKIP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A6B63),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox(height: 56);
    }
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: isActive ? 24 : 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : const Color(0xFFD7CCC8),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButtons() {
    final isLastPage = _currentPage == 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (isLastPage) {
                  _completeOnboarding();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLastPage ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_currentPage == 0)
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'SKIP INTRO',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A6B63),
                  letterSpacing: 1.0,
                ),
              ),
            )
          else if (_currentPage == 2)
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text(
                'EXPLORE AS GUEST',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A6B63),
                  letterSpacing: 1.0,
                ),
              ),
            )
          else
            const SizedBox(height: 36), // maintain consistent spacing
        ],
      ),
    );
  }

  Widget _buildPageOne(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Card 1
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/onboarding_1.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Zero Friction Badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF81C784),
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Zero Friction',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF81C784),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          const Text(
            'Open. Read. Repeat.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3826),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          const Text(
            'No accounts. No sign-ups. Just instant access to thousands of stories, right at your fingertips.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5,
              color: Color(0xFF7A6B63),
              height: 1.5,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  Widget _buildPageTwo(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Card 2: Interactive Widget Card
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Simulated Text Lines
                                _buildSimulatedTextLine(widthFactor: 0.8),
                                const SizedBox(height: 10),
                                _buildSimulatedTextLine(widthFactor: 0.95),
                                const SizedBox(height: 10),
                                // Highlighted row
                                Row(
                                  children: [
                                    _buildSimulatedTextLine(width: 40),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE0B2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Container(
                                        width: 50,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: _buildSimulatedTextLine(height: 6),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildSimulatedTextLine(widthFactor: 0.95),
                                const SizedBox(height: 10),
                                _buildSimulatedTextLine(widthFactor: 0.75),
                                const SizedBox(height: 24),
                                // Waveform
                                const Center(child: _AnimatedWaveform()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Narrated Badge (Top-Right)
                    Positioned(
                      top: -12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7D9D85),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.headset, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'NARRATED',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Highlights Badge (Bottom-Left)
                    Positioned(
                      bottom: -12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFF1E88E5),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'HIGHLIGHTS',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E88E5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Floating Play Button
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          const Text(
            'Immersive Reading.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3826),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          const Text(
            'Listen to human-narrated audiobooks while you follow along with word-by-word highlighting. Perfect for deep focus or learning.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5,
              color: Color(0xFF7A6B63),
              height: 1.5,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  Widget _buildPageThree(double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Card 3
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/onboarding_3.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Downloading Library Badge
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'DOWNLOADING LIBRARY',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C3826),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 110,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(1.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          const Text(
            'Take it Anywhere.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Literata',
              fontFamilyFallback: ['serif'],
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5C3826),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          const Text(
            "Download your entire library for offline access. Whether you're commuting or off-grid, PageTurn never stops.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5,
              color: Color(0xFF7A6B63),
              height: 1.5,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
        ],
      ),
    );
  }

  Widget _buildSimulatedTextLine({
    double? widthFactor,
    double? width,
    double height = 8,
  }) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _AnimatedWaveform extends StatefulWidget {
  const _AnimatedWaveform();

  @override
  State<_AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<_AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heights = [20.0, 36.0, 44.0, 28.0, 40.0, 16.0, 32.0];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(heights.length, (index) {
            final phase = (index / heights.length) * math.pi;
            final scale = 0.4 +
                0.6 *
                    math
                        .sin(_controller.value * 2 * math.pi + phase)
                        .abs();
            final currentHeight = heights[index] * scale;

            return Container(
              width: 4,
              height: currentHeight,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF5C3826),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

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
