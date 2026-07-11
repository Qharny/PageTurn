import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../data/models/book_model.dart';
import '../common/widgets/book_cover.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.book});

  final Book book;

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _playbackProgress = 0.35; // mock progress (0.0 to 1.0), used when no real audio is attached
  double _speed = 1.25;
  String _selectedPersona = 'BRITISH SCHOLAR';
  late AnimationController _barsController;

  // Real playback — only active when widget.book.audioChapters is populated
  // (LibriVox-sourced audiobooks). Demo/mock books keep the old animated
  // placeholder behaviour untouched below.
  AudioService? _audioService;
  Duration _realPosition = Duration.zero;
  Duration _realDuration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<bool>? _playingSub;

  bool get _hasRealAudio => widget.book.audioChapters != null && widget.book.audioChapters!.isNotEmpty;

  // AI-narration (text-to-speech) — active for text ebooks with a
  // downloaded/imported EPUB but no real human narration available.
  TtsService? _ttsService;
  bool _ttsPreparing = false;
  bool get _hasTextContent =>
      !_hasRealAudio && widget.book.localFilePath != null && widget.book.localFilePath!.isNotEmpty;
  bool get _hasLiveTrack => _hasRealAudio || _hasTextContent;

  List<String> get _personas => ttsPersonas.map((p) => p.name).toList();

  TtsPersona _personaFor(String name) =>
      ttsPersonas.firstWhere((p) => p.name == name, orElse: () => ttsPersonas.first);

  @override
  void initState() {
    super.initState();
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (_hasRealAudio) {
      _initRealAudio();
    } else if (_hasTextContent) {
      _initTts();
    }
  }

  Future<void> _initRealAudio() async {
    final service = AudioService();
    _audioService = service;
    _positionSub = service.positionStream.listen((p) {
      if (mounted) setState(() => _realPosition = p);
    });
    _durationSub = service.durationStream.listen((d) {
      if (mounted) setState(() => _realDuration = d ?? Duration.zero);
    });
    _playingSub = service.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
        if (playing) {
          _barsController.repeat();
        } else {
          _barsController.stop();
        }
      }
    });
    try {
      await service.loadChapters(widget.book.audioChapters!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'.replaceFirst('AppException: ', ''))),
        );
      }
    }
  }

  Future<void> _initTts() async {
    setState(() => _ttsPreparing = true);
    final service = TtsService();
    _ttsService = service;
    _positionSub = service.positionStream.listen((p) {
      if (mounted) setState(() => _realPosition = p);
    });
    _durationSub = service.durationStream.listen((d) {
      if (mounted) setState(() => _realDuration = d ?? Duration.zero);
    });
    _playingSub = service.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
        if (playing) {
          _barsController.repeat();
        } else {
          _barsController.stop();
        }
      }
    });
    try {
      final data = await compute(prepareTtsChapters, widget.book.localFilePath!);
      service.loadChapters(data.titles, data.texts);
      await service.setPersona(_personaFor(_selectedPersona));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not prepare this book for AI narration.')),
        );
      }
    } finally {
      if (mounted) setState(() => _ttsPreparing = false);
    }
  }

  @override
  void dispose() {
    _barsController.dispose();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playingSub?.cancel();
    _audioService?.dispose();
    _ttsService?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ttsPreparing) return;
    final audio = _audioService;
    if (audio != null) {
      audio.isPlaying ? audio.pause() : audio.play();
      return;
    }
    final tts = _ttsService;
    if (tts != null) {
      tts.isPlaying ? tts.pause() : tts.play();
      return;
    }
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _barsController.repeat();
      } else {
        _barsController.stop();
      }
    });
  }

  void _changeSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 1.25;
      } else if (_speed == 1.25) {
        _speed = 1.5;
      } else if (_speed == 1.5) {
        _speed = 2.0;
      } else {
        _speed = 1.0;
      }
    });
    _audioService?.setSpeed(_speed);
    _ttsService?.setSpeed(_speed);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _showPersonasSheet() {
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
                'AI Voice Persona',
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
                  itemCount: _personas.length,
                  itemBuilder: (context, index) {
                    final persona = _personas[index];
                    final isCurrent = _selectedPersona == persona;
                    return ListTile(
                      onTap: () {
                        setState(() {
                          _selectedPersona = persona;
                        });
                        _ttsService?.setPersona(_personaFor(persona));
                        Navigator.pop(context);
                      },
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isCurrent ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: isCurrent ? AppTheme.primary : const Color(0xFF9C8F84),
                      ),
                      title: Text(
                        persona,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      body: Stack(
        children: [
          // Speckled paper background
          const Positioned.fill(
            child: CustomPaint(painter: _SpeckPainter()),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        _buildCoverFrame(),
                        const SizedBox(height: 32),
                        _buildMetadata(),
                        const SizedBox(height: 20),
                        _buildPersonaPill(),
                        const SizedBox(height: 36),
                        _buildWaveTrack(),
                        const SizedBox(height: 32),
                        _buildPlayControls(),
                        const SizedBox(height: 32),
                        _buildBottomOptionsBar(),
                        const SizedBox(height: 28),
                        _buildSwitchActionRow(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5C3826), size: 30),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'NOW PLAYING',
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
                  _ttsPreparing
                      ? 'Preparing AI narration…'
                      : _audioService?.currentChapter?.title ??
                          _ttsService?.currentChapterTitle ??
                          'Chapter 4: The Alchemist\'s Secret',
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
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF5C3826), size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCoverFrame() {
    return Container(
      width: 250,
      height: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cover Image Display
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BookCover(
              coverAsset: widget.book.coverAsset,
              coverUrl: widget.book.coverUrl,
              title: widget.book.title,
              width: 250,
              height: 340,
              borderRadius: 0,
            ),
          ),
          // Pulsing audio wave status icon overlaid at the bottom center of card
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(4, (index) {
                    return AnimatedBuilder(
                      animation: _barsController,
                      builder: (context, child) {
                        double scale = 1.0;
                        if (_isPlaying) {
                          final waveVal = math.sin((_barsController.value * math.pi * 2) + (index * 1.5));
                          scale = 0.4 + (waveVal.abs() * 0.6);
                        }
                        return Container(
                          width: 3.5,
                          height: 16 * scale,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata() {
    return Column(
      children: [
        Text(
          widget.book.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Literata',
            fontFamilyFallback: ['serif'],
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF5C3826),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _hasRealAudio
              ? widget.book.author
              : _hasTextContent
                  ? '${widget.book.author} • AI narration'
                  : '${widget.book.author} • Narrated by Simon Vance',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            color: Color(0xFF7A6B63),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonaPill() {
    return GestureDetector(
      onTap: _showPersonasSheet,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEBE6DD),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic_rounded,
              color: Color(0xFF8B4513),
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'AI PERSONA: $_selectedPersona',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF8B4513),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF8B4513),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveTrack() {
    return Column(
      children: [
        // Beautiful horizontal wave player bar with handle indicator
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPos = box.globalToLocal(details.globalPosition);
            final double width = box.size.width - 48; // padding margins
            final target = ((localPos.dx - 24) / width).clamp(0.0, 1.0);
            if (_hasLiveTrack && _realDuration > Duration.zero) {
              if (_hasRealAudio) {
                _audioService?.seek(_realDuration * target);
              } else {
                _ttsService?.seek(_realDuration * target);
              }
            } else {
              setState(() => _playbackProgress = target);
            }
          },
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _barsController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _WaveTrackPainter(
                    progress: _currentProgress,
                    animationValue: _barsController.value,
                    isPlaying: _isPlaying,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _hasLiveTrack ? _formatDuration(_realPosition) : '12:45',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A6B63),
              ),
            ),
            Text(
              _hasLiveTrack ? '-${_formatDuration(_realDuration - _realPosition)}' : '-24:15',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A6B63),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double get _currentProgress {
    if (_hasLiveTrack && _realDuration > Duration.zero) {
      return (_realPosition.inMilliseconds / _realDuration.inMilliseconds).clamp(0.0, 1.0);
    }
    return _playbackProgress;
  }

  Widget _buildPlayControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded, color: Color(0xFF5C3826), size: 28),
          onPressed: _hasLiveTrack
              ? () => _hasRealAudio ? _audioService?.skipToPrevious() : _ttsService?.skipToPrevious()
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.replay_10_rounded, color: Color(0xFF5C3826), size: 28),
          onPressed: () {
            if (_hasLiveTrack) {
              final target = _realPosition - const Duration(seconds: 10);
              final clamped = target.isNegative ? Duration.zero : target;
              _hasRealAudio ? _audioService?.seek(clamped) : _ttsService?.seek(clamped);
            } else {
              setState(() {
                _playbackProgress = math.max(0.0, _playbackProgress - 0.05);
              });
            }
          },
        ),
        // Play/Pause circular FAB
        GestureDetector(
          onTap: _togglePlay,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFD35400),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: _ttsPreparing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.forward_30_rounded, color: Color(0xFF5C3826), size: 28),
          onPressed: () {
            if (_hasLiveTrack) {
              final target = _realPosition + const Duration(seconds: 30);
              final clamped = target > _realDuration ? _realDuration : target;
              _hasRealAudio ? _audioService?.seek(clamped) : _ttsService?.seek(clamped);
            } else {
              setState(() {
                _playbackProgress = math.min(1.0, _playbackProgress + 0.08);
              });
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next_rounded, color: Color(0xFF5C3826), size: 28),
          onPressed: _hasLiveTrack
              ? () => _hasRealAudio ? _audioService?.skipToNext() : _ttsService?.skipToNext()
              : null,
        ),
      ],
    );
  }

  Widget _buildBottomOptionsBar() {
    final buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Flexible(
          child: TextButton.icon(
            style: buttonStyle,
            onPressed: _changeSpeed,
            icon: const Icon(Icons.speed_rounded, color: Color(0xFF7A6B63), size: 16),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_speed}X',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: TextButton.icon(
            style: buttonStyle,
            onPressed: () {},
            icon: const Icon(Icons.timer_rounded, color: Color(0xFF7A6B63), size: 16),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'TIMER',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: TextButton.icon(
            style: buttonStyle,
            onPressed: () {},
            icon: const Icon(Icons.list_rounded, color: Color(0xFF7A6B63), size: 16),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'CHAPTERS',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: TextButton.icon(
            style: buttonStyle,
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border_rounded, color: Color(0xFF7A6B63), size: 16),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'CLIP',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchActionRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.readAlong,
                  arguments: widget.book,
                );
              },
              icon: const Icon(Icons.menu_book_rounded, color: Color(0xFF5C3826), size: 18),
              label: const Text(
                'Switch to Read-Along',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5C3826),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE2DDD5), width: 1.5),
                backgroundColor: const Color(0xFFEBE6DD).withValues(alpha: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEBE6DD).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2DDD5), width: 1.5),
          ),
          child: IconButton(
            icon: const Icon(Icons.cast_rounded, color: Color(0xFF5C3826), size: 20),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

class _WaveTrackPainter extends CustomPainter {
  const _WaveTrackPainter({
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

    const barWidth = 4.0;
    const spacing = 3.0;
    final totalBars = (size.width / (barWidth + spacing)).floor();

    final activeLimit = (totalBars * progress).floor();

    final rng = math.Random(50);

    for (var i = 0; i < totalBars; i++) {
      var baseHeight = 8.0 + rng.nextDouble() * 28.0;

      // Pulse animation if playing
      if (isPlaying) {
        final phase = (i * 0.12) - (animationValue * math.pi * 2);
        baseHeight += math.sin(phase) * 5.0;
      }

      final x = i * (barWidth + spacing) + spacing;
      final y = size.height / 2;

      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: barWidth,
        height: baseHeight,
      );

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2.0));

      canvas.drawRRect(rrect, i <= activeLimit ? paintActive : paintInactive);

      // Draw Playback Head handle circle
      if (i == activeLimit) {
        final paintHandle = Paint()
          ..color = const Color(0xFFD35400)
          ..style = PaintingStyle.fill;
        final paintBorder = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawCircle(Offset(x, y), 8.0, paintHandle);
        canvas.drawCircle(Offset(x, y), 8.0, paintBorder);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaveTrackPainter oldDelegate) {
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
