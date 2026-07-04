import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../data/models/book_model.dart';

class ReadAlongScreen extends StatefulWidget {
  const ReadAlongScreen({super.key, required this.book});

  final Book book;

  @override
  State<ReadAlongScreen> createState() => _ReadAlongScreenState();
}

class _ReadAlongScreenState extends State<ReadAlongScreen> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _playbackProgress = 0.25; // mock progress (0.0 to 1.0)
  double _speed = 1.2;
  late AnimationController _waveController;

  int _currentChapter = 1;
  final List<String> _chaptersList = [
    'CHAPTER 1: THE ADVICE',
    'CHAPTER 2: GATSBY\'S HOUSE',
    'CHAPTER 3: THE PARTY',
    'CHAPTER 4: MEET THE BAKER',
    'CHAPTER 5: REUNION',
  ];

  bool _isFlippingMode = true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _waveController.repeat();
      } else {
        _waveController.stop();
      }
    });
  }

  void _changeSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 1.2;
      } else if (_speed == 1.2) {
        _speed = 1.5;
      } else if (_speed == 1.5) {
        _speed = 2.0;
      } else {
        _speed = 1.0;
      }
    });
  }

  void _showChaptersSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chapters',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _chaptersList.length,
                  itemBuilder: (context, index) {
                    final chapterNum = index + 1;
                    final isCurrent = _currentChapter == chapterNum;
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _currentChapter = chapterNum;
                        });
                        Navigator.pop(context);
                      },
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isCurrent ? Icons.play_circle_filled_rounded : Icons.play_circle_outline_rounded,
                        color: isCurrent ? AppTheme.primary : const Color(0xFF9C8F84),
                      ),
                      title: Text(
                        _chaptersList[index],
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? const Color(0xFF5C3826) : const Color(0xFF7A6B63),
                        ),
                      ),
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

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Reader Options',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.text_fields_rounded, color: Color(0xFF5C3826)),
                title: const Text('Text Size', style: TextStyle(fontFamily: 'Inter')),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.remove)),
                    const Text('A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
                  ],
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode_rounded, color: Color(0xFF5C3826)),
                title: const Text('Background Theme', style: TextStyle(fontFamily: 'Inter')),
                trailing: const Text('Warm Paper', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Color(0xFFD35400))),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.menu_book_rounded, color: Color(0xFF5C3826)),
                title: const Text('Transition Style', style: TextStyle(fontFamily: 'Inter')),
                trailing: DropdownButton<bool>(
                  value: _isFlippingMode,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFFD35400)),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD35400),
                  ),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Vertical Scroll')),
                    DropdownMenuItem(value: true, child: Text('Page Flip')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _isFlippingMode = val;
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
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
                  child: _isFlippingMode
                      ? _buildFlippingContent()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 220.0), // Extra bottom padding for player overlay
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildBookParagraphs(),
                          ),
                        ),
                ),
              ],
            ),
          ),
          // Floating Bottom Audio Controls Container
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomPlayerPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF5C3826), size: 26),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'READ-ALONG MODE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9C8F84),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontFamilyFallback: ['serif'],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C3826),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildToggleSwitch(),
        ],
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBE6DD),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'READ-ALONG',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.player,
                arguments: widget.book,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              color: Colors.transparent,
              child: const Text(
                'PLAYER',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7A6B63),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBookParagraphs() {
    final title = widget.book.title.toLowerCase();
    final isGatsby = widget.book.id == 'great_gatsby' || title.contains('gatsby');

    final textStyle = const TextStyle(
      fontFamily: 'Literata',
      fontFamilyFallback: ['serif'],
      fontSize: 17.5,
      color: Color(0xFF5C3826),
      height: 1.68,
    );

    if (isGatsby) {
      return [
        Text(
          'In my younger and more vulnerable years my father gave me some advice that I’ve been turning over in my mind ever since.',
          style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),
        Text(
          '"Whenever you feel like criticizing any one," he told me, "just remember that all the people in this world haven\'t had the advantages that you\'ve had."',
          style: textStyle,
        ),
        const SizedBox(height: 24),
        // Highlighted paragraph matching screenshot
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCDDBC).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFCDDBC),
              width: 1.5,
            ),
          ),
          child: Text(
            'He didn\'t say any more, but we\'ve always been unusually communicative in a reserved way, and I understood that he meant a great deal more than that.',
            style: textStyle,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'In consequence, I\'m inclined to reserve all judgments, a habit that has opened up many curious natures to me and also made me the victim of not a few veteran bores.',
          style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),
        Text(
          'The abnormal mind is quick to detect and attach itself to this quality when it appears in a normal person, and so it came about that in college I was unjustly accused of being a politician, because I was privy to the secret griefs of wild, unknown men.',
          style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 24),
        Text(
          'Most of the confidences were unsought—frequently I have feigned sleep, preoccupation, or a hostile levity when I realized by some unmistakable sign that an intimate revelation was quivering on the horizon.',
          style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.2)),
        ),
      ];
    } else {
      // General fallbacks for other books
      return [
        Text(
          'This is the beginning of the story of "${widget.book.title}". The lines flow elegantly as you listen to the voice of the narrator, guiding you through the pages.',
          style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 24),
        Text(
          'Every character speaks with depth, and the words glow on the screen, creating an immersive, multi-sensory reading experience.',
          style: textStyle,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFCDDBC).withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFCDDBC),
              width: 1.5,
            ),
          ),
          child: Text(
            'The core themes of ${widget.book.title} reflect the complexity of life, echoing choices and landscapes that shape the protagonist\'s journey.',
            style: textStyle,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.book.description,
          style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.5)),
        ),
      ];
    }
  }

  List<Widget> _buildBookPages() {
    final title = widget.book.title.toLowerCase();
    final isGatsby = widget.book.id == 'great_gatsby' || title.contains('gatsby');

    final textStyle = const TextStyle(
      fontFamily: 'Literata',
      fontFamilyFallback: ['serif'],
      fontSize: 18.0,
      color: Color(0xFF5C3826),
      height: 1.68,
    );

    Widget buildPageWrapper(Widget content) {
      return Container(
        color: const Color(0xFFFAF6F0),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 240), // Extra bottom padding for player overlay
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: content,
          ),
        ),
      );
    }

    if (isGatsby) {
      return [
        buildPageWrapper(
          Text(
            'In my younger and more vulnerable years my father gave me some advice that I’ve been turning over in my mind ever since.',
            style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.6)),
          ),
        ),
        buildPageWrapper(
          Text(
            '"Whenever you feel like criticizing any one," he told me, "just remember that all the people in this world haven\'t had the advantages that you\'ve had."',
            style: textStyle,
          ),
        ),
        buildPageWrapper(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCDDBC).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFCDDBC),
                width: 1.5,
              ),
            ),
            child: Text(
              'He didn\'t say any more, but we\'ve always been unusually communicative in a reserved way, and I understood that he meant a great deal more than that.',
              style: textStyle,
            ),
          ),
        ),
        buildPageWrapper(
          Text(
            'In consequence, I\'m inclined to reserve all judgments, a habit that has opened up many curious natures to me and also made me the victim of not a few veteran bores.',
            style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.6)),
          ),
        ),
        buildPageWrapper(
          Text(
            'The abnormal mind is quick to detect and attach itself to this quality when it appears in a normal person, and so it came about that in college I was unjustly accused of being a politician, because I was privy to the secret griefs of wild, unknown men.',
            style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.4)),
          ),
        ),
        buildPageWrapper(
          Text(
            'Most of the confidences were unsought—frequently I have feigned sleep, preoccupation, or a hostile levity when I realized by some unmistakable sign that an intimate revelation was quivering on the horizon.',
            style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.2)),
          ),
        ),
      ];
    } else {
      return [
        buildPageWrapper(
          Text(
            'This is the beginning of the story of "${widget.book.title}". The lines flow elegantly as you listen to the voice of the narrator, guiding you through the pages.',
            style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.6)),
          ),
        ),
        buildPageWrapper(
          Text(
            'Every character speaks with depth, and the words glow on the screen, creating an immersive, multi-sensory reading experience.',
            style: textStyle,
          ),
        ),
        buildPageWrapper(
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFCDDBC).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFCDDBC),
                width: 1.5,
              ),
            ),
            child: Text(
              'The core themes of ${widget.book.title} reflect the complexity of life, echoing choices and landscapes that shape the protagonist\'s journey.',
              style: textStyle,
            ),
          ),
        ),
        buildPageWrapper(
          Text(
            widget.book.description,
            style: textStyle.copyWith(color: const Color(0xFF7A6B63).withValues(alpha: 0.5)),
          ),
        ),
      ];
    }
  }

  Widget _buildFlippingContent() {
    return _PageFlipView(pages: _buildBookPages());
  }

  Widget _buildBottomPlayerPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBE6DD).withValues(alpha: 0.96),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Audio Waveform graph display
          SizedBox(
            height: 48,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WaveformPainter(
                    progress: _playbackProgress,
                    animationValue: _waveController.value,
                    isPlaying: _isPlaying,
                  ),
                  child: Container(),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Times and chapter Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '04:12',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A6B63),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF8B4513),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _chaptersList[_currentChapter - 1],
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8B4513),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '-12:45',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7A6B63),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Play Controls Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded, color: Color(0xFF5C3826), size: 28),
                      onPressed: () {
                        setState(() {
                          _playbackProgress = math.max(0.0, _playbackProgress - 0.05);
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Color(0xFF5C3826), size: 28),
                      onPressed: () {
                        setState(() {
                          if (_currentChapter > 1) _currentChapter--;
                        });
                      },
                    ),
                    // Large Play/Pause FAB
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD35400),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Color(0xFF5C3826), size: 28),
                      onPressed: () {
                        setState(() {
                          if (_currentChapter < _chaptersList.length) _currentChapter++;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_30_rounded, color: Color(0xFF5C3826), size: 28),
                      onPressed: () {
                        setState(() {
                          _playbackProgress = math.min(1.0, _playbackProgress + 0.08);
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Bottom row options: Speed, Chapters, Options
                const Divider(color: Color(0xFFD8D3C8), height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: _changeSpeed,
                        icon: const Icon(Icons.speed_rounded, color: Color(0xFF7A6B63), size: 18),
                        label: Text(
                          '${_speed}x',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3826),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showChaptersSheet,
                        icon: const Icon(Icons.list_rounded, color: Color(0xFF7A6B63), size: 18),
                        label: const Text(
                          'CHAPTERS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3826),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showOptionsSheet,
                        icon: const Icon(Icons.settings_rounded, color: Color(0xFF7A6B63), size: 18),
                        label: const Text(
                          'OPTIONS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5C3826),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A 3D page-flipping view. The top page rotates around its left edge (spine)
/// while the neighbouring page is revealed underneath, giving a realistic book
/// page-turn. Supports both dragging and tapping the left/right edge to turn.
class _PageFlipView extends StatefulWidget {
  const _PageFlipView({required this.pages});

  final List<Widget> pages;

  @override
  State<_PageFlipView> createState() => _PageFlipViewState();
}

class _PageFlipViewState extends State<_PageFlipView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _currentIndex = 0;
  double _value = 0.0; // 0..1 progress of the in-flight flip
  int _direction = 0; // 1 = forward (next page), -1 = backward (previous page)

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..addListener(() {
        setState(() => _value = _controller.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canGoNext => _currentIndex < widget.pages.length - 1;
  bool get _canGoPrev => _currentIndex > 0;

  void _onDragUpdate(DragUpdateDetails details, double width) {
    if (_controller.isAnimating) return;
    if (_direction == 0) {
      if (details.delta.dx < 0) {
        if (!_canGoNext) return;
        _direction = 1;
      } else if (details.delta.dx > 0) {
        if (!_canGoPrev) return;
        _direction = -1;
      } else {
        return;
      }
    }
    setState(() {
      _value = (_value + (-details.delta.dx / width) * _direction)
          .clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details, double width) {
    if (_direction == 0 || _controller.isAnimating) return;
    final velocity = details.primaryVelocity ?? 0.0;
    final bool complete = _direction == 1
        ? (_value > 0.5 || velocity < -600)
        : (_value > 0.5 || velocity > 600);
    _settle(complete);
  }

  void _settle(bool complete) {
    _controller.value = _value;
    _controller
        .animateTo(
          complete ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
      setState(() {
        if (complete) _currentIndex += _direction;
        _direction = 0;
        _value = 0.0;
        _controller.value = 0.0;
      });
    });
  }

  void _flip(int direction) {
    if (_controller.isAnimating || _direction != 0) return;
    if (direction == 1 && !_canGoNext) return;
    if (direction == -1 && !_canGoPrev) return;
    setState(() {
      _direction = direction;
      _value = 0.0;
    });
    _controller.value = 0.0;
    _controller
        .animateTo(
          1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
      setState(() {
        _currentIndex += _direction;
        _direction = 0;
        _value = 0.0;
        _controller.value = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (d) => _onDragUpdate(d, width),
          onHorizontalDragEnd: (d) => _onDragEnd(d, width),
          onTapUp: (d) {
            if (_controller.isAnimating || _direction != 0) return;
            if (d.localPosition.dx > width * 0.72) {
              _flip(1);
            } else if (d.localPosition.dx < width * 0.28) {
              _flip(-1);
            }
          },
          child: Stack(children: _buildLayers()),
        );
      },
    );
  }

  List<Widget> _buildLayers() {
    final pages = widget.pages;

    if (_direction == 0) {
      return [Positioned.fill(child: pages[_currentIndex])];
    }

    if (_direction == 1) {
      // Forward: current page flips left over the spine, next page revealed.
      final angle = -_value * math.pi;
      return [
        Positioned.fill(child: pages[_currentIndex + 1]),
        _spineShadow(_value),
        _flippingPage(pages[_currentIndex], angle),
      ];
    }

    // Backward: previous page rotates back into view on top of the current one.
    final angle = -(1 - _value) * math.pi;
    return [
      Positioned.fill(child: pages[_currentIndex]),
      _flippingPage(pages[_currentIndex - 1], angle),
    ];
  }

  /// Soft shadow cast into the spine of the revealed page, strongest mid-flip.
  Widget _spineShadow(double value) {
    final intensity = math.sin(value * math.pi).clamp(0.0, 1.0);
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: 0.22 * intensity),
                Colors.black.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.35],
            ),
          ),
        ),
      ),
    );
  }

  /// The turning leaf: rotated around its left edge with perspective. Shows the
  /// page content while facing the reader, then its shaded back once past 90°.
  Widget _flippingPage(Widget page, double angle) {
    final showingFront = angle > -math.pi / 2;
    final lift = math.sin(-angle).clamp(0.0, 1.0); // 0 flat, 1 at 90°

    return Positioned.fill(
      child: Transform(
        alignment: Alignment.centerLeft,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY(angle),
        child: showingFront
            ? Stack(
                fit: StackFit.expand,
                children: [
                  page,
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.30 * lift),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : _backOfPage(lift),
      ),
    );
  }

  /// The blank reverse side of a leaf, tinted slightly darker than the paper.
  Widget _backOfPage(double lift) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFEDE6DA), Color(0xFFDCD2C3)],
        ),
      ),
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withValues(alpha: 0.20 * lift),
                Colors.black.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.5],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.progress,
    required this.animationValue,
    required this.isPlaying,
  });

  final double progress;
  final double animationValue;
  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    final paintActive = Paint()
      ..color = const Color(0xFFD35400)
      ..style = PaintingStyle.fill;

    final paintInactive = Paint()
      ..color = const Color(0xFF7A6B63).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    const barWidth = 3.0;
    const spacing = 2.0;
    final totalBars = (size.width / (barWidth + spacing)).floor();

    final activeLimit = (totalBars * progress).floor();

    final rng = math.Random(100);

    for (var i = 0; i < totalBars; i++) {
      // Deterministic bar height
      var baseHeight = 12.0 + rng.nextDouble() * 26.0;

      // Pulse animation if playing
      if (isPlaying) {
        final phase = (i * 0.15) - (animationValue * math.pi * 2);
        baseHeight += math.sin(phase) * 6.0;
      }

      final x = i * (barWidth + spacing) + spacing;
      final y = size.height / 2;

      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: barWidth,
        height: baseHeight,
      );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(1.5));

      canvas.drawRRect(rrect, i <= activeLimit ? paintActive : paintInactive);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isPlaying != isPlaying;
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
