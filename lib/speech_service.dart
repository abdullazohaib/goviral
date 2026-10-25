import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Phase 17: Host Speech Understanding & Real-Time Audio Stream Transcription
/// Singleton service providing continuous speech-to-text processing for host commentary,
/// adhering to zero-persistence requirements (ephemeral memory-only).
class SpeechService extends ChangeNotifier {
  static final SpeechService instance = SpeechService._();
  SpeechService._();

  final SpeechToText _speechToText = SpeechToText();

  bool _isInitialized = false;
  bool _isAvailable = false;
  bool _isListening = false;
  bool _isActive = false;
  bool _isMuted = false;

  String _currentLocaleId = 'en_IN';
  String _currentWords = '';
  double _soundLevel = 0.0;
  final List<String> _recentTranscripts = [];

  void Function(String spokenText)? _onHostSpoke;
  Timer? _restartDebounce;
  Timer? _phraseDebounceTimer;
  String _lastDispatchedPhrase = '';

  // Public getters
  bool get isInitialized => _isInitialized;
  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  bool get isActive => _isActive;
  bool get isMuted => _isMuted;
  String get currentWords => _currentWords;
  double get soundLevel => _soundLevel;
  List<String> get recentTranscripts => List.unmodifiable(_recentTranscripts);
  String get currentLocaleId => _currentLocaleId;

  /// Map GoViral stream languages to standard Indian BCP-47 speech recognition locales (Primary: Hindi, English, Hinglish)
  static String resolveLocaleForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'hindi':
      case 'hinglish':
        return 'hi_IN'; // hi_IN supports Hindi & code-mixed Hinglish in Android Google Speech Recognizer
      case 'kannada':
        return 'kn_IN';
      case 'urdu':
        return 'ur_IN';
      case 'tamil':
        return 'ta_IN';
      case 'telugu':
        return 'te_IN';
      case 'malayalam':
        return 'ml_IN';
      case 'english':
      default:
        return 'en_IN';
    }
  }

  /// Initializes the on-device speech engine
  Future<bool> initialize() async {
    if (_isInitialized) return _isAvailable;

    try {
      _isAvailable = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: false,
      );
      _isInitialized = true;
      notifyListeners();
      return _isAvailable;
    } catch (e) {
      debugPrint('[SpeechService] Initialization error: $e');
      _isAvailable = false;
      _isInitialized = true;
      notifyListeners();
      return false;
    }
  }

  /// Starts continuous speech-to-text monitoring for host live broadcast
  Future<void> startListening({
    required String streamLanguage,
    void Function(String spokenText)? onHostSpoke,
  }) async {
    _isActive = true;
    _isMuted = false;
    _onHostSpoke = onHostSpoke;
    _currentWords = '';
    _lastDispatchedPhrase = '';
    _recentTranscripts.clear();

    _currentLocaleId = resolveLocaleForLanguage(streamLanguage);

    if (!_isInitialized) {
      await initialize();
    }

    if (!_isAvailable) {
      debugPrint('[SpeechService] Speech recognition not available on this device');
      return;
    }

    // Verify whether the resolved locale is supported by device, else fallback to en_IN
    try {
      final locales = await _speechToText.locales();
      final hasLocale = locales.any((l) => l.localeId == _currentLocaleId);
      if (!hasLocale && locales.isNotEmpty) {
        final hasEnIn = locales.any((l) => l.localeId == 'en_IN');
        _currentLocaleId = hasEnIn ? 'en_IN' : locales.first.localeId;
      }
    } catch (_) {
      // Keep best-effort locale
    }

    await _listen();
  }

  Future<void> _listen() async {
    if (!_isActive || _isMuted || !_isAvailable) return;

    try {
      await _speechToText.listen(
        onResult: _handleResult,
        onSoundLevelChange: _handleSoundLevel,
        listenOptions: SpeechListenOptions(
          localeId: _currentLocaleId,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
      _isListening = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[SpeechService] Listen error: $e');
      _scheduleRestart(delayMs: 1500);
    }
  }

  void _dispatchPhrase(String phrase) {
    final clean = phrase.trim();
    if (clean.isEmpty || clean == _lastDispatchedPhrase) return;
    if (clean.length < 3) return; // Discard isolated micro-noises

    _lastDispatchedPhrase = clean;
    _recentTranscripts.add(clean);

    // Keep only last 10 entries in volatile memory (zero persistence)
    if (_recentTranscripts.length > 10) {
      _recentTranscripts.removeAt(0);
    }

    _onHostSpoke?.call(clean);
    _currentWords = '';
    notifyListeners();
  }

  void _handleResult(SpeechRecognitionResult result) {
    if (!_isActive || _isMuted) return;

    final words = result.recognizedWords.trim();
    _currentWords = words;
    notifyListeners();

    _phraseDebounceTimer?.cancel();

    if (result.finalResult && words.isNotEmpty) {
      _dispatchPhrase(words);
    } else if (words.isNotEmpty) {
      // Incremental debounce: when speaker pauses for ~1300ms, recognize as completed utterance
      _phraseDebounceTimer = Timer(const Duration(milliseconds: 1300), () {
        if (!_isActive || _isMuted) return;
        _dispatchPhrase(_currentWords);
      });
    }
  }

  void _handleSoundLevel(double level) {
    if (!_isActive || _isMuted) {
      _soundLevel = 0.0;
    } else {
      // Normalize sound level from typical -10..10 dB to 0.0..1.0
      _soundLevel = ((level + 10) / 20.0).clamp(0.0, 1.0);
    }
    notifyListeners();
  }

  void _handleStatus(String status) {
    // When Android recognizer pauses or finishes phrase, automatically keep listening if stream active
    if (status == 'listening') {
      _isListening = true;
      notifyListeners();
    } else if (status == 'notListening' || status == 'done') {
      _isListening = false;
      notifyListeners();
      if (_isActive && !_isMuted) {
        _scheduleRestart(delayMs: 2500);
      }
    }
  }

  void _handleError(dynamic error) {
    debugPrint('[SpeechService] Error status: $error');
    _isListening = false;
    notifyListeners();
    if (_isActive && !_isMuted) {
      _scheduleRestart(delayMs: 1200);
    }
  }

  void _scheduleRestart({int delayMs = 500}) {
    _restartDebounce?.cancel();
    if (!_isActive || _isMuted) return;

    _restartDebounce = Timer(Duration(milliseconds: delayMs), () {
      if (_isActive && !_isMuted && !_speechToText.isListening) {
        _listen();
      }
    });
  }

  /// Sets host microphone mute state
  void setMuted(bool muted) {
    _isMuted = muted;
    if (muted) {
      _restartDebounce?.cancel();
      _speechToText.stop();
      _isListening = false;
      _soundLevel = 0.0;
      _currentWords = '';
    } else if (_isActive) {
      _listen();
    }
    notifyListeners();
  }

  /// Stops speech understanding session and tears down ephemeral resources (zero persistence)
  Future<void> stopListening() async {
    _isActive = false;
    _isMuted = false;
    _restartDebounce?.cancel();
    _restartDebounce = null;
    _onHostSpoke = null;
    _isListening = false;
    _currentWords = '';
    _soundLevel = 0.0;
    _recentTranscripts.clear();
    notifyListeners();

    try {
      await _speechToText.stop();
    } catch (_) {}
  }

  /// For testing or manual simulation of host speech
  @visibleForTesting
  void simulateSpokenSpeech(String text) {
    _currentWords = text;
    _recentTranscripts.add(text);
    _onHostSpoke?.call(text);
    notifyListeners();
  }
}
