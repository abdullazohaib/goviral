import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

/// Supported categories of visual frame understanding
enum VisionEventType {
  normal,
  highMotion,
  closeUpFocus,
  lightingShift,
  idleOrAway,
  personEntered,
}

/// A structured visual event recognized from real-time keyframes
class VisionEvent {
  final VisionEventType type;
  final String label;
  final double score;
  final DateTime timestamp;

  const VisionEvent({
    required this.type,
    required this.label,
    required this.score,
    required this.timestamp,
  });

  @override
  String toString() => 'VisionEvent($type, $label, score: ${score.toStringAsFixed(2)})';
}

/// Phase 18: Relevant Video-Frame Understanding & Visual Cue Analysis
/// Processes camera keyframes in real-time without storing or persisting any images
/// (strictly ephemeral memory-only processing fulfilling Zero-Persistence Section 1.7).
class VisionService extends ChangeNotifier {
  static final VisionService instance = VisionService._();
  VisionService._();

  bool _isActive = false;
  bool _isProcessing = false;

  DateTime _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastEventTime = DateTime.fromMillisecondsSinceEpoch(0);

  double _currentLuminance = 0.5;
  double _currentMotionScore = 0.0;
  double _previousLuminance = 0.5;
  Uint8List? _previousYSubsample;
  int _consecutiveLowMotionFrames = 0;

  VisionEvent? _lastDetectedEvent;
  void Function(VisionEvent event)? _onVisualEvent;

  // Getters
  bool get isActive => _isActive;
  bool get isProcessing => _isProcessing;
  double get currentLuminance => _currentLuminance;
  double get currentMotionScore => _currentMotionScore;
  VisionEvent? get lastDetectedEvent => _lastDetectedEvent;

  String get visualStatusLabel {
    if (!_isActive) return 'Inactive';
    if (_lastDetectedEvent != null &&
        DateTime.now().difference(_lastDetectedEvent!.timestamp).inSeconds < 4) {
      return _lastDetectedEvent!.label;
    }
    if (_currentMotionScore > 0.35) return 'Dynamic Movement';
    if (_currentLuminance < 0.15) return 'Low Light';
    return 'Broadcast Active';
  }

  /// Starts the vision processing session
  void startSession({void Function(VisionEvent event)? onVisualEvent}) {
    _isActive = true;
    _onVisualEvent = onVisualEvent;
    _lastFrameTime = DateTime.fromMillisecondsSinceEpoch(0);
    _lastEventTime = DateTime.fromMillisecondsSinceEpoch(0);
    _previousYSubsample = null;
    _lastDetectedEvent = null;
    _currentMotionScore = 0.0;
    _currentLuminance = 0.5;
    _previousLuminance = 0.5;
    _consecutiveLowMotionFrames = 0;
    notifyListeners();
  }

