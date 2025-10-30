import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/bible_verse.dart';

/// Text-to-Speech service for Bible audio playback
///
/// Features:
/// - Play/pause/stop chapter audio
/// - Adjustable speech rate (0.5x - 2.0x)
/// - Verse-by-verse progress tracking
/// - Background audio support
/// - Automatic cleanup on completion
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();

  // State management
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isPaused = false;
  List<BibleVerse> _currentVerses = [];
  int _currentVerseIndex = -1;
  Completer<void>? _speakCompleter;

  // Configurable settings
  static const String _keyTtsRate = 'tts_speech_rate';
  static const List<double> speedPresets = [0.75, 1.0, 1.25]; // Slow, Normal, Fast
  static const double _defaultRate = 1.0; // Normal speed
  static const int _defaultSpeedIndex = 1; // Default to 1.0x (index 1)
  double _speechRate = _defaultRate;
  int _currentSpeedIndex = _defaultSpeedIndex;

  // Callbacks for UI updates
  Function(int verseIndex)? onVerseChanged;
  Function(bool isPlaying)? onPlayStateChanged;
  Function()? onPlaybackComplete;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentVerseIndex => _currentVerseIndex;
  int get totalVerses => _currentVerses.length;
  double get speechRate => _speechRate;

  /// Initialize TTS engine with platform-specific settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      developer.log('[TtsService] Initializing TTS engine', name: 'TtsService');

      // Platform-specific initialization
      await _tts.setLanguage("en-US");
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Load saved speech rate and apply it
      await _loadSpeechRate();
      developer.log('[TtsService] 🔊 APPLYING SPEECH RATE: ${_speechRate}x (index: $_currentSpeedIndex)', name: 'TtsService');
      await _tts.setSpeechRate(_speechRate); // CRITICAL: Apply loaded rate to engine
      developer.log('[TtsService] ✅ Speech rate applied successfully', name: 'TtsService');

      // iOS-specific: Enable background audio
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.spokenAudio,
      );

      // Set up completion handler
      _tts.setCompletionHandler(() {
        developer.log('[TtsService] Verse completed', name: 'TtsService');
        _speakCompleter?.complete();
      });

      // Set up error handler
      _tts.setErrorHandler((msg) {
        developer.log('[TtsService] Error: $msg', name: 'TtsService', error: msg);
        _speakCompleter?.completeError(msg);
      });

      _isInitialized = true;
      developer.log('[TtsService] Initialization complete', name: 'TtsService');
    } catch (e) {
      developer.log('[TtsService] Initialization failed: $e', name: 'TtsService', error: e);
      rethrow;
    }
  }

  /// Play chapter from the beginning
  Future<void> playChapter(List<BibleVerse> verses, {int startIndex = 0}) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (verses.isEmpty) {
      developer.log('[TtsService] No verses to play', name: 'TtsService');
      return;
    }

    developer.log('[TtsService] Playing chapter: ${verses.length} verses from index $startIndex', name: 'TtsService');

    _currentVerses = verses;
    _currentVerseIndex = startIndex;
    _isPlaying = true;
    _isPaused = false;

    onPlayStateChanged?.call(true);

    await _playFromCurrentIndex();
  }

  /// Internal method to play verses sequentially from current index
  Future<void> _playFromCurrentIndex() async {
    try {
      for (int i = _currentVerseIndex; i < _currentVerses.length; i++) {
        if (!_isPlaying || _isPaused) {
          developer.log('[TtsService] Playback stopped/paused at verse $i', name: 'TtsService');
          break;
        }

        _currentVerseIndex = i;
        onVerseChanged?.call(i);

        final verse = _currentVerses[i];
        final textToSpeak = verse.text; // Just the verse text, no number

        developer.log('[TtsService] Speaking verse ${verse.verseNumber}', name: 'TtsService');

        // Create new completer for this verse
        _speakCompleter = Completer<void>();

        await _tts.speak(textToSpeak);

        // Wait for completion
        await _speakCompleter!.future;

        // Brief pause between verses
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Playback complete
      if (_isPlaying && !_isPaused && _currentVerseIndex == _currentVerses.length - 1) {
        developer.log('[TtsService] Playback complete', name: 'TtsService');
        await stop();
        onPlaybackComplete?.call();
      }
    } catch (e) {
      developer.log('[TtsService] Playback error: $e', name: 'TtsService', error: e);
      await stop();
    }
  }

  /// Pause playback (can be resumed)
  Future<void> pause() async {
    if (!_isPlaying || _isPaused) return;

    developer.log('[TtsService] Pausing playback', name: 'TtsService');

    _isPaused = true;
    await _tts.stop(); // flutter_tts doesn't have native pause, so we stop

    onPlayStateChanged?.call(false);
  }

  /// Resume playback from where it was paused
  Future<void> resume() async {
    if (!_isPaused) return;

    developer.log('[TtsService] Resuming playback from verse $_currentVerseIndex', name: 'TtsService');

    _isPaused = false;
    _isPlaying = true;

    onPlayStateChanged?.call(true);

    // Continue from current verse
    await _playFromCurrentIndex();
  }

  /// Stop playback completely (resets position)
  Future<void> stop() async {
    developer.log('[TtsService] Stopping playback', name: 'TtsService');

    _isPlaying = false;
    _isPaused = false;
    _currentVerseIndex = -1;

    await _tts.stop();

    onPlayStateChanged?.call(false);
  }

  /// Cycle through preset speeds: 0.75x → 1.0x → 1.25x
  Future<void> cycleSpeed() async {
    _currentSpeedIndex = (_currentSpeedIndex + 1) % speedPresets.length;
    _speechRate = speedPresets[_currentSpeedIndex];

    developer.log('[TtsService] Cycling speed to ${_speechRate}x', name: 'TtsService');

    await _tts.setSpeechRate(_speechRate);

    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tts_speed_index', _currentSpeedIndex);
  }

  /// Get current speed as formatted string (e.g., "1.0x")
  String get speedLabel {
    if (_speechRate == 0.75) return '0.75x';
    if (_speechRate == 1.0) return '1.0x';
    if (_speechRate == 1.25) return '1.25x';
    return '${_speechRate.toStringAsFixed(2)}x';
  }

  /// Load saved speech rate preference
  Future<void> _loadSpeechRate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // MIGRATION: Remove old slider-based preference if it exists
      if (prefs.containsKey(_keyTtsRate)) {
        developer.log('[TtsService] Removing old tts_speech_rate preference', name: 'TtsService');
        await prefs.remove(_keyTtsRate);
      }

      _currentSpeedIndex = prefs.getInt('tts_speed_index') ?? _defaultSpeedIndex;

      // Clamp to valid range
      if (_currentSpeedIndex < 0 || _currentSpeedIndex >= speedPresets.length) {
        _currentSpeedIndex = _defaultSpeedIndex;
      }

      _speechRate = speedPresets[_currentSpeedIndex];
      developer.log('[TtsService] Loaded speed preset: ${_speechRate}x (index $_currentSpeedIndex)', name: 'TtsService');
    } catch (e) {
      developer.log('[TtsService] Error loading speech rate: $e', name: 'TtsService', error: e);
      _speechRate = _defaultRate;
      _currentSpeedIndex = _defaultSpeedIndex;
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    developer.log('[TtsService] Disposing TTS service', name: 'TtsService');

    await stop();
    _currentVerses.clear();

    onVerseChanged = null;
    onPlayStateChanged = null;
    onPlaybackComplete = null;
  }
}
