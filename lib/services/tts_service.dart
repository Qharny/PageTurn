import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:html/parser.dart' as html_parser;

import '../data/sources/local/epub_parser.dart';

/// A pitch/rate/locale preset selectable from the player's "AI Persona" pill.
/// On-device TTS engines don't expose distinct named voices consistently
/// across manufacturers, so personas are differentiated by pitch, rate and
/// regional accent (en-GB vs en-US) rather than a specific voice name.
class TtsPersona {
  final String name;
  final double pitch;
  final double rate;
  final String languageCode;

  const TtsPersona({
    required this.name,
    required this.pitch,
    required this.rate,
    required this.languageCode,
  });
}

const List<TtsPersona> ttsPersonas = [
  TtsPersona(name: 'BRITISH SCHOLAR', pitch: 1.0, rate: 0.45, languageCode: 'en-GB'),
  TtsPersona(name: 'COZY STORYTELLER', pitch: 1.08, rate: 0.4, languageCode: 'en-US'),
  TtsPersona(name: 'DEEP BARITONE', pitch: 0.72, rate: 0.42, languageCode: 'en-US'),
  TtsPersona(name: 'CLASSIC NARRATOR', pitch: 0.92, rate: 0.47, languageCode: 'en-GB'),
];

/// Strips an EPUB chapter's XHTML markup down to plain readable text.
String stripHtmlToText(String html) {
  final document = html_parser.parse(html);
  return (document.body?.text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

class TtsChapterData {
  final List<String> titles;
  final List<String> texts;
  const TtsChapterData(this.titles, this.texts);
}

/// Top-level so it can run on a background isolate via `compute()` — parsing
/// and HTML-stripping a large EPUB (hundreds of chapters) synchronously on
/// the UI isolate can block the main thread for many seconds.
TtsChapterData prepareTtsChapters(String epubPath) {
  final parsed = parseEpubFile(epubPath);
  final titles = parsed.chapters.map((c) => c.title).toList();
  final texts = parsed.chapters.map((c) => stripHtmlToText(c.contentHtml)).toList();
  return TtsChapterData(titles, texts);
}

/// Thin wrapper around `flutter_tts` for reading ebook chapters aloud.
/// Mirrors [AudioService]'s shape (position/duration/playing streams, one
/// "track" per chapter) so [AudioPlayerScreen] can drive it through the same
/// UI it uses for real LibriVox audio.
class TtsService {
  final FlutterTts _tts = FlutterTts();

  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _playingController = StreamController<bool>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<bool> get playingStream => _playingController.stream;

  List<String> _chapterTitles = [];
  List<String> _chapterTexts = [];
  int _chapterIndex = 0;
  int _charOffset = 0;
  Duration _chapterDuration = Duration.zero;
  bool _isPlaying = false;

  static const _wordsPerMinute = 155;

  TtsPersona _persona = ttsPersonas.first;
  double _speedMultiplier = 1.0;

  bool get isPlaying => _isPlaying;
  String? get currentChapterTitle => _chapterTitles.isEmpty ? null : _chapterTitles[_chapterIndex];
  String get _currentChapterText => _chapterTexts.isEmpty ? '' : _chapterTexts[_chapterIndex];

  TtsService() {
    _tts.awaitSpeakCompletion(true);
    _tts.setProgressHandler((text, start, end, word) {
      _positionController.add(_durationForChars(_charOffset + start));
    });
    _tts.setCompletionHandler(() {
      if (_chapterIndex < _chapterTexts.length - 1) {
        skipToNext();
      } else {
        _isPlaying = false;
        _playingController.add(false);
      }
    });
    _tts.setCancelHandler(() {
      _isPlaying = false;
      _playingController.add(false);
    });
    _tts.setErrorHandler((msg) {
      _isPlaying = false;
      _playingController.add(false);
    });
  }

  Future<void> setPersona(TtsPersona persona) async {
    _persona = persona;
    await _tts.setPitch(persona.pitch);
    await _applyRate();
    try {
      await _tts.setLanguage(persona.languageCode);
    } catch (_) {
      // Falls back to the device's default TTS language if unsupported.
    }
  }

  /// [multiplier] mirrors the player's 1.0/1.25/1.5/2.0 speed control,
  /// applied on top of the current persona's base reading rate.
  Future<void> setSpeed(double multiplier) async {
    _speedMultiplier = multiplier;
    await _applyRate();
  }

  Future<void> _applyRate() async {
    await _tts.setSpeechRate((_persona.rate * _speedMultiplier).clamp(0.1, 1.0));
  }

  void loadChapters(List<String> titles, List<String> texts, {int startIndex = 0}) {
    if (texts.isEmpty) return;
    _chapterTitles = titles;
    _chapterTexts = texts;
    _chapterIndex = startIndex.clamp(0, texts.length - 1);
    _charOffset = 0;
    _updateDurationForCurrentChapter();
  }

  void _updateDurationForCurrentChapter() {
    final wordCount = _currentChapterText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    _chapterDuration = Duration(seconds: ((wordCount / _wordsPerMinute) * 60).round());
    _durationController.add(_chapterDuration);
    _positionController.add(Duration.zero);
  }

  Duration _durationForChars(int chars) {
    final total = _currentChapterText.isEmpty ? 1 : _currentChapterText.length;
    final fraction = (chars / total).clamp(0.0, 1.0);
    return Duration(milliseconds: (_chapterDuration.inMilliseconds * fraction).round());
  }

  Future<void> play() async {
    // Some chapters (cover pages, blank front matter) have no readable
    // text — skip forward to the next chapter that actually has content.
    while (_currentChapterText.trim().isEmpty && _chapterIndex < _chapterTexts.length - 1) {
      _chapterIndex++;
      _charOffset = 0;
      _updateDurationForCurrentChapter();
    }
    if (_currentChapterText.trim().isEmpty) return;
    _isPlaying = true;
    _playingController.add(true);
    final start = _charOffset.clamp(0, _currentChapterText.length);
    await _tts.speak(_currentChapterText.substring(start));
  }

  Future<void> pause() async {
    _isPlaying = false;
    _playingController.add(false);
    await _tts.stop();
  }

  Future<void> seek(Duration position) async {
    final totalMs = _chapterDuration.inMilliseconds == 0 ? 1 : _chapterDuration.inMilliseconds;
    final fraction = (position.inMilliseconds / totalMs).clamp(0.0, 1.0);
    _charOffset = (_currentChapterText.length * fraction).round();
    _positionController.add(_durationForChars(_charOffset));
    if (_isPlaying) {
      await _tts.stop();
      await play();
    }
  }

  Future<void> skipToNext() async {
    if (_chapterIndex >= _chapterTexts.length - 1) return;
    final wasPlaying = _isPlaying;
    await _tts.stop();
    _chapterIndex++;
    _charOffset = 0;
    _updateDurationForCurrentChapter();
    if (wasPlaying) await play();
  }

  Future<void> skipToPrevious() async {
    if (_chapterIndex <= 0) return;
    final wasPlaying = _isPlaying;
    await _tts.stop();
    _chapterIndex--;
    _charOffset = 0;
    _updateDurationForCurrentChapter();
    if (wasPlaying) await play();
  }

  Future<void> dispose() async {
    await _tts.stop();
    await _positionController.close();
    await _durationController.close();
    await _playingController.close();
  }
}