  /// Ingests a raw camera image frame from CameraController.startImageStream
  void processCameraImage(CameraImage image) {
    if (!_isActive || _isProcessing) return;

    final now = DateTime.now();
    // Throttle to ~3-4 frames per second to ensure negligible CPU overhead
    if (now.difference(_lastFrameTime).inMilliseconds < 280) {
      return;
    }
    _lastFrameTime = now;
    _isProcessing = true;

    try {
      _analyzeYPlane(image);
    } catch (e) {
      debugPrint('[VisionService] Frame analysis error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  void _analyzeYPlane(CameraImage image) {
    if (image.planes.isEmpty) return;
    final yPlane = image.planes[0];
    final bytes = yPlane.bytes;
    if (bytes.isEmpty) return;

    // Subsample step: stride across pixels to extract a lightweight 1D feature array
    const int targetSamples = 256;
    final stride = (bytes.length ~/ targetSamples).clamp(1, 1024);
    final subsample = Uint8List(targetSamples);

    int totalY = 0;
    int sampleIndex = 0;

    for (int i = 0; i < bytes.length && sampleIndex < targetSamples; i += stride) {
      final val = bytes[i];
      subsample[sampleIndex++] = val;
      totalY += val;
    }

    if (sampleIndex == 0) return;

    // 1. Calculate Average Luminance (0.0 to 1.0)
    final avgLuminance = (totalY / sampleIndex) / 255.0;
    _previousLuminance = _currentLuminance;
    _currentLuminance = avgLuminance;

    // 2. Calculate Optical Motion Delta against previous subsample (with spatial upper/lower split)
    double motionScore = 0.0;
    double upperMotion = 0.0;
    double lowerMotion = 0.0;
    if (_previousYSubsample != null && _previousYSubsample!.length == sampleIndex) {
      int deltaSum = 0;
      int upperDelta = 0;
      int lowerDelta = 0;
      final half = sampleIndex ~/ 2;
      for (int i = 0; i < sampleIndex; i++) {
        final diff = (subsample[i] - _previousYSubsample![i]).abs();
        deltaSum += diff;
        if (i < half) {
          upperDelta += diff;
        } else {
          lowerDelta += diff;
        }
      }
      motionScore = (deltaSum / sampleIndex) / 255.0;
      upperMotion = (upperDelta / half) / 255.0;
      lowerMotion = (lowerDelta / (sampleIndex - half)) / 255.0;
    }

    _currentMotionScore = motionScore;
    _previousYSubsample = subsample;

    // 3. Event Classification
    _classifyVisualEvent(motionScore, avgLuminance, upperMotion, lowerMotion);
    notifyListeners();
  }

  void _classifyVisualEvent(double motionScore, double luminance, double upperMotion, double lowerMotion) {
    final now = DateTime.now();
    // Minimum 7 seconds between AI audience visual reactions to prevent spamming
    final canEmitEvent = now.difference(_lastEventTime).inSeconds >= 7;

    VisionEvent? candidate;

    // Check for someone entering background/frame (upper frame movement distinct from foreground)
    if (upperMotion > 0.15 && upperMotion > (lowerMotion * 1.25) && motionScore < 0.45) {
      _consecutiveLowMotionFrames = 0;
      candidate = VisionEvent(
        type: VisionEventType.personEntered,
        label: 'Someone Entered Frame 👀',
        score: upperMotion,
        timestamp: now,
      );
    }
    // Check for High Motion / Waving / High Energy
    else if (motionScore > 0.36) {
      _consecutiveLowMotionFrames = 0;
      candidate = VisionEvent(
        type: VisionEventType.highMotion,
        label: 'High Energy Movement',
        score: motionScore,
        timestamp: now,
      );
    }
    // Check for Lighting Shift
    else if ((luminance - _previousLuminance).abs() > 0.22) {
      _consecutiveLowMotionFrames = 0;
      candidate = VisionEvent(
        type: VisionEventType.lightingShift,
        label: 'Lighting Shift',
        score: (luminance - _previousLuminance).abs(),
        timestamp: now,
      );
    }
    // Check for Close-up product or focus inspection
    else if (motionScore > 0.16 && motionScore < 0.32 && luminance > 0.25) {
      _consecutiveLowMotionFrames = 0;
      candidate = VisionEvent(
        type: VisionEventType.closeUpFocus,
        label: 'Close-Up Showcase',
        score: motionScore,
        timestamp: now,
      );
    }
    // Check for Idle or Stepped Away
    else if (motionScore < 0.02) {
      _consecutiveLowMotionFrames++;
      if (_consecutiveLowMotionFrames >= 15) { // ~4-5 seconds of stillness
        candidate = VisionEvent(
          type: VisionEventType.idleOrAway,
          label: 'Host Stepped Away',
          score: motionScore,
          timestamp: now,
        );
        _consecutiveLowMotionFrames = 0;
      }
    } else {
      _consecutiveLowMotionFrames = 0;
    }

    if (candidate != null) {
      _lastDetectedEvent = candidate;
      if (canEmitEvent) {
        _lastEventTime = now;
        _onVisualEvent?.call(candidate);
      }
    }
  }

  /// Synchronously terminates the session and frees memory (zero-persistence compliance)
  void stopSession() {
    _isActive = false;
    _isProcessing = false;
    _onVisualEvent = null;
    _previousYSubsample = null;
    _lastDetectedEvent = null;
    _currentMotionScore = 0.0;
    _currentLuminance = 0.5;
    _previousLuminance = 0.5;
    _consecutiveLowMotionFrames = 0;
    notifyListeners();
  }

  /// Visible for unit testing visual event triggers
  @visibleForTesting
  void simulateVisualEvent(VisionEventType type, {double score = 0.85}) {
    String label = 'High Energy Movement';
    switch (type) {
      case VisionEventType.personEntered:
        label = 'Someone Entered Frame 👀';
        break;
      case VisionEventType.highMotion:
        label = 'High Energy Movement';
        break;
      case VisionEventType.closeUpFocus:
        label = 'Close-Up Showcase';
        break;
      case VisionEventType.lightingShift:
        label = 'Lighting Shift';
        break;
      case VisionEventType.idleOrAway:
        label = 'Host Stepped Away';
        break;
      case VisionEventType.normal:
        label = 'Broadcast Active';
        break;
    }
    final event = VisionEvent(
      type: type,
      label: label,
      score: score,
      timestamp: DateTime.now(),
    );
    _lastDetectedEvent = event;
    _onVisualEvent?.call(event);
    notifyListeners();
  }
}
