import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_audience_catalog.dart';
import 'chat_service.dart';
import 'contextual_ai_engine.dart';
import 'vision_service.dart';

/// Engine mode indicator transparently distinguishing Cloud LLM from On-Device fallback
enum AiEngineMode {
  cloudGemini,
  localNeuralEngine,
}

/// A structured dynamic AI comment produced by the generation pipeline
class AiGeneratedComment {
  final String senderName;
  final String message;
  final int delayMs;
  final bool isCloudGenerated;
  final String? city;
  final String? archetype;

  const AiGeneratedComment({
    required this.senderName,
    required this.message,
    required this.delayMs,
    required this.isCloudGenerated,
    this.city,
    this.archetype,
  });
}

/// Phase 19/20: Real-Time Dynamic AI Comment Generation Service
/// Manages streaming/REST connections to Google Gemini 1.5 Flash for true generative AI comments,
/// with dynamic on-device lexical synthesis fallback adhering to Zero Persistence (Section 1.7).
class AiCommentService extends ChangeNotifier {
  static final AiCommentService instance = AiCommentService._();
  AiCommentService._();

  static const String _prefApiKey = 'goviral_gemini_api_key';
  static const String _prefCloudEnabled = 'goviral_cloud_ai_enabled';

  final Random _random = Random();
  String? _geminiApiKey;
  bool _isCloudEnabled = true;
  bool _isInitialized = false;
  bool _isRequestInFlight = false;
  String _lastErrorMessage = '';

  // Getters
  String? get geminiApiKey => _geminiApiKey;
  bool get isCloudEnabled => _isCloudEnabled;
  bool get isInitialized => _isInitialized;
  bool get isRequestInFlight => _isRequestInFlight;
  String get lastErrorMessage => _lastErrorMessage;

  AiEngineMode get activeMode {
    if (_isCloudEnabled && _geminiApiKey != null && _geminiApiKey!.trim().isNotEmpty) {
      return AiEngineMode.cloudGemini;
    }
    return AiEngineMode.localNeuralEngine;
  }

  bool get isCloudActive => activeMode == AiEngineMode.cloudGemini;

  String get engineStatusLabel {
    switch (activeMode) {
      case AiEngineMode.cloudGemini:
        return 'Gemini 1.5 Flash (Cloud LLM)';
      case AiEngineMode.localNeuralEngine:
        return 'Local Intent Engine (Offline Fallback)';
    }
  }

