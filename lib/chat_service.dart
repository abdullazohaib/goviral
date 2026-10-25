import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'ai_audience_catalog.dart';
import 'ai_comment_service.dart';
import 'vision_service.dart';

class LiveChatMessage {
  final String id;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isHost;
  final bool isAi;
  final Color avatarColor;
  final String? city;
  final String? archetype;
  final String? avatarUrl;
  final bool isCloudGenerated;

  const LiveChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isHost = false,
    this.isAi = false,
    this.avatarColor = const Color(0xFF8758FF),
    this.city,
    this.archetype,
    this.avatarUrl,
    this.isCloudGenerated = false,
  });
}

class LiveChatService extends ChangeNotifier {
  static final LiveChatService instance = LiveChatService._();
  LiveChatService._();

  final List<LiveChatMessage> _messages = [];
  final Set<String> _recentlyEmittedMessages = {};
  final List<String> _recentSenders = [];
  Timer? _aiPacingTimer;
  final List<Timer> _pendingTimers = [];
  final Random _random = Random();
  String _streamTitle = 'GoViral Live';
  String _streamLanguage = 'Hinglish';
  bool _isActive = false;
  DateTime _lastHostInteractionTime = DateTime.now();
  DateTime? _lastVisualCommentTime;
  VisionEventType? _lastVisualEventType;

  List<LiveChatMessage> get messages => List.unmodifiable(_messages);
  bool get isActive => _isActive;
  int get messageCount => _messages.length;
  DateTime get lastHostInteractionTime => _lastHostInteractionTime;

  /// Starts the dynamic chat session for the live room
  void startSession({
    String streamTitle = 'GoViral Live',
    required String streamLanguage,
    required int audienceCount,
  }) {
    _streamTitle = streamTitle;
    _streamLanguage = streamLanguage;
    _isActive = true;
    _lastHostInteractionTime = DateTime.now();
    _lastVisualCommentTime = null;
    _lastVisualEventType = null;
    _messages.clear();
    _recentlyEmittedMessages.clear();
    _recentSenders.clear();
    _cancelPendingTimers();

    // Populate initial starter comments from catalog
    _populateInitialComments();

    // Start periodic ambient comments with natural human pacing and micro-bursts
    _scheduleNextAiEmission();
    notifyListeners();
  }

  void _cancelPendingTimers() {
    _aiPacingTimer?.cancel();
    _aiPacingTimer = null;
    for (final timer in _pendingTimers) {
      timer.cancel();
    }
    _pendingTimers.clear();
  }

  void _populateInitialComments() {
    final remaining = List<AiViewerProfile>.from(AiAudienceCatalog.profiles.skip(1))..shuffle(_random);
    final initialProfiles = [AiAudienceCatalog.profiles.first, ...remaining.take(3)];

    final starterMessages = [
      'hello brother! wassup 🙌',
      'OP stream chal rhi h bhai 🔥',
      'audio and video ekdum clear h 👍',
      'love from ${initialProfiles[3].city} bhai! ✨',
    ];

    for (int i = 0; i < initialProfiles.length; i++) {
      final p = initialProfiles[i];
      final msg = starterMessages[i];
      _recentlyEmittedMessages.add(msg);
      _recentSenders.add(p.name);

      _messages.add(
        LiveChatMessage(
          id: 'init_${p.id}',
          senderName: p.name,
          message: msg,
          timestamp: DateTime.now().subtract(Duration(seconds: (4 - i) * 3)),
          isHost: false,
          isAi: true,
          avatarColor: p.avatarColor,
          avatarUrl: p.photoUrl,
          city: p.city,
          archetype: p.archetype,
          isCloudGenerated: false,
        ),
      );
    }
  }

  /// High-speed authentic Instagram Live pacing matching 20K-25K live viewers
  void _scheduleNextAiEmission() {
    _aiPacingTimer?.cancel();
    if (!_isActive) return;

    // Fast, authentic Instagram Live pacing matching 20K-25K live viewers (350ms - 800ms)
    final delayMs = 350 + _random.nextInt(450);

    _aiPacingTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_isActive) return;

      _emitDynamicAiComment();

