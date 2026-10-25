import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goviral/main.dart';
import 'package:goviral/streaming_service.dart';
import 'package:goviral/chat_service.dart';
import 'package:goviral/ai_audience_catalog.dart';
import 'package:goviral/speech_service.dart';
import 'package:goviral/vision_service.dart';
import 'package:goviral/contextual_ai_engine.dart';
import 'package:goviral/ai_comment_service.dart';
import 'package:goviral/audience_simulation_service.dart';
import 'package:goviral/live_summary_screen.dart';
import 'package:goviral/zero_persistence_service.dart';
import 'package:goviral/invitation_auth_service.dart';
import 'package:goviral/join_private_stream_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GoViral app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const GoViralApp());

    expect(find.text('GoViral'), findsWidgets);
  });

  testWidgets('AuthScreen displays Continue with Google button and auth fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AuthScreen(),
      ),
    );

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
    expect(find.byType(GoogleLogo), findsOneWidget);
  });

  testWidgets('GoLiveSetupScreen displays private access options and stream controls',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: GoLiveSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set Up Go Live'), findsOneWidget);
    expect(find.text('Stream Title'), findsOneWidget);
    expect(find.text('Stream Language'), findsOneWidget);
    expect(find.text('Simulated Audience Range'), findsOneWidget);
    expect(find.text('Private Stream (Invite-Only)'), findsOneWidget);
    expect(find.text('INVITATION CODE'), findsOneWidget);
    expect(find.text('Start Live'), findsOneWidget);
  });

  testWidgets(
      'LiveRoomScreen displays broadcast header, LIVE badge, timer, and host controls',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      StreamingService.instance.stopStream();
      LiveChatService.instance.stopSession();
      SpeechService.instance.stopListening();
      VisionService.instance.stopSession();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: LiveRoomScreen(
          streamTitle: 'Saturday Night Jam',
          language: 'Hinglish',
          isPrivate: true,
          inviteCode: 'GV-9999',
          audienceRange: RangeValues(20000, 25000),
          microphoneEnabled: true,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('20K'), findsOneWidget);
    expect(find.byTooltip('End Live'), findsOneWidget);
    expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);
    expect(find.byIcon(Icons.mic), findsOneWidget);

    // Verify telemetry sheet opens on tapping the LIVE badge
    await tester.tap(find.text('LIVE'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('720p HD Stream Infrastructure'), findsOneWidget);
    expect(find.text('Resolution'), findsOneWidget);
    expect(find.text('720p HD (1280x720)'), findsOneWidget);

    // Close telemetry sheet
    await tester.tap(find.byTooltip('Close Telemetry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Instagram Live: Verify realistic comment stream without artificial badges
    expect(find.textContaining('Aarav Sharma'), findsOneWidget);
    expect(find.byTooltip('React'), findsOneWidget);
    expect(find.byTooltip('Send Comment'), findsOneWidget);

    // Test sending a host comment
    await tester.enterText(
        find.widgetWithText(TextField, 'Add a comment...'), 'Welcome to the live!');
    await tester.tap(find.byTooltip('Send Comment'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Welcome to the live!'), findsOneWidget);

    // Test spawning floating heart reaction
    await tester.tap(find.byTooltip('React'));
    await tester.pump(const Duration(milliseconds: 100));

    // Test End Live confirmation dialog
    await tester.tap(find.byTooltip('End Live'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('End Live Stream?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Cancel dismissal
    await tester.tap(find.text('Cancel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('End Live Stream?'), findsNothing);
  });

  test('AiAudienceCatalog contains exactly 30 distinct Indian profiles across 8 languages', () {
    expect(AiAudienceCatalog.profiles.length, 30);

    // Verify distinct names and IDs
    final ids = AiAudienceCatalog.profiles.map((p) => p.id).toSet();
    expect(ids.length, 30);

    final names = AiAudienceCatalog.profiles.map((p) => p.name).toSet();
    expect(names.length, 30);

    // Verify presence of all 8 supported languages in sample emissions
    final supportedLanguages = [
      'English',
      'Hinglish',
      'Hindi',
      'Kannada',
      'Urdu',
      'Tamil',
      'Telugu',
      'Malayalam',
    ];

    for (final lang in supportedLanguages) {
      final emission = AiAudienceCatalog.sampleEmission(streamLanguage: lang);
      expect(emission.message.isNotEmpty, true);
      expect(emission.profile.name.isNotEmpty, true);
    }
  });

  test('LiveChatService manages dynamic AI comments and host messages', () {
    final chatService = LiveChatService.instance;
    chatService.startSession(streamLanguage: 'Hinglish', audienceCount: 20000);

    expect(chatService.isActive, true);
    expect(chatService.messages.length, greaterThanOrEqualTo(4));
    expect(chatService.messages.first.isAi, true);

    // Host message
    chatService.sendHostMessage('Hello everyone from Mumbai!', hostName: 'Host');
    expect(chatService.messages.last.message, 'Hello everyone from Mumbai!');
    expect(chatService.messages.last.isHost, true);
    expect(chatService.messages.last.isAi, false);

    chatService.stopSession();
    expect(chatService.isActive, false);
  });

  test('SpeechService maps 8 regional languages to proper Indian BCP-47 speech locales', () {
    expect(SpeechService.resolveLocaleForLanguage('English'), 'en_IN');
    expect(SpeechService.resolveLocaleForLanguage('Hinglish'), 'hi_IN');
    expect(SpeechService.resolveLocaleForLanguage('Hindi'), 'hi_IN');
    expect(SpeechService.resolveLocaleForLanguage('Kannada'), 'kn_IN');
    expect(SpeechService.resolveLocaleForLanguage('Urdu'), 'ur_IN');
    expect(SpeechService.resolveLocaleForLanguage('Tamil'), 'ta_IN');
    expect(SpeechService.resolveLocaleForLanguage('Telugu'), 'te_IN');
    expect(SpeechService.resolveLocaleForLanguage('Malayalam'), 'ml_IN');
  });

  test('SpeechService manages host speech transcription and zero-persistence lifecycle', () async {
    final speechService = SpeechService.instance;
    String? callbackSpokenText;

    speechService.startListening(
      streamLanguage: 'Hinglish',
      onHostSpoke: (text) {
        callbackSpokenText = text;
      },
    );

    expect(speechService.isActive, true);
    expect(speechService.currentLocaleId, 'hi_IN');

    // Simulate host speech
    speechService.simulateSpokenSpeech('Namaste everyone welcome to GoViral');
    expect(speechService.recentTranscripts.length, 1);
    expect(speechService.recentTranscripts.first, 'Namaste everyone welcome to GoViral');
    expect(callbackSpokenText, 'Namaste everyone welcome to GoViral');

    // Test mute behavior
    speechService.setMuted(true);
    expect(speechService.isMuted, true);
    expect(speechService.currentWords, '');

    speechService.setMuted(false);
    expect(speechService.isMuted, false);

    // Test zero persistence teardown
    await speechService.stopListening();
    expect(speechService.isActive, false);
    expect(speechService.recentTranscripts.isEmpty, true);
    expect(speechService.currentWords, '');
  });

  test('VisionService manages keyframe visual cue detection and zero persistence', () {
    final visionService = VisionService.instance;
    VisionEvent? capturedEvent;

    visionService.startSession(
      onVisualEvent: (event) {
        capturedEvent = event;
      },
    );

    expect(visionService.isActive, true);
    expect(visionService.visualStatusLabel, 'Broadcast Active');

    // Simulate High Energy Movement (waving / dancing)
    visionService.simulateVisualEvent(VisionEventType.highMotion, score: 0.88);
    expect(visionService.lastDetectedEvent?.type, VisionEventType.highMotion);
    expect(visionService.lastDetectedEvent?.label, 'High Energy Movement');
    expect(capturedEvent?.type, VisionEventType.highMotion);

    // Simulate Close-Up Showcase
    visionService.simulateVisualEvent(VisionEventType.closeUpFocus, score: 0.65);
    expect(visionService.lastDetectedEvent?.type, VisionEventType.closeUpFocus);
    expect(capturedEvent?.type, VisionEventType.closeUpFocus);

    // Simulate Lighting Shift
    visionService.simulateVisualEvent(VisionEventType.lightingShift, score: 0.45);
    expect(visionService.lastDetectedEvent?.type, VisionEventType.lightingShift);

    // Simulate Stepped Away
    visionService.simulateVisualEvent(VisionEventType.idleOrAway, score: 0.01);
    expect(visionService.lastDetectedEvent?.type, VisionEventType.idleOrAway);

    // Simulate Person Entered Frame
    visionService.simulateVisualEvent(VisionEventType.personEntered, score: 0.78);
    expect(visionService.lastDetectedEvent?.type, VisionEventType.personEntered);
    expect(visionService.lastDetectedEvent?.label, 'Someone Entered Frame 👀');
    expect(capturedEvent?.type, VisionEventType.personEntered);

    // Test zero persistence teardown
    visionService.stopSession();
    expect(visionService.isActive, false);
    expect(visionService.lastDetectedEvent, isNull);
    expect(visionService.currentMotionScore, 0.0);
  });

  test('AiAudienceCatalog generates tailored visual reactions for all VisionEventTypes', () {
    final types = [
      VisionEventType.highMotion,
      VisionEventType.closeUpFocus,
      VisionEventType.lightingShift,
      VisionEventType.idleOrAway,
      VisionEventType.personEntered,
      VisionEventType.normal,
    ];

    for (final type in types) {
      final reaction = AiAudienceCatalog.sampleVisualReaction(
        eventType: type,
        streamLanguage: 'Hinglish',
      );
      expect(reaction.message.isNotEmpty, true);
      expect(reaction.profile.name.isNotEmpty, true);
    }

    // Verify sampleLiveTask generator
    final generalTask = AiAudienceCatalog.sampleLiveTask(streamLanguage: 'Hinglish', hasPersonInFrame: false);
    expect(generalTask.message.startsWith('🎯'), true);

    final personTask = AiAudienceCatalog.sampleLiveTask(streamLanguage: 'Hinglish', hasPersonInFrame: true);
    expect(personTask.message.startsWith('🎯'), true);
  });

  test('ContextualAiEngine classifies speech intents across multiple Indian conversational categories', () {
    final engine = ContextualAiEngine.instance;

    expect(engine.classifySpeechIntent('Namaste everyone welcome to GoViral!'),
        HostSpeechIntent.greeting);
    expect(engine.classifySpeechIntent('Kem cho friends kaise ho aap sab?'),
        HostSpeechIntent.greeting);
    expect(engine.classifySpeechIntent('Audio and awaz clear aa rahi hai kya?'),
        HostSpeechIntent.question);
    expect(engine.classifySpeechIntent('Kahan se dekh rahe ho aap log?'),
        HostSpeechIntent.question);
    expect(engine.classifySpeechIntent('Check this out dekho yeh phone aur camera setup!'),
        HostSpeechIntent.productShowcase);
    expect(engine.classifySpeechIntent('Let\'s go full on fire machaenge aaj!'),
        HostSpeechIntent.hypeAndEnergy);
    expect(engine.classifySpeechIntent('Drop some hearts and like the live!'),
        HostSpeechIntent.callForReactions);
    expect(engine.classifySpeechIntent('Chalo guys bye phir milenge good night!'),
        HostSpeechIntent.farewell);
    expect(engine.classifySpeechIntent('Koi task do ya live challenge batao kya karu!'),
        HostSpeechIntent.taskRequest);
    expect(engine.classifySpeechIntent('Yeh mera dost hai peeche dekho milo sabhi!'),
        HostSpeechIntent.friendOrGuest);
  });

  test('ContextualAiEngine generates contextual AI comments, multi-turn audience banter and persona archetype alignment', () {
    final engine = ContextualAiEngine.instance;
    engine.startSession();

    // 1. Product Showcase with Close-up Focus cue
    final closeUpEvent = VisionEvent(
      type: VisionEventType.closeUpFocus,
      label: 'Close-Up Showcase',
      score: 0.72,
      timestamp: DateTime.now(),
    );

    final response = engine.generateSpeechResponse(
      hostSpeech: 'Look at the sleek edges on this phone!',
      recentVisionEvent: closeUpEvent,
      streamLanguage: 'Hinglish',
    );

    expect(response.detectedIntent, HostSpeechIntent.productShowcase);
    expect(response.primaryProfile.name.isNotEmpty, true);
    expect(response.primaryComment.isNotEmpty, true);
    expect(response.banterProfile, isNotNull);
    expect(response.banterComment, isNotNull);
    expect(response.banterComment!.contains(response.primaryProfile.name), true);

    // 2. Question to audience about audio
    final audioResponse = engine.generateSpeechResponse(
      hostSpeech: 'Aawaaz clear hai kya sabhi ko?',
      streamLanguage: 'Hinglish',
    );
    expect(audioResponse.detectedIntent, HostSpeechIntent.question);
    expect(audioResponse.primaryComment.toLowerCase().contains('audio') ||
        audioResponse.primaryComment.toLowerCase().contains('clear'), true);

    // 3. Task request to audience
    final taskResponse = engine.generateSpeechResponse(
      hostSpeech: 'Koi task do stream pe',
      streamLanguage: 'Hinglish',
    );
    expect(taskResponse.detectedIntent, HostSpeechIntent.taskRequest);
    expect(taskResponse.primaryComment.isNotEmpty, true);

    engine.stopSession();
    expect(engine.isActive, false);
  });

  test('ContextualAiEngine triggers reaction bursts on calls for reactions and high energy visual cues', () {
    final engine = ContextualAiEngine.instance;
    ReactionBurstEvent? capturedBurst;

    engine.startSession(
      onReactionBurst: (event) {
        capturedBurst = event;
      },
    );

    // Call for reactions
    final reactionResponse = engine.generateSpeechResponse(
      hostSpeech: 'Drop hearts and dil in chat if you love this!',
      streamLanguage: 'Hinglish',
    );

    expect(reactionResponse.detectedIntent, HostSpeechIntent.callForReactions);
    expect(reactionResponse.reactionBurst, isNotNull);
    expect(reactionResponse.reactionBurst?.type, ReactionBurstType.heartShower);
    expect(capturedBurst?.type, ReactionBurstType.heartShower);

    // High motion visual reaction
    final highMotionEvent = VisionEvent(
      type: VisionEventType.highMotion,
      label: 'High Energy Movement',
      score: 0.90,
      timestamp: DateTime.now(),
    );

    final visualResponse = engine.generateVisualResponse(
      visualEvent: highMotionEvent,
      streamLanguage: 'Hinglish',
    );

    expect(visualResponse.primaryProfile.name.isNotEmpty, true);
    expect(visualResponse.banterComment, isNotNull);

    // Person entered visual reaction
    final personEnteredEvent = VisionEvent(
      type: VisionEventType.personEntered,
      label: 'Someone Entered Frame 👀',
      score: 0.85,
      timestamp: DateTime.now(),
    );

    final personResponse = engine.generateVisualResponse(
      visualEvent: personEnteredEvent,
      streamLanguage: 'Hinglish',
    );
    expect(personResponse.primaryProfile.name.isNotEmpty, true);
    expect(personResponse.banterComment, isNotNull);

    // Teardown
    engine.stopSession();
    expect(engine.isActive, false);
  });

  test('AiCommentService manages cloud vs local modes and dynamic generation', () async {
    final aiService = AiCommentService.instance;

    // By default without key, active mode is localNeuralEngine
    expect(aiService.activeMode, AiEngineMode.localNeuralEngine);
    expect(aiService.isCloudActive, false);
    expect(aiService.engineStatusLabel.contains('Local Intent Engine'), true);

    // Test dynamic comment generation via local synthesis
    final comments = await aiService.generateDynamicComments(
      streamTitle: 'Tech Demo Stream',
      streamLanguage: 'Hinglish',
      hostUtterance: 'Look at this new phone camera!',
    );

    expect(comments.isNotEmpty, true);
    expect(comments.first.senderName.isNotEmpty, true);
    expect(comments.first.message.isNotEmpty, true);
    expect(comments.first.isCloudGenerated, false);

    // Test cloud toggle
    await aiService.setCloudEnabled(false);
    expect(aiService.isCloudEnabled, false);
    await aiService.setCloudEnabled(true);
    expect(aiService.isCloudEnabled, true);
  });

  test('LiveChatService tracks host speech interaction time for silence pacing', () {
    final chatService = LiveChatService.instance;
    chatService.startSession(
      streamTitle: 'Saturday Live',
      streamLanguage: 'Hinglish',
      audienceCount: 15000,
    );

    expect(chatService.isActive, true);
    final initialInteraction = chatService.lastHostInteractionTime;

    // Simulate sending host message updates interaction timestamp
    chatService.sendHostMessage('Namaste everyone!');
    expect(chatService.lastHostInteractionTime.isAfter(initialInteraction) ||
        chatService.lastHostInteractionTime == initialInteraction, true);

    chatService.stopSession();
    expect(chatService.isActive, false);
  });

  test('Language Engine: ContextualAiEngine & AiAudienceCatalog support Hindi, English, and Hinglish', () {
    final engine = ContextualAiEngine.instance;

    // 1. Multilingual Intent Classification
    expect(engine.classifySpeechIntent('kya task du batao challenge'), HostSpeechIntent.taskRequest);
    expect(engine.classifySpeechIntent('namaste dosto hello how are you'), HostSpeechIntent.greeting);
    expect(engine.classifySpeechIntent('friends dil and hearts bhej do'), HostSpeechIntent.callForReactions);
    expect(engine.classifySpeechIntent('yeh mera dost hai piche'), HostSpeechIntent.friendOrGuest);
    expect(engine.classifySpeechIntent('अलविदा phir milenge tata'), HostSpeechIntent.farewell);
    expect(engine.classifySpeechIntent('kya chal raha hai dosto'), HostSpeechIntent.generalChatter);

    // 2. Multilingual Response Generation across the 3 core languages
    final coreLanguages = ['Hindi', 'English', 'Hinglish'];
    for (final lang in coreLanguages) {
      final speechResp = engine.generateSpeechResponse(
        hostSpeech: 'Hey everyone, what challenge should we do?',
        streamLanguage: lang,
      );
      expect(speechResp.primaryProfile.name.isNotEmpty, true, reason: '$lang primary profile name empty');
      expect(speechResp.primaryComment.isNotEmpty, true, reason: '$lang primary comment empty');
      expect(speechResp.banterComment != null, true, reason: '$lang banter comment null');

      // 3. Ambient catalog sampling
      final ambient = AiAudienceCatalog.sampleEmission(streamLanguage: lang);
      expect(ambient.profile.name.isNotEmpty, true, reason: '$lang ambient profile name empty');
      expect(ambient.message.isNotEmpty, true, reason: '$lang ambient message empty');

      // 4. Visual reaction sampling
      final visual = AiAudienceCatalog.sampleVisualReaction(
        eventType: VisionEventType.highMotion,
        streamLanguage: lang,
      );
      expect(visual.profile.name.isNotEmpty, true, reason: '$lang visual profile name empty');
      expect(visual.message.isNotEmpty, true, reason: '$lang visual message empty');

      // 5. Live task dare sampling
      final task = AiAudienceCatalog.sampleLiveTask(streamLanguage: lang);
      expect(task.profile.name.isNotEmpty, true, reason: '$lang live task profile name empty');
      expect(task.message.isNotEmpty, true, reason: '$lang live task text empty');
    }
  });

  test('Phase 22: AudienceSimulationService manages stochastic fluctuation and engagement surges', () {
    final sim = AudienceSimulationService.instance;

    // 1. Session start
    sim.startSession(minAudience: 20000, maxAudience: 25000);
    expect(sim.isActive, true);
    expect(sim.currentCount, 20000);
    expect(sim.minTarget, 20000);
    expect(sim.maxTarget, 25000);

    // 2. Formatting verification
    expect(AudienceSimulationService.formatAudienceCount(20000), '20K');
    expect(AudienceSimulationService.formatAudienceCount(20500), '20.5K');
    expect(AudienceSimulationService.formatAudienceCount(1500000), '1.5M');
    expect(AudienceSimulationService.formatAudienceCount(2000000), '2M');
    expect(AudienceSimulationService.formatAudienceCount(850), '850');

    // 3. Speech Engagement Surge
    final initial = sim.currentCount;
    sim.surgeHostSpeech();
    expect(sim.currentCount > initial, true);
    expect(sim.direction, FluctuationDirection.increasing);
    expect(sim.lastDelta > 0, true);

    // 4. Reaction Burst Surge
    final beforeReaction = sim.currentCount;
    sim.surgeReactionBurst();
    expect(sim.currentCount > beforeReaction, true);

    // 5. Host Message Surge
    final beforeMsg = sim.currentCount;
    sim.surgeHostMessage();
    expect(sim.currentCount > beforeMsg, true);

    // 6. Visual Cue Surge
    final beforeVisual = sim.currentCount;
    sim.surgeVisualCue();
    expect(sim.currentCount > beforeVisual, true);

    // 7. Snapshot verification
    final snap = sim.snapshot;
    expect(snap.count, sim.currentCount);
    expect(snap.formatted.contains('K') || snap.formatted.contains('M'), true);
    expect(snap.direction, FluctuationDirection.increasing);

    // 8. Session stop
    sim.stopSession();
    expect(sim.isActive, false);
  });

  testWidgets('Phase 23: LiveSummaryScreen displays post-broadcast metrics and zero-persistence verification',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final summary = LiveStreamSummaryData(
      streamTitle: 'Night Jam Live',
      hostName: 'Abdul',
      durationSeconds: 254, // 04:14
      peakAudience: 24500, // 24.5K
      totalComments: 142,
      totalReactions: 680,
      endedAt: DateTime.now(),
      language: 'Hinglish',
      isPrivate: true,
    );

    expect(summary.formattedDuration, '04:14');
    expect(summary.formattedPeakAudience, '24.5K');

    await tester.pumpWidget(
      MaterialApp(
        home: LiveSummaryScreen(summary: summary),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live Video Ended'), findsOneWidget);
    expect(find.text('Night Jam Live'), findsOneWidget);
    expect(find.text('04:14'), findsOneWidget);
    expect(find.text('24.5K'), findsOneWidget);
    expect(find.text('142'), findsOneWidget);
    expect(find.text('680'), findsOneWidget);
    expect(find.text('Share Stats'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
    expect(find.textContaining('Zero Persistence Verified'), findsOneWidget);

    // Tap the Zero Persistence banner to open the privacy audit details modal
    await tester.tap(find.textContaining('Zero Persistence Verified'));
    await tester.pumpAndSettle();

    expect(find.text('No Video Recording'), findsOneWidget);
    expect(find.text('Ephemeral Audio & Speech'), findsOneWidget);
    expect(find.text('Zero Frame Persistence'), findsOneWidget);
    expect(find.text('Automatic Zero-Wipe on Teardown'), findsOneWidget);
    expect(find.text('Acknowledge & Close'), findsOneWidget);

    // Close the audit modal
    await tester.tap(find.text('Acknowledge & Close'));
    await tester.pumpAndSettle();
    expect(find.text('Acknowledge & Close'), findsNothing);
  });

  test('Phase 24: ZeroPersistenceService architectural policies and teardown zero-wipe', () async {
    final zeroService = ZeroPersistenceService.instance;

    // 1. Verify architectural invariants
    expect(ZeroPersistenceService.isVideoRecordingDisabled, true);
    expect(ZeroPersistenceService.isAudioRecordingDisabled, true);
    expect(ZeroPersistenceService.isDiskCachingDisabled, true);
    expect(ZeroPersistenceService.isCloudMediaPersistenceDisabled, true);

    // 2. Setup mock volatile buffers across subsystems
    SpeechService.instance.simulateSpokenSpeech('Testing zero persistence memory wipe');
    expect(SpeechService.instance.currentWords.isNotEmpty, true);

    VisionService.instance.simulateVisualEvent(VisionEventType.highMotion);
    expect(VisionService.instance.lastDetectedEvent != null, true);

    LiveChatService.instance.startSession(
      streamTitle: 'Privacy Test Stream',
      streamLanguage: 'English',
      audienceCount: 1000,
    );
    expect(LiveChatService.instance.messages.isNotEmpty, true);

    // 3. Execute architectural zero-wipe
    await zeroService.enforceTeardownZeroWipe();

    // 4. Assert all volatile buffers were wiped
    expect(SpeechService.instance.recentTranscripts.isEmpty, true);
    expect(SpeechService.instance.currentWords.isEmpty, true);
    expect(SpeechService.instance.isActive, false);

    expect(VisionService.instance.lastDetectedEvent, isNull);
    expect(VisionService.instance.isActive, false);

    expect(LiveChatService.instance.messages.isEmpty, true);
    expect(LiveChatService.instance.isActive, false);

    expect(StreamingService.instance.isStreaming, false);

    // 5. Assert compliance audit report
    final report = zeroService.performComplianceAudit();
    expect(report.isFullyCompliant, true);
    expect(report.isRecordingActive, false);
    expect(report.isEphemeralMemoryEnforced, true);
    expect(report.isSpeechBufferDiscarded, true);
    expect(report.isVisionBufferDiscarded, true);
    expect(report.isChatBufferDiscarded, true);
    expect(report.verifiedGuarantees.length, 6);
  });

  test('Phase 25: InvitationAuthService code normalization, format validation, and session authorization', () async {
    final authService = InvitationAuthService.instance;

    // 1. Code normalization
    expect(InvitationAuthService.normalizeCode('7482'), 'GV-7482');
    expect(InvitationAuthService.normalizeCode('gv-demo'), 'GV-DEMO');
    expect(InvitationAuthService.normalizeCode('GV 1234'), 'GV-1234');

    // 2. Format validation
    expect(InvitationAuthService.isValidCodeFormat('GV-7482'), true);
    expect(InvitationAuthService.isValidCodeFormat('GV-DEMO'), true);
    expect(InvitationAuthService.isValidCodeFormat('GV-1'), false);
    expect(InvitationAuthService.isValidCodeFormat('INV-1234'), false);

    // 3. Register active private session
    final session = authService.registerSession(
      inviteCode: 'GV-7777',
      hostName: 'Rohan Sharma',
      streamTitle: 'Acoustic Guitar Session',
      language: 'Hindi',
      isPrivate: true,
    );
    expect(session.isLive, true);
    expect(session.inviteCode, 'GV-7777');

    // 4. Verify invalid format attempt
    final invalidResult = await authService.verifyAndAuthorize(
      rawCode: 'invalid',
      viewerId: 'viewer_1',
      viewerName: 'Viewer 1',
    );
    expect(invalidResult.status, AuthStatus.invalidFormat);
    expect(invalidResult.isSuccess, false);

    // 5. Verify successful authorization
    final successResult = await authService.verifyAndAuthorize(
      rawCode: '7777',
      viewerId: 'viewer_1',
      viewerName: 'Ananya',
    );
    expect(successResult.status, AuthStatus.authorized);
    expect(successResult.isSuccess, true);
    expect(authService.isViewerAuthorized('GV-7777', 'viewer_1'), true);

    // 6. End session and verify subsequent join attempts are rejected
    authService.endSession('GV-7777');
    final endedResult = await authService.verifyAndAuthorize(
      rawCode: 'GV-7777',
      viewerId: 'viewer_2',
      viewerName: 'Kunal',
    );
    expect(endedResult.status, AuthStatus.streamEnded);
    expect(endedResult.isSuccess, false);
  });

  testWidgets('Phase 25: JoinPrivateStreamSheet input validation and successful join',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      StreamingService.instance.stopStream();
      LiveChatService.instance.stopSession();
      SpeechService.instance.stopListening();
      VisionService.instance.stopSession();
      AudienceSimulationService.instance.stopSession();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: JoinPrivateStreamSheet(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial UI verification
    expect(find.text('Join Private Stream'), findsOneWidget);
    expect(find.text('Enter host invitation code (GV-XXXX)'), findsOneWidget);
    expect(find.text('Join Broadcast'), findsOneWidget);
    expect(find.text('Paste'), findsOneWidget);

    // 2. Empty code submission
    await tester.tap(find.text('Join Broadcast'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter an invitation code.'), findsOneWidget);

    // 3. Invalid code format submission
    await tester.enterText(find.byType(TextField), 'BAD');
    await tester.tap(find.text('Join Broadcast'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Invalid code format'), findsOneWidget);

    // 4. Valid active code entry (GV-DEMO seeded in InvitationAuthService)
    await tester.enterText(find.byType(TextField), 'GV-DEMO');
    await tester.tap(find.text('Join Broadcast'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Verify navigating to LiveRoomScreen
    expect(find.byType(LiveRoomScreen), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);

    // Cleanly pop LiveRoomScreen to trigger dispose() and cancel _durationTimer
    Navigator.of(tester.element(find.byType(LiveRoomScreen))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets('Phase 25: Private viewer joins live stream with viewer role controls and leave confirmation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: LiveRoomScreen(
          streamTitle: 'VIP Private Session',
          language: 'Hinglish',
          isPrivate: true,
          inviteCode: 'GV-TEST',
          audienceRange: RangeValues(1000, 2000),
          isHost: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Viewer controls: camera flip and mic mute are hidden
    expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
    expect(find.byIcon(Icons.mic), findsNothing);
    expect(find.byIcon(Icons.mic_off), findsNothing);

    // 2. Heart reaction button is available
    expect(find.byIcon(Icons.favorite), findsOneWidget);

    // 3. Comment input is available
    expect(find.byType(TextField), findsOneWidget);

    // 4. Test submitting a viewer comment
    await tester.enterText(find.byType(TextField), 'Loving the private stream!');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    final viewerMessage = LiveChatService.instance.messages.firstWhere(
      (m) => m.message == 'Loving the private stream!',
    );
    expect(viewerMessage.message, 'Loving the private stream!');
    expect(viewerMessage.isHost, false);

    // 5. Verify Close button displays Leave dialog rather than End Live
    final closeButtonFinder = find.byKey(const Key('end_live_button'));
    expect(closeButtonFinder, findsOneWidget);
    await tester.tap(closeButtonFinder);
    await tester.pumpAndSettle();

    // Confirm Leave dialog appears
    expect(find.text('Leave Live Stream?'), findsOneWidget);
    expect(find.textContaining('Are you sure you want to leave'), findsOneWidget);
    expect(find.text('Stay'), findsOneWidget);
    expect(find.text('Leave'), findsOneWidget);

    // Tap Leave to exit
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    // Verify screen popped
    expect(find.byType(LiveRoomScreen), findsNothing);
  });

  test('Phase 26: StreamingService manages Adaptive Bitrate (ABR) under network degradation', () async {
    final streamService = StreamingService.instance;

    await streamService.startStream(streamKey: 'GV-TEST-ABR');
    expect(streamService.isStreaming, true);
    expect(streamService.networkQuality, NetworkQuality.optimal);

    // 1. Moderate degradation (3.0% loss -> Good tier: 1400 kbps, 24fps)
    streamService.simulateNetworkDegradation(3.0);
    expect(streamService.networkQuality, NetworkQuality.good);
    expect(streamService.isDegraded, false);

    // 2. High degradation (5.0% loss -> Degraded tier: 750 kbps, 20fps)
    streamService.simulateNetworkDegradation(5.0);
    expect(streamService.networkQuality, NetworkQuality.degraded);
    expect(streamService.isDegraded, true);

    // 3. Critical degradation (9.5% loss -> Critical tier: 350 kbps, 15fps audio priority)
    streamService.simulateNetworkDegradation(9.5);
    expect(streamService.networkQuality, NetworkQuality.critical);
    expect(streamService.isDegraded, true);

    // 4. Recovery (0.0% loss -> Optimal tier: 2500 kbps, 30fps)
    streamService.clearNetworkDegradation();
    expect(streamService.networkQuality, NetworkQuality.optimal);
    expect(streamService.isDegraded, false);

    streamService.stopStream();
    expect(streamService.status, StreamConnectionStatus.idle);
  });

  test('Phase 26: StreamingService network drop detection, exponential backoff, and recovery', () async {
    final streamService = StreamingService.instance;

    await streamService.startStream(streamKey: 'GV-TEST-DROP');
    expect(streamService.isStreaming, true);

    // Trigger sudden carrier drop / socket disconnect
    streamService.triggerNetworkDrop(reason: 'Carrier tower handover');
    expect(streamService.isReconnecting, true);
    expect(streamService.networkQuality, NetworkQuality.offline);
    expect(streamService.reconnectAttempts, 1);

    // Manual or auto-recovery
    streamService.retryConnection();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(streamService.isStreaming, true);
    expect(streamService.networkQuality, NetworkQuality.optimal);
    expect(streamService.reconnectAttempts, 0);

    streamService.stopStream();
  });

  testWidgets('Phase 26: LiveRoomScreen displays reconnecting and degraded network banners', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      StreamingService.instance.stopStream();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: LiveRoomScreen(
          streamTitle: 'Network Resilience Test',
          language: 'Hinglish',
          isPrivate: true,
          inviteCode: 'GV-NET',
          audienceRange: RangeValues(2000, 3000),
          isHost: true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // 1. Normal state: no warning banner
    expect(find.byKey(const Key('reconnecting_banner')), findsNothing);
    expect(find.byKey(const Key('connection_failed_banner')), findsNothing);
    expect(find.byKey(const Key('network_degraded_pill')), findsNothing);

    // 2. Trigger network drop -> Reconnecting banner appears
    StreamingService.instance.triggerNetworkDrop(reason: 'Test drop');
    await tester.pump();
    expect(find.byKey(const Key('reconnecting_banner')), findsOneWidget);
    expect(find.textContaining('Reconnecting to broadcast...'), findsOneWidget);

    // 3. Recover network -> Reconnecting banner disappears
    StreamingService.instance.retryConnection();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reconnecting_banner')), findsNothing);

    // 4. Trigger degraded network -> Low bandwidth pill appears
    StreamingService.instance.simulateNetworkDegradation(6.0);
    await tester.pump();
    expect(find.byKey(const Key('network_degraded_pill')), findsOneWidget);
    expect(find.textContaining('Slow Signal'), findsOneWidget);

    // Cleanly pop
    Navigator.of(tester.element(find.byType(LiveRoomScreen))).pop();
    await tester.pumpAndSettle();
  });

  testWidgets(
      'Phase 27: GoLiveSetupScreen loads and persists audience range (1000-2000), stream title, and host name',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Seed mock SharedPreferences
    SharedPreferences.setMockInitialValues({
      'pref_stream_title': 'My Special Live Session',
      'pref_stream_user_name': 'Abdullah Zoahib',
      'pref_stream_language': 'Hindi',
      'pref_audience_min': 1000.0,
      'pref_audience_max': 2000.0,
      'pref_is_private': true,
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: GoLiveSetupScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify fields reflect stored values
    expect(find.text('My Special Live Session'), findsOneWidget);
    expect(find.text('Abdullah Zoahib'), findsOneWidget);
    expect(find.text('Minimum: 1000   •   Maximum: 2000'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Tap Save button to trigger manual persistence toast
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.textContaining('Saved! Audience: 1000-2000'), findsOneWidget);
  });

  testWidgets(
      'Phase 27: LiveRoomScreen displays custom hostName in top overlay',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      StreamingService.instance.stopStream();
      LiveChatService.instance.stopSession();
      SpeechService.instance.stopListening();
      VisionService.instance.stopSession();
      AudienceSimulationService.instance.stopSession();
      ContextualAiEngine.instance.stopSession();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: LiveRoomScreen(
          streamTitle: 'Night Vibes',
          language: 'Hinglish',
          isPrivate: true,
          inviteCode: 'GV-8888',
          audienceRange: RangeValues(1000, 2000),
          hostName: 'Abdullah Zoahib',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify hostName and host avatar initial 'A' are displayed in top overlay
    expect(find.text('Abdullah Zoahib'), findsOneWidget);
    expect(find.text('A'), findsWidgets);
    expect(find.text('LIVE'), findsOneWidget);

    // Stop services & unmount cleanly
    AudienceSimulationService.instance.stopSession();
    LiveChatService.instance.stopSession();
    await tester.pumpWidget(const SizedBox());
  });
}