  /// Initializes configuration from persistent preferences
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _geminiApiKey = prefs.getString(_prefApiKey);
      _isCloudEnabled = prefs.getBool(_prefCloudEnabled) ?? true;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[AiCommentService] SharedPreferences init error: $e');
      _isInitialized = true;
    }
  }

  /// Updates and persists the Gemini API key
  Future<void> setGeminiApiKey(String? key) async {
    _geminiApiKey = key?.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_geminiApiKey == null || _geminiApiKey!.isEmpty) {
        await prefs.remove(_prefApiKey);
      } else {
        await prefs.setString(_prefApiKey, _geminiApiKey!);
      }
    } catch (e) {
      debugPrint('[AiCommentService] Failed saving API key: $e');
    }
  }

  /// Toggles whether Cloud AI is enabled
  Future<void> setCloudEnabled(bool enabled) async {
    _isCloudEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefCloudEnabled, enabled);
    } catch (e) {
      debugPrint('[AiCommentService] Failed saving cloud enabled: $e');
    }
  }

  /// Tests connection to Gemini API with the given API key
  Future<bool> testConnection(String apiKey) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      _lastErrorMessage = 'API key cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$cleanKey',
      );

      final payload = {
        'contents': [
          {
            'parts': [
              {'text': 'Say hello in 3 words.'}
            ]
          }
        ],
        'generationConfig': {
          'maxOutputTokens': 15,
        }
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        _lastErrorMessage = '';
        notifyListeners();
        return true;
      } else {
        final body = jsonDecode(response.body);
        _lastErrorMessage = body['error']?['message'] ?? 'HTTP ${response.statusCode} error';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _lastErrorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Generates dynamic contextual comments for host speech, visual actions, or periodic stream pacing
  Future<List<AiGeneratedComment>> generateDynamicComments({
    required String streamTitle,
    required String streamLanguage,
    String? hostUtterance,
    VisionEvent? visionEvent,
    List<LiveChatMessage>? recentHistory,
  }) async {
    if (isCloudActive) {
      try {
        _isRequestInFlight = true;
        notifyListeners();

        final comments = await _callGeminiApi(
          streamTitle: streamTitle,
          streamLanguage: streamLanguage,
          hostUtterance: hostUtterance,
          visionEvent: visionEvent,
          recentHistory: recentHistory,
        );

        _isRequestInFlight = false;
        notifyListeners();

        if (comments.isNotEmpty) {
          return comments;
        }
      } catch (e) {
        _isRequestInFlight = false;
        debugPrint('[AiCommentService] Gemini Cloud API error: $e, falling back to local synthesis');
        notifyListeners();
      }
    }

    // Honest fallback to dynamic on-device lexical synthesis
    return _generateLocalDynamicComments(
      streamTitle: streamTitle,
      streamLanguage: streamLanguage,
      hostUtterance: hostUtterance,
      visionEvent: visionEvent,
      recentHistory: recentHistory,
    );
  }

  /// Performs cloud generation via Google Gemini 1.5 Flash
  Future<List<AiGeneratedComment>> _callGeminiApi({
    required String streamTitle,
    required String streamLanguage,
    String? hostUtterance,
    VisionEvent? visionEvent,
    List<LiveChatMessage>? recentHistory,
  }) async {
    final apiKey = _geminiApiKey!.trim();
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );

    // Pick 4 diverse candidate personas from the catalog
    final candidateProfiles = List<AiViewerProfile>.from(AiAudienceCatalog.profiles)..shuffle(_random);
    final selectedProfiles = candidateProfiles.take(4).toList();

    final personasSummary = selectedProfiles.map((p) =>
      '- "${p.name}" (from ${p.city}, archetype: ${p.archetype}, preferred language: ${p.preferredLanguage})'
    ).join('\n');

    final visualContext = visionEvent != null
        ? 'Visual cue observed on camera: ${visionEvent.label} (score: ${visionEvent.score.toStringAsFixed(2)})'
        : 'Visual state: Standard camera stream active';

    final hostContext = (hostUtterance != null && hostUtterance.trim().isNotEmpty)
        ? 'Streamer just said: "$hostUtterance"'
        : 'Streamer is currently interacting live without speaking.';

    final recentChat = (recentHistory != null && recentHistory.isNotEmpty)
        ? 'Recent chat:\n${recentHistory.take(4).map((m) => '${m.senderName}: ${m.message}').join('\n')}'
        : 'Chat started.';

    final prompt = '''
You are generating realistic, dynamic viewer comments for a mobile livestream (like Instagram Live or Parallel Live).
Stream Title: "$streamTitle"
Selected Stream Language: "$streamLanguage"
$visualContext
$hostContext
$recentChat

Available Viewers:
$personasSummary

INSTRUCTIONS:
1. Select 1 or 2 distinct viewers from the list above who would naturally react to what the streamer just said or showed.
2. Formulate authentic, spontaneous live stream comments strictly in $streamLanguage.
   - If stream language is Hindi: use colloquial Hindi or Romanized Hindi ("अरे भाई गजब", "मस्त लग रहा है", "OP भाई", "क्या बात है 🔥").
   - If stream language is Hinglish: use modern colloquial Indian social media Hinglish ("bhai", "OP", "mast", "sahi h", "kya baat h", "full power 🔥").
   - If English: use natural conversational livestream English ("let's go!", "looking sharp", "W stream", "banger 🔥").
   - Keep comments short, punchy, and spontaneous (3 to 10 words max).
   - If someone entered the room behind the streamer, mention them or ask to introduce them.
   - If the streamer asked a question or asked for a task/challenge, answer or suggest a fun dare.
3. Return STRICTLY a valid JSON array of objects with keys: "senderName", "message", "delayMs".
Example format:
[
  {"senderName": "${selectedProfiles[0].name}", "message": "bhai OP stream chal rhi h 🔥", "delayMs": 1200},
  {"senderName": "${selectedProfiles[1].name}", "message": "@${selectedProfiles[0].name} bilkul agree bro!", "delayMs": 2800}
]
No markdown fences, no explanatory text, return only the JSON array.
''';

    final payload = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.88,
        'maxOutputTokens': 250,
      }
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 7));

    if (response.statusCode != 200) {
      throw Exception('Gemini API HTTP ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned empty candidates');
    }

    final textContent = candidates[0]['content']?['parts']?[0]?['text'] as String?;
    if (textContent == null || textContent.trim().isEmpty) {
      throw Exception('Gemini returned empty text content');
    }

    // Parse JSON array
    final rawJson = textContent.trim();
    final parsed = jsonDecode(rawJson) as List;

    final results = <AiGeneratedComment>[];
    for (final item in parsed) {
      if (item is Map) {
        final sender = (item['senderName'] as String?)?.trim() ?? selectedProfiles.first.name;
        final msg = (item['message'] as String?)?.trim() ?? '';
        final delay = (item['delayMs'] as num?)?.toInt() ?? (1200 + _random.nextInt(1500));

        if (msg.isNotEmpty) {
          final matchedProfile = selectedProfiles.firstWhere(
            (p) => p.name.toLowerCase() == sender.toLowerCase(),
            orElse: () => selectedProfiles.first,
          );

          results.add(AiGeneratedComment(
            senderName: matchedProfile.name,
            message: msg,
            delayMs: delay,
            isCloudGenerated: true,
            city: matchedProfile.city,
            archetype: matchedProfile.archetype,
          ));
        }
      }
    }

    return results;
  }

  /// Generates dynamic on-device contextual comments via intent synthesis when offline
  List<AiGeneratedComment> _generateLocalDynamicComments({
    required String streamTitle,
    required String streamLanguage,
    String? hostUtterance,
    VisionEvent? visionEvent,
    List<LiveChatMessage>? recentHistory,
  }) {
    final results = <AiGeneratedComment>[];

    // 1. If host spoke, use ContextualAiEngine to classify intent and synthesize dynamic multi-turn response
    if (hostUtterance != null && hostUtterance.trim().isNotEmpty) {
      final response = ContextualAiEngine.instance.generateSpeechResponse(
        hostSpeech: hostUtterance,
        recentVisionEvent: visionEvent,
        streamLanguage: streamLanguage,
      );

      results.add(AiGeneratedComment(
        senderName: response.primaryProfile.name,
        message: response.primaryComment,
        delayMs: 1100 + _random.nextInt(600),
        isCloudGenerated: false,
        city: response.primaryProfile.city,
        archetype: response.primaryProfile.archetype,
      ));

      if (response.banterProfile != null && response.banterComment != null) {
        results.add(AiGeneratedComment(
          senderName: response.banterProfile!.name,
          message: response.banterComment!,
          delayMs: 2400 + _random.nextInt(900),
          isCloudGenerated: false,
          city: response.banterProfile!.city,
          archetype: response.banterProfile!.archetype,
        ));
      }
      return results;
    }

    // 2. If visual event was triggered, generate visual reaction
    if (visionEvent != null) {
      final response = ContextualAiEngine.instance.generateVisualResponse(
        visualEvent: visionEvent,
        streamLanguage: streamLanguage,
      );

      results.add(AiGeneratedComment(
        senderName: response.primaryProfile.name,
        message: response.primaryComment,
        delayMs: 1000 + _random.nextInt(500),
        isCloudGenerated: false,
        city: response.primaryProfile.city,
        archetype: response.primaryProfile.archetype,
      ));

      if (response.banterProfile != null && response.banterComment != null) {
        results.add(AiGeneratedComment(
          senderName: response.banterProfile!.name,
          message: response.banterComment!,
          delayMs: 2200 + _random.nextInt(800),
          isCloudGenerated: false,
          city: response.banterProfile!.city,
          archetype: response.banterProfile!.archetype,
        ));
      }
      return results;
    }

    // 3. Otherwise, ambient dynamic emission from catalog
    final emission = AiAudienceCatalog.sampleEmission(streamLanguage: streamLanguage);
    results.add(AiGeneratedComment(
      senderName: emission.profile.name,
      message: emission.message,
      delayMs: 800,
      isCloudGenerated: false,
      city: emission.profile.city,
      archetype: emission.profile.archetype,
    ));

    return results;
  }
}
