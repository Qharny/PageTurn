import 'package:just_audio/just_audio.dart';

import '../core/errors/app_exception.dart';
import '../domain/entities/audiobook.dart';

/// Thin wrapper around `just_audio` for streaming LibriVox MP3 chapters.
/// Kept separate from [AudioPlayerScreen] so the screen's existing UI/mock
/// state stays untouched when no real chapters are available.
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  List<AudiobookChapter> _chapters = [];

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;

  Duration get position => _player.position;
  bool get isPlaying => _player.playing;
  AudiobookChapter? get currentChapter =>
      (_player.currentIndex != null && _player.currentIndex! < _chapters.length)
          ? _chapters[_player.currentIndex!]
          : null;

  Future<void> loadChapters(List<AudiobookChapter> chapters, {int startIndex = 0}) async {
    if (chapters.isEmpty) {
      throw const NetworkException('This audiobook has no playable sections.');
    }
    _chapters = List.of(chapters)..sort((a, b) => a.order.compareTo(b.order));
    try {
      await _player.setAudioSources(
        _chapters.map((c) => AudioSource.uri(Uri.parse(c.listenUrl))).toList(),
        initialIndex: startIndex,
      );
    } catch (e) {
      throw NetworkException('Could not load this audiobook\'s audio.', e);
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> seek(Duration position, {int? chapterIndex}) => _player.seek(position, index: chapterIndex);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
  Future<void> skipToNext() => _player.seekToNext();
  Future<void> skipToPrevious() => _player.seekToPrevious();

  Future<void> dispose() => _player.dispose();
}