      // In ~55% of ticks, trigger a rapid secondary comment (micro-burst) 120-250ms later
      if (_random.nextInt(100) < 55) {
        final burstTimer = Timer(Duration(milliseconds: 120 + _random.nextInt(130)), () {
          if (!_isActive) return;
          _emitDynamicAiComment();
        });
        _pendingTimers.add(burstTimer);
      }

      // In ~25% of ticks, trigger a 3rd rapid comment (stream surge) 220-380ms later
      if (_random.nextInt(100) < 25) {
        final thirdTimer = Timer(Duration(milliseconds: 220 + _random.nextInt(160)), () {
          if (!_isActive) return;
          _emitDynamicAiComment();
        });
        _pendingTimers.add(thirdTimer);
      }

      _scheduleNextAiEmission();
    });
  }

  void _emitDynamicAiComment() {
    AiCommentEmission? chosen;
    for (int attempts = 0; attempts < 24; attempts++) {
      final candidate = AiAudienceCatalog.sampleEmission(
        streamLanguage: _streamLanguage,
      );
      if (!_recentSenders.contains(candidate.profile.name) &&
          !_recentlyEmittedMessages.contains(candidate.message)) {
        chosen = candidate;
        break;
      }
      chosen ??= candidate;
    }

    if (chosen == null) return;

    _recentlyEmittedMessages.add(chosen.message);
    if (_recentlyEmittedMessages.length > 50) {
      _recentlyEmittedMessages.remove(_recentlyEmittedMessages.first);
    }

    _recentSenders.add(chosen.profile.name);
    // Keep last 30 senders to guarantee high diversity and no repeated avatars
    if (_recentSenders.length > 30) {
      _recentSenders.removeAt(0);
    }

    final newMsg = LiveChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      senderName: chosen.profile.name,
      message: chosen.message,
      timestamp: DateTime.now(),
      isHost: false,
      isAi: true,
      avatarColor: chosen.profile.avatarColor,
      avatarUrl: chosen.profile.photoUrl,
      city: chosen.profile.city,
      archetype: chosen.profile.archetype,
      isCloudGenerated: false,
    );

    _addMessage(newMsg);
  }

  void _addMessage(LiveChatMessage msg) {
    _messages.add(msg);
    // Keep max 80 messages in memory to prevent memory bloat (zero persistence)
    if (_messages.length > 80) {
      _messages.removeAt(0);
    }
    notifyListeners();
  }

  /// Sends a comment from the live host
  void sendHostMessage(String text, {String hostName = 'You'}) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    _lastHostInteractionTime = DateTime.now();

    final newMsg = LiveChatMessage(
      id: 'host_${DateTime.now().millisecondsSinceEpoch}',
      senderName: hostName,
      message: clean,
      timestamp: DateTime.now(),
      isHost: true,
      isAi: false,
      avatarColor: const Color(0xFFFF3D8D), // gvPink
      isCloudGenerated: false,
    );

    _addMessage(newMsg);

    // Contextual understanding of host typed comment so audience answers!
    onHostSpeechContext(clean);
  }

  /// Sends a comment from an authorized invited viewer
  void sendViewerMessage(String text, {String viewerName = 'Invited Guest'}) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    final newMsg = LiveChatMessage(
      id: 'viewer_${DateTime.now().millisecondsSinceEpoch}',
      senderName: viewerName,
      message: clean,
      timestamp: DateTime.now(),
      isHost: false,
      isAi: false,
      avatarColor: const Color(0xFF6C5CE7), // Distinct purple for authorized private viewers
      isCloudGenerated: false,
    );

    _addMessage(newMsg);
  }

  /// Phase 19/20: Called when host speech understanding detects complete spoken utterance from host
  void onHostSpeechContext(String spokenText) {
    if (!_isActive || spokenText.trim().isEmpty) return;

    _lastHostInteractionTime = DateTime.now();
    // Re-synchronize pacing since host just spoke
    _scheduleNextAiEmission();

    // Call AiCommentService pipeline (Cloud Gemini 1.5 Flash with fallback to local intent synthesis)
    AiCommentService.instance.generateDynamicComments(
      streamTitle: _streamTitle,
      streamLanguage: _streamLanguage,
      hostUtterance: spokenText,
      visionEvent: VisionService.instance.lastDetectedEvent,
      recentHistory: _messages.take(6).toList(),
    ).then((comments) {
      if (!_isActive) return;

      for (final comment in comments) {
        final timer = Timer(Duration(milliseconds: comment.delayMs), () {
          if (!_isActive) return;

          // Prevent exact duplicate comment text
          if (_recentlyEmittedMessages.contains(comment.message)) {
            return;
          }
          _recentlyEmittedMessages.add(comment.message);
          if (_recentlyEmittedMessages.length > 40) {
            _recentlyEmittedMessages.remove(_recentlyEmittedMessages.first);
          }

          final profile = AiAudienceCatalog.findProfile(comment.senderName);
          final chatMsg = LiveChatMessage(
            id: 'ai_dyn_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999)}',
            senderName: comment.senderName,
            message: comment.message,
            timestamp: DateTime.now(),
            isHost: false,
            isAi: true,
            avatarColor: profile.avatarColor,
            avatarUrl: profile.photoUrl,
            city: profile.city,
            archetype: profile.archetype,
            isCloudGenerated: comment.isCloudGenerated,
          );
          _addMessage(chatMsg);
        });
        _pendingTimers.add(timer);
      }
    }).catchError((e) {
      debugPrint('[LiveChatService] Error in dynamic comments: $e');
    });
  }

  /// Phase 18/20: Called when vision understanding detects a keyframe visual action
  void onHostVisualContext(VisionEvent event) {
    if (!_isActive) return;

    final now = DateTime.now();
    // Debounce visual comments to avoid spamming (minimum 10 seconds between visual reactions)
    if (_lastVisualCommentTime != null &&
        now.difference(_lastVisualCommentTime!).inSeconds < 10) {
      return;
    }

    // If camera is still (idleOrAway), only react once every 35 seconds
    if (event.type == VisionEventType.idleOrAway) {
      if (_lastVisualEventType == VisionEventType.idleOrAway &&
          _lastVisualCommentTime != null &&
          now.difference(_lastVisualCommentTime!).inSeconds < 35) {
        return;
      }
    }

    _lastVisualCommentTime = now;
    _lastVisualEventType = event.type;
    _lastHostInteractionTime = now;
    _scheduleNextAiEmission();

    AiCommentService.instance.generateDynamicComments(
      streamTitle: _streamTitle,
      streamLanguage: _streamLanguage,
      visionEvent: event,
      recentHistory: _messages.take(6).toList(),
    ).then((comments) {
      if (!_isActive) return;

      for (final comment in comments) {
        final timer = Timer(Duration(milliseconds: comment.delayMs), () {
          if (!_isActive) return;

          // Prevent exact duplicate visual reaction messages
          if (_recentlyEmittedMessages.contains(comment.message)) {
            return;
          }
          _recentlyEmittedMessages.add(comment.message);
          if (_recentlyEmittedMessages.length > 40) {
            _recentlyEmittedMessages.remove(_recentlyEmittedMessages.first);
          }

          final profile = AiAudienceCatalog.findProfile(comment.senderName);
          final visualMsg = LiveChatMessage(
            id: 'ai_vis_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999)}',
            senderName: comment.senderName,
            message: comment.message,
            timestamp: DateTime.now(),
            isHost: false,
            isAi: true,
            avatarColor: profile.avatarColor,
            avatarUrl: profile.photoUrl,
            city: profile.city,
            archetype: profile.archetype,
            isCloudGenerated: comment.isCloudGenerated,
          );
          _addMessage(visualMsg);
        });
        _pendingTimers.add(timer);
      }
    }).catchError((e) {
      debugPrint('[LiveChatService] Error in visual comments: $e');
    });
  }

  /// Synchronously cancels all timers and cleans up chat state
  void stopSession() {
    _isActive = false;
    _aiPacingTimer?.cancel();
    _aiPacingTimer = null;
    _cancelPendingTimers();
    notifyListeners();
  }

  /// Clears chat history
  void clear() {
    _messages.clear();
    notifyListeners();
  }
}
