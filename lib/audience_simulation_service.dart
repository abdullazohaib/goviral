import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Direction of audience fluctuation for directional UI animations
enum FluctuationDirection {
  increasing,
  decreasing,
  stable,
}

/// Structured audience state snapshot
class AudienceSnapshot {
  final int count;
  final FluctuationDirection direction;
  final int delta;
  final String formatted;
  final DateTime timestamp;

  const AudienceSnapshot({
    required this.count,
    required this.direction,
    required this.delta,
    required this.formatted,
    required this.timestamp,
  });
}

/// Phase 22: Dynamic Simulated Audience Counter with Fluctuation
/// Implements stochastic Poisson/Normal arrival and churn kinetics simulating live audience join/leave,
/// FYP recommendation waves, host speech engagement surges, and reaction vitality bursts.
class AudienceSimulationService extends ChangeNotifier {
  static final AudienceSimulationService instance = AudienceSimulationService._();
  AudienceSimulationService._();

  final Random _random = Random();
  Timer? _tickerTimer;

  bool _isActive = false;
  int _currentCount = 0;
  int _minTarget = 20000;
  int _maxTarget = 25000;
  int _hardMinBound = 1000;
  int _hardMaxBound = 30000;

  FluctuationDirection _lastDirection = FluctuationDirection.stable;
  int _lastDelta = 0;
  DateTime _lastUpdateTime = DateTime.now();

  bool get isActive => _isActive;
  int get currentCount => _currentCount;
  int get minTarget => _minTarget;
  int get maxTarget => _maxTarget;
  FluctuationDirection get direction => _lastDirection;
  int get lastDelta => _lastDelta;

  AudienceSnapshot get snapshot => AudienceSnapshot(
        count: _currentCount,
        direction: _lastDirection,
        delta: _lastDelta,
        formatted: formatAudienceCount(_currentCount),
        timestamp: _lastUpdateTime,
      );

  /// Initializes and starts the simulation session with target range
  void startSession({
    required int minAudience,
    required int maxAudience,
  }) {
    stopSession();
    _isActive = true;
    _minTarget = min(minAudience, maxAudience);
    _maxTarget = max(minAudience, maxAudience);

    // Initial count is set to min target
    _currentCount = _minTarget;
    _hardMinBound = max(10, (_minTarget * 0.85).round());
    _hardMaxBound = max(_hardMinBound + 500, (_maxTarget * 1.15).round());

    _lastDirection = FluctuationDirection.stable;
    _lastDelta = 0;
    _lastUpdateTime = DateTime.now();

    notifyListeners();
    _scheduleNextTick();
  }

  /// Stops and disposes active timers
  void stopSession() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
    _isActive = false;
  }

  /// Schedules the next stochastic arrival/churn evaluation
  void _scheduleNextTick() {
    _tickerTimer?.cancel();
    if (!_isActive) return;

    // Organic tick interval: 850ms to 1800ms
    final delayMs = 850 + _random.nextInt(950);
    _tickerTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_isActive) return;
      _computeNextFluctuation();
      _scheduleNextTick();
    });
  }

  /// Computes the next natural fluctuation using Poisson/Gaussian kinetics
  void _computeNextFluctuation() {
    final span = _maxTarget - _minTarget;
    final progress = span > 0 ? (_currentCount - _minTarget) / span : 0.5;

    // Base step magnitude proportional to stream size (e.g., 40 to 160 for a 20k stream)
    final baseScale = max(25, (_currentCount * 0.006).round());
    final roll = _random.nextInt(100);

    int delta;
    if (progress < 0.20) {
      // Below min target: strong incoming join wave (88% arrival probability)
      if (roll < 88) {
        delta = (baseScale * 0.7 + _random.nextInt(baseScale)).round();
      } else {
        delta = -(_random.nextInt((baseScale * 0.3).round() + 1));
      }
    } else if (progress > 0.85) {
      // Above 85% of target: natural viewer churn / drop off (72% leave probability)
      if (roll < 72) {
        delta = -((baseScale * 0.6 + _random.nextInt(baseScale)).round());
      } else {
        delta = (_random.nextInt((baseScale * 0.4).round() + 1));
      }
    } else {
      // Healthy mid-stream balance (60% join, 34% leave, 6% stable)
      if (roll < 60) {
        delta = (baseScale * 0.5 + _random.nextInt(baseScale)).round();
      } else if (roll < 94) {
        delta = -((baseScale * 0.4 + _random.nextInt((baseScale * 0.7).round() + 1)).round());
      } else {
        delta = 0;
      }
    }

    // 12% probability of an algorithmic recommendation burst (FYP wave)
    if (_random.nextInt(100) < 12) {
      final viralBoost = (baseScale * 1.5 + _random.nextInt((baseScale * 1.8).round() + 1)).round();
      delta += viralBoost;
    }

    _applyDelta(delta);
  }

  /// Applies a delta to the audience count and updates direction
  void _applyDelta(int delta) {
    if (delta == 0) return;

    final updated = (_currentCount + delta).clamp(_hardMinBound, _hardMaxBound);
    if (updated != _currentCount) {
      final actualDelta = updated - _currentCount;
      _currentCount = updated;
      _lastDelta = actualDelta;
      _lastDirection = actualDelta > 0
          ? FluctuationDirection.increasing
          : FluctuationDirection.decreasing;
      _lastUpdateTime = DateTime.now();
      notifyListeners();
    }
  }

  /// Surge: Host spoke into microphone — viewers engage and share (+35 to +95)
  void surgeHostSpeech() {
    if (!_isActive) return;
    final bonus = 35 + _random.nextInt(60);
    _applyDelta(bonus);
  }

  /// Surge: Reaction burst triggered (hearts/fire) — algorithm boosts stream (+55 to +145)
  void surgeReactionBurst() {
    if (!_isActive) return;
    final bonus = 55 + _random.nextInt(90);
    _applyDelta(bonus);
  }

  /// Surge: Host submitted a comment — chat activity spike (+40 to +110)
  void surgeHostMessage() {
    if (!_isActive) return;
    final bonus = 40 + _random.nextInt(70);
    _applyDelta(bonus);
  }

  /// Surge: Visual cue observed (movement, showcase, person entering) (+30 to +80)
  void surgeVisualCue() {
    if (!_isActive) return;
    final bonus = 30 + _random.nextInt(50);
    _applyDelta(bonus);
  }

  /// Formats raw audience integers into standard livestream format (K / M / Raw)
  static String formatAudienceCount(int count) {
    if (count >= 1000000) {
      final double millions = count / 1000000.0;
      return (millions >= 10 || count % 1000000 == 0)
          ? '${millions.toStringAsFixed(0)}M'
          : '${millions.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      final double thousands = count / 1000.0;
      return (thousands >= 100 || count % 1000 == 0)
          ? '${thousands.toStringAsFixed(0)}K'
          : '${thousands.toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
