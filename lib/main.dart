import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:camera/camera.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'streaming_service.dart';
import 'chat_service.dart';
import 'speech_service.dart';
import 'vision_service.dart';
import 'contextual_ai_engine.dart';
import 'ai_comment_service.dart';
import 'audience_simulation_service.dart';
import 'live_summary_screen.dart';
import 'zero_persistence_service.dart';
import 'invitation_auth_service.dart';
import 'join_private_stream_sheet.dart';

const Color gvBackground = Color(0xFF101018);
const Color gvSurface = Color(0xFF1C1C29);
const Color gvPink = Color(0xFFFF3D8D);
const Color gvPurple = Color(0xFF8758FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phase 26: Global resilient error boundaries protecting against fatal crashes
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[GoViral Exception Guard] ${details.exceptionAsString()}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[GoViral Async Exception Guard] $error');
    return true; // Gracefully handled to prevent unhandled process termination
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '846606492012-8u2qtlpkq9g1dnq1uhf38g8nfpu9a10o.apps.googleusercontent.com',
  );

  await AiCommentService.instance.initialize();

  runApp(const GoViralApp());
}

// ------------------------------------------------------------
// APP
// ------------------------------------------------------------

class GoViralApp extends StatelessWidget {
  const GoViralApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoViral',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: gvBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gvPink,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: gvBackground,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: gvSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ------------------------------------------------------------
// REUSABLE WIDGETS
// ------------------------------------------------------------

class CreatorAvatar extends StatelessWidget {
  final double size;

  const CreatorAvatar({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [gvPink, gvPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gvPink.withValues(alpha: 0.8),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.58,
        color: Colors.white,
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Widget child;

  const SectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: gvSurface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// ------------------------------------------------------------
// HOME SCREEN
// ------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  void openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  Future<void> openGoLive(BuildContext context) async {
    // Guests can explore GoViral, but must sign in before Go Live.
    if (FirebaseAuth.instance.currentUser == null) {
      final signedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );

      if (signedIn != true || !context.mounted) {
        return;
      }
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GoLiveSetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'GoViral',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: gvPink,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => openProfile(context),
            icon: const CreatorAvatar(size: 35),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => openSettings(context),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Live Streaming Studio',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Broadcast live with 30 AI audience members & real-time chat.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 22),

            // Go Live card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3B1D54),
                    Color(0xFF1E1736),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: gvPink.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gvPink.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: gvPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.sensors,
                          size: 32,
                          color: gvPink,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Instant Broadcast',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'One-tap to go live with AI audience',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => openGoLive(context),
                      icon: const Icon(Icons.videocam_rounded),
                      label: const Text(
                        'Set Up Go Live',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: gvPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => JoinPrivateStreamSheet.show(context),
                      icon: const Icon(Icons.vpn_key_outlined, size: 18),
                      label: const Text(
                        'Join Private Stream with Code',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Stream Highlights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SectionCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people_alt_rounded, color: Color(0xFFA29BFE), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '30 Active Indian Personas',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Hindi, English & Hinglish colloquial banter',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SectionCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00CEC9).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.hd_rounded, color: Color(0xFF81ECEC), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '720p HD Portrait Camera',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Smooth 30 FPS video with fast front/rear lens flip',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            SectionCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ED573).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Color(0xFF2ED573), size: 24),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zero Persistence Privacy',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'No recordings or logs saved. Complete peace of mind.',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: gvSurface,
        selectedItemColor: gvPink,
        unselectedItemColor: Colors.white60,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              openGoLive(context);
              break;
            case 2:
              openProfile(context);
              break;
            case 3:
              openSettings(context);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam_outlined),
            label: 'Go Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// PROFILE SCREEN
// ------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = 'GoViral Creator';
  String username = 'goviral_creator';
  String bio = 'Creating moments, one live at a time.';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_display_name') ?? prefs.getString('pref_stream_user_name');
      final savedUser = prefs.getString('user_handle');
      final savedBio = prefs.getString('user_bio');
      if (!mounted) return;
      setState(() {
        if (savedName != null && savedName.trim().isNotEmpty) {
          displayName = savedName.trim();
        }
        if (savedUser != null && savedUser.trim().isNotEmpty) {
          username = savedUser.trim();
        }
        if (savedBio != null && savedBio.trim().isNotEmpty) {
          bio = savedBio.trim();
        }
      });
    } catch (_) {}
  }

  Future<void> _saveProfile(String name, String handle, String newBio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', name);
      await prefs.setString('pref_stream_user_name', name);
      await prefs.setString('user_handle', handle);
      await prefs.setString('user_bio', newBio);
    } catch (_) {}
  }

  Future<void> editProfile() async {
    final nameController = TextEditingController(text: displayName);
    final usernameController = TextEditingController(text: username);
    final bioController = TextEditingController(text: bio);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: gvSurface,
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final handle = usernameController.text
                    .trim()
                    .replaceAll('@', '');

                if (name.isEmpty || handle.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Name and username are required.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'name': name,
                  'username': handle,
                  'bio': bioController.text.trim(),
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();

    if (result != null && mounted) {
      final newName = result['name']!;
      final newUsername = result['username']!;
      final newBio = result['bio'] ?? '';
      setState(() {
        displayName = newName;
        username = newUsername;
        bio = newBio;
      });
      await _saveProfile(newName, newUsername, newBio);
    }
  }

  void openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            const Center(child: CreatorAvatar(size: 105)),
            const SizedBox(height: 16),
            Center(
              child: Text(
                displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 5),
            Center(
              child: Text(
                '@$username',
                style: const TextStyle(
                  color: gvPink,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                bio.isEmpty ? 'No bio added yet.' : bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: editProfile,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: gvPink),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Creator Space & Privacy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: Color(0xFF00E676),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Zero-Persistence Privacy',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your livestreams and voice audio are never recorded or stored on any server or disk. All frames and transcripts are transiently processed in volatile RAM only.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SectionCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.sensors,
                    color: gvPink,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Broadcast Studio',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Camera & AI Audience Ready',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GoLiveSetupScreen(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: gvPink,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Go Live'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// SETTINGS SCREEN
// ------------------------------------------------------------

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkAppearance = true;
  String selectedLanguage = 'English';

  void showLanguagePicker() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          backgroundColor: gvSurface,
          title: const Text('App Language'),
          children: [
            for (final language in [
              'Hindi',
              'English',
              'Hinglish',
            ])
              // ignore: deprecated_member_use
              RadioListTile<String>(
                title: Text(language),
                value: language,
                // ignore: deprecated_member_use
                groupValue: selectedLanguage,
                activeColor: gvPink,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedLanguage = value;
                  });

                  Navigator.pop(dialogContext);
                },
              ),
          ],
        );
      },
    );
  }

  void showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: gvSurface,
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }


  void _configureGeminiApiKey() {
    final aiService = AiCommentService.instance;
    final controller = TextEditingController(text: aiService.geminiApiKey ?? '');
    bool isTesting = false;
    String testStatus = '';
    bool? testSuccess;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: gvSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: gvPurple, size: 22),
                  SizedBox(width: 8),
                  Text('Google Gemini API Key'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Power realistic live audience reactions using Google Gemini 1.5 Flash (free tier available at aistudio.google.com).',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Gemini API Key',
                        hintText: 'AIzaSy...',
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isTesting) ...[
                      const Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: gvPurple),
                          ),
                          SizedBox(width: 8),
                          Text('Validating API key with Google...', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ] else if (testStatus.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            testSuccess == true ? Icons.check_circle : Icons.error_outline,
                            size: 16,
                            color: testSuccess == true ? Colors.greenAccent : Colors.redAccent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              testStatus,
                              style: TextStyle(
                                fontSize: 12,
                                color: testSuccess == true ? Colors.greenAccent : Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: isTesting
                          ? null
                          : () async {
                              final key = controller.text.trim();
                              if (key.isEmpty) {
                                setDialogState(() {
                                  testStatus = 'Please enter an API key to test.';
                                  testSuccess = false;
                                });
                                return;
                              }
                              setDialogState(() {
                                isTesting = true;
                                testStatus = '';
                              });
                              final ok = await aiService.testConnection(key);
                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  isTesting = false;
                                  testSuccess = ok;
                                  testStatus = ok
                                      ? 'Connected successfully! Gemini 1.5 Flash is ready.'
                                      : 'Connection failed: ${aiService.lastErrorMessage}';
                                });
                              }
                            },
                      icon: const Icon(Icons.cable, size: 16),
                      label: const Text('Test Connection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Privacy note: Livestream audio and video frames are processed ephemerally in-memory only (Zero Persistence). No recordings or transcripts are permanently saved.',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              actions: [
                if (aiService.geminiApiKey != null && aiService.geminiApiKey!.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await aiService.setGeminiApiKey(null);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      if (mounted) setState(() {});
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Gemini API key cleared. Using local intent engine.')),
                      );
                    },
                    child: const Text('Clear Key', style: TextStyle(color: Colors.redAccent)),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final key = controller.text.trim();
                    await aiService.setGeminiApiKey(key.isEmpty ? null : key);
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                    if (mounted) setState(() {});
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(key.isNotEmpty
                            ? 'Gemini API key saved! Cloud LLM enabled.'
                            : 'API key cleared. Fallback to local intent engine.'),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: gvPink),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 3,
      ),
      leading: Icon(icon, color: gvPink),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: Colors.white54,
          ),
      onTap: onTap,
    );
  }

  Future<void> handleAccountAction() async {
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      final signedIn = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const AuthScreen(),
        ),
      );

      if (signedIn == true && mounted) {
        setState(() {});
      }

      return;
    }

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: gvSurface,
          title: const Text('Sign out?'),
          content: const Text(
            'You can sign in again whenever you want to use Go Live.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (shouldSignOut != true) return;

    try {
      await auth.signOut();
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have signed out of GoViral.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to sign out. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'PREFERENCES',
              style: TextStyle(
                color: gvPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              child: Column(
                children: [
                  settingsTile(
                    icon: Icons.language,
                    title: 'App language',
                    subtitle: selectedLanguage,
                    onTap: showLanguagePicker,
                  ),
                  const Divider(color: Colors.white12),
                  settingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Push alerts for livestream invitations',
                    trailing: Switch(
                      value: notificationsEnabled,
                      activeThumbColor: gvPink,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  settingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Appearance',
                    subtitle: 'GoViral Dark (OLED Optimized)',
                    trailing: const Icon(
                      Icons.check_circle,
                      color: gvPink,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'AI AUDIENCE & LLM ENGINE',
              style: TextStyle(
                color: gvPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              child: Column(
                children: [
                  ListenableBuilder(
                    listenable: AiCommentService.instance,
                    builder: (context, _) {
                      final ai = AiCommentService.instance;
                      return Column(
                        children: [
                          settingsTile(
                            icon: Icons.psychology,
                            title: 'Active AI Engine',
                            subtitle: ai.engineStatusLabel,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ai.isCloudActive
                                    ? const Color(0xFF6C5CE7).withValues(alpha: 0.3)
                                    : Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ai.isCloudActive
                                      ? const Color(0xFFA29BFE)
                                      : Colors.white24,
                                ),
                              ),
                              child: Text(
                                ai.isCloudActive ? 'CLOUD LLM' : 'LOCAL ENGINE',
                                style: TextStyle(
                                  color: ai.isCloudActive
                                      ? const Color(0xFFA29BFE)
                                      : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const Divider(color: Colors.white12),
                          settingsTile(
                            icon: Icons.key_outlined,
                            title: 'Google Gemini 1.5 Flash Key',
                            subtitle: ai.geminiApiKey != null && ai.geminiApiKey!.isNotEmpty
                                ? '•••••••••••••••• (Configured)'
                                : 'Not configured (Tap to setup)',
                            onTap: _configureGeminiApiKey,
                          ),
                          const Divider(color: Colors.white12),
                          settingsTile(
                            icon: Icons.cloud_outlined,
                            title: 'Enable Cloud Generation',
                            subtitle: 'Toggle Gemini cloud vs local intent engine',
                            trailing: Switch(
                              value: ai.isCloudEnabled,
                              activeThumbColor: gvPink,
                              onChanged: (value) async {
                                await ai.setCloudEnabled(value);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ACCOUNT',
              style: TextStyle(
                color: gvPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              child: Column(
                children: [
                  settingsTile(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Edit your creator information',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(color: Colors.white12),
                  settingsTile(
                    icon: Icons.lock_outline,
                    title: user == null
                        ? 'Sign in / Create account'
                        : 'Sign out',
                    subtitle: user?.email ??
                        'Sign in to manage your account',
                    onTap: handleAccountAction,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'PRIVACY & SUPPORT',
              style: TextStyle(
                color: gvPink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            SectionCard(
              child: Column(
                children: [
                  settingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy & Data Safety',
                    subtitle: 'Zero recordings, volatile RAM processing only',
                    onTap: () {
                      showInfo(
                        'Zero-Persistence Privacy Guarantee',
                        'GoViral operates under a strict Zero-Persistence architecture. Video and audio streams are never recorded or stored on any disk or cloud server. AI audience synthesis and optical motion cues are evaluated in volatile RAM and completely cleared upon session exit.',
                      );
                    },
                  ),
                  const Divider(color: Colors.white12),
                  settingsTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Creator guidance & contact support@goviral.app',
                    onTap: () {
                      showInfo(
                        'Creator Help & Support',
                        'For questions regarding private invitations, camera setup, or AI audience features, contact support@goviral.app or visit goviral.app/help.',
                      );
                    },
                  ),
                  const Divider(color: Colors.white12),
                  settingsTile(
                    icon: Icons.info_outline,
                    title: 'About GoViral',
                    subtitle: 'Version 1.0.0 (Release Build)',
                    onTap: () {
                      showInfo(
                        'About GoViral',
                        'GoViral v1.0.0 is an invitation-based private livestreaming platform. Broadcast in 720p HD with adaptive bitrate, engage with 30 distinct Indian AI viewer personalities across 8 languages, and enjoy total privacy with Zero Persistence.',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'GoViral v1.0.0 • Production Release',
                style: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// GO LIVE SETUP SCREEN
// ------------------------------------------------------------

class GoLiveSetupScreen extends StatefulWidget {
  const GoLiveSetupScreen({super.key});

  @override
  State<GoLiveSetupScreen> createState() => _GoLiveSetupScreenState();
}

class _GoLiveSetupScreenState extends State<GoLiveSetupScreen> {
  final TextEditingController _titleController =
      TextEditingController(text: 'My GoViral Live');
  final TextEditingController _userNameController =
      TextEditingController(text: 'Creator');
  final List<String> languages = const [
    'Hindi',
    'English',
    'Hinglish',
  ];

  String selectedLanguage = 'Hinglish';
  RangeValues audienceRange = const RangeValues(1000, 2000);
  bool cameraPreviewEnabled = false;
  bool microphoneEnabled = false;
  bool isPrivateStream = true;
  String inviteCode = 'GV-7482';

  bool _hasCameraPermission = false;
  bool _hasMicPermission = false;

  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraInitializing = false;

  static double _snapAudience(double val) {
    const step = 500.0;
    final snapped = ((val - 1000.0) / step).round() * step + 1000.0;
    return snapped.clamp(1000.0, 25000.0);
  }

  double? _getPrefDouble(SharedPreferences prefs, String key) {
    try {
      final val = prefs.get(key);
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val);
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _checkInitialPermissions();
    _titleController.addListener(_onFieldEdited);
    _userNameController.addListener(_onFieldEdited);
    _loadSavedPreferences();
  }

  void _onFieldEdited() {
    _saveStreamPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTitle = prefs.getString('pref_stream_title');
      var savedUserName = prefs.getString('pref_stream_user_name');
      if (savedUserName == null || savedUserName.trim().isEmpty) {
        savedUserName = prefs.getString('user_display_name');
      }
      final savedLang = prefs.getString('pref_stream_language');
      final savedMin = _getPrefDouble(prefs, 'pref_audience_min');
      final savedMax = _getPrefDouble(prefs, 'pref_audience_max');
      final savedPrivate = prefs.getBool('pref_is_private');

      if (!mounted) return;
      setState(() {
        if (savedTitle != null && savedTitle.trim().isNotEmpty) {
          _titleController.text = savedTitle.trim();
        }
        if (savedUserName != null && savedUserName.trim().isNotEmpty) {
          _userNameController.text = savedUserName.trim();
        } else {
          final user = FirebaseAuth.instance.currentUser;
          if (user?.displayName?.isNotEmpty == true) {
            _userNameController.text = user!.displayName!.trim();
          }
        }
        if (savedLang != null && languages.contains(savedLang)) {
          selectedLanguage = savedLang;
        }
        if (savedMin != null && savedMax != null) {
          final minVal = _snapAudience(savedMin);
          final maxVal = _snapAudience(savedMax);
          if (minVal <= maxVal) {
            audienceRange = RangeValues(minVal, maxVal);
          }
        }
        if (savedPrivate != null) {
          isPrivateStream = savedPrivate;
        }
      });
    } catch (e) {
      debugPrint('[GoLiveSetup] Error loading preferences: $e');
    }
  }

  Future<void> _saveStreamPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final title = _titleController.text.trim();
      final user = _userNameController.text.trim();
      if (title.isNotEmpty) {
        await prefs.setString('pref_stream_title', title);
      }
      if (user.isNotEmpty) {
        await prefs.setString('pref_stream_user_name', user);
        await prefs.setString('user_display_name', user);
      }
      await prefs.setString('pref_stream_language', selectedLanguage);
      await prefs.setDouble('pref_audience_min', audienceRange.start);
      await prefs.setDouble('pref_audience_max', audienceRange.end);
      await prefs.setBool('pref_is_private', isPrivateStream);
    } catch (e) {
      debugPrint('[GoLiveSetup] Error saving preferences: $e');
    }
  }

  Future<void> _handleExplicitSave() async {
    await _saveStreamPreferences();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2ED573), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Saved! Audience: ${audienceRange.start.round()}-${audienceRange.end.round()} • Name: "${_userNameController.text.trim()}"',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkInitialPermissions() async {
    try {
      final cameraStatus = await Permission.camera.status;
      final micStatus = await Permission.microphone.status;
      if (mounted) {
        setState(() {
          _hasCameraPermission = cameraStatus.isGranted;
          _hasMicPermission = micStatus.isGranted;
          cameraPreviewEnabled = cameraStatus.isGranted;
        });
      }
      if (cameraStatus.isGranted) {
        await _initializeCameras();
      }
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
  }

  Future<void> _initializeCameras() async {
    if (_isCameraInitializing) return;
    setState(() {
      _isCameraInitializing = true;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        final frontIndex = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIndex = frontIndex != -1 ? frontIndex : 0;
        await _setupCameraController(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('Camera discovery error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
        });
      }
    }
  }

  Future<void> _setupCameraController(CameraDescription description) async {
    await _cameraController?.dispose();
    _cameraController = null;

    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _cameraController = controller;
        });
      }
    } catch (e) {
      debugPrint('Camera setup error: $e');
      controller.dispose();
    }
  }

  Future<void> _toggleCameraLens() async {
    if (_cameras.length < 2 || _isCameraInitializing) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    _selectedCameraIndex = nextIndex;
    await _setupCameraController(_cameras[_selectedCameraIndex]);
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        setState(() {
          _hasCameraPermission = true;
          cameraPreviewEnabled = true;
        });
        _showMessage('Camera permission granted!');
        await _initializeCameras();
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog('Camera');
      } else {
        _showMessage('Camera access is required for livestream video.');
      }
    } catch (e) {
      debugPrint('Camera request error: $e');
    }
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      setState(() {
        _hasMicPermission = true;
        microphoneEnabled = true;
      });
      _showMessage('Microphone permission granted!');
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog('Microphone');
    } else {
      setState(() {
        microphoneEnabled = false;
      });
      _showMessage('Microphone access is required for audio streaming.');
    }
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  void _showSettingsDialog(String feature) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: gvSurface,
          title: Text('$feature Permission Required'),
          content: Text(
            '$feature access has been permanently denied. Please enable it in the GoViral app settings to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                openAppSettings();
              },
              style: FilledButton.styleFrom(backgroundColor: gvPink),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFieldEdited);
    _userNameController.removeListener(_onFieldEdited);
    _cameraController?.dispose();
    _titleController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  void _regenerateInviteCode() {
    final random = Random();
    final code = 1000 + random.nextInt(9000);
    setState(() {
      inviteCode = 'GV-$code';
    });
  }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: inviteCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite code $inviteCode copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  Future<void> startLiveBroadcast() async {
    // Verify Camera permission before going live
    if (!_hasCameraPermission) {
      final camStatus = await Permission.camera.request();
      if (!camStatus.isGranted) {
        if (camStatus.isPermanentlyDenied) {
          _showSettingsDialog('Camera');
        } else {
          _showMessage('Please grant Camera permission to start the livestream.');
        }
        return;
      }
      setState(() {
        _hasCameraPermission = true;
        cameraPreviewEnabled = true;
      });
    }

    // Verify Microphone permission if enabled
    if (microphoneEnabled && !_hasMicPermission) {
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        if (micStatus.isPermanentlyDenied) {
          _showSettingsDialog('Microphone');
        } else {
          _showMessage('Please grant Microphone permission to stream audio.');
        }
        return;
      }
      setState(() {
        _hasMicPermission = true;
      });
    }

    final title = _titleController.text.trim().isEmpty
        ? 'Untitled Live'
        : _titleController.text.trim();
    if (!mounted) return;

    final customHostName = _userNameController.text.trim().isEmpty
        ? 'Creator'
        : _userNameController.text.trim();

    await _saveStreamPreferences();

    InvitationAuthService.instance.registerSession(
      inviteCode: inviteCode,
      hostName: customHostName,
      streamTitle: title,
      language: selectedLanguage,
      isPrivate: isPrivateStream,
      minAudience: audienceRange.start.round(),
      maxAudience: audienceRange.end.round(),
    );

    if (!mounted) return;

    // Phase 13: Launch Full-Screen Live Room
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => LiveRoomScreen(
          streamTitle: title,
          language: selectedLanguage,
          isPrivate: isPrivateStream,
          inviteCode: inviteCode,
          audienceRange: audienceRange,
          microphoneEnabled: microphoneEnabled,
          initialCameraController: _cameraController,
          cameras: _cameras,
          initialCameraIndex: _selectedCameraIndex,
          hostName: customHostName,
        ),
      ),
    );

    // Re-verify cameras and preview state when returning from Live Room
    if (mounted) {
      _loadSavedPreferences();
      if (_hasCameraPermission) {
        _initializeCameras();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Go Live'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _handleExplicitSave,
              icon: const Icon(Icons.check, color: Colors.greenAccent, size: 18),
              label: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            (_cameraController != null &&
                    _cameraController!.value.isInitialized)
                ? Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: gvPink.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Center(
                          child: CameraPreview(_cameraController!),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.45),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              onTap: _toggleCameraLens,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.flip_camera_ios,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _cameras.isNotEmpty &&
                                              _cameras[_selectedCameraIndex]
                                                      .lensDirection ==
                                                  CameraLensDirection.front
                                          ? 'Front Camera'
                                          : 'Back Camera',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: gvPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'LIVE PREVIEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.hd_outlined, size: 14, color: Colors.greenAccent),
                                SizedBox(width: 4),
                                Text(
                                  '720p HD Ready • 30 FPS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    height: 210,
                    decoration: BoxDecoration(
                      color: const Color(0xFF242435),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.videocam_outlined,
                          size: 56,
                          color: gvPink,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Camera Preview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _hasCameraPermission
                              ? (_isCameraInitializing
                                  ? 'Initializing camera sensor...'
                                  : 'Camera ready • Tap to start preview')
                              : 'Camera permission required for video',
                          style: TextStyle(
                            color: _hasCameraPermission
                                ? Colors.greenAccent
                                : Colors.white60,
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: _hasCameraPermission
                              ? _initializeCameras
                              : _requestCameraPermission,
                          icon: Icon(
                            _hasCameraPermission
                                ? Icons.flip_camera_android
                                : Icons.videocam,
                            color: _hasCameraPermission ? Colors.greenAccent : null,
                          ),
                          label: Text(
                            _hasCameraPermission
                                ? (_isCameraInitializing
                                    ? 'Starting sensor...'
                                    : 'Start Camera Preview')
                                : 'Grant Camera Permission',
                          ),
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 20),
            const Text(
              'Your Live Name',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(
                hintText: 'e.g. Abdulla Zoahib',
                prefixIcon: const Icon(Icons.person_outline, color: gvPink),
                filled: true,
                fillColor: gvSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _saveStreamPreferences(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Stream Title',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Late night chat with friends',
                prefixIcon: const Icon(Icons.edit_note, color: gvPink),
                filled: true,
                fillColor: gvSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _saveStreamPreferences(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Stream Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedLanguage,
              decoration: InputDecoration(
                filled: true,
                fillColor: gvSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              items: languages.map((language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedLanguage = value;
                });
                _saveStreamPreferences();
              },
            ),
            const SizedBox(height: 26),
            const Text(
              'Simulated Audience Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum: ${audienceRange.start.round()}   •   Maximum: ${audienceRange.end.round()}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            RangeSlider(
              values: audienceRange,
              min: 1000,
              max: 25000,
              divisions: 48,
              activeColor: gvPink,
              inactiveColor: Colors.white24,
              labels: RangeLabels(
                audienceRange.start.round().toString(),
                audienceRange.end.round().toString(),
              ),
              onChanged: (values) {
                setState(() {
                  audienceRange = RangeValues(
                    _snapAudience(values.start),
                    _snapAudience(values.end),
                  );
                });
                _saveStreamPreferences();
              },
              onChangeEnd: (_) => _saveStreamPreferences(),
            ),
            const SizedBox(height: 4),
            Text(
              'This is a simulated audience setting, not a count of real people.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            // PRIVATE ACCESS AND INVITATION CODE (PHASE 10)
            SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPrivateStream ? Icons.lock : Icons.public,
                        color: isPrivateStream ? gvPink : Colors.greenAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Private Stream (Invite-Only)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: isPrivateStream,
                        activeTrackColor: gvPink,
                        onChanged: (value) {
                          setState(() {
                            isPrivateStream = value;
                          });
                          _saveStreamPreferences();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPrivateStream
                        ? 'Only viewers with your private invitation code can join this livestream.'
                        : 'Public mode: Any simulated or real viewer can enter directly.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  if (isPrivateStream) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242435),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: gvPink.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'INVITATION CODE',
                                style: TextStyle(
                                  color: gvPink.withValues(alpha: 0.9),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                inviteCode,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton.filledTonal(
                            onPressed: _copyInviteCode,
                            tooltip: 'Copy Code',
                            icon: const Icon(Icons.copy, size: 20),
                          ),
                          const SizedBox(width: 8),
                          IconButton.outlined(
                            onPressed: _regenerateInviteCode,
                            tooltip: 'Regenerate Code',
                            icon: const Icon(Icons.refresh, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(
                  _hasMicPermission ? Icons.mic : Icons.mic_none,
                  color: _hasMicPermission ? Colors.greenAccent : gvPurple,
                ),
                title: const Text('Microphone'),
                subtitle: Text(
                  _hasMicPermission
                      ? 'Microphone permission granted'
                      : 'Tap to grant microphone access',
                  style: TextStyle(
                    color: _hasMicPermission
                        ? Colors.greenAccent.withValues(alpha: 0.8)
                        : Colors.white60,
                  ),
                ),
                value: microphoneEnabled,
                activeThumbColor: gvPink,
                onChanged: (value) async {
                  if (value && !_hasMicPermission) {
                    await _requestMicPermission();
                  } else {
                    setState(() {
                      microphoneEnabled = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: startLiveBroadcast,
                icon: const Icon(Icons.sensors),
                label: const Text('Start Live'),
                style: FilledButton.styleFrom(
                  backgroundColor: gvPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'High-speed connection recommended for optimal 720p HD streaming.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// LIVE ROOM SCREEN (PHASE 13)
// ------------------------------------------------------------

class LiveRoomScreen extends StatefulWidget {
  final String streamTitle;
  final String language;
  final bool isPrivate;
  final String inviteCode;
  final RangeValues audienceRange;
  final bool microphoneEnabled;
  final CameraController? initialCameraController;
  final List<CameraDescription> cameras;
  final int initialCameraIndex;
  final bool isHost;
  final String? hostName;

  const LiveRoomScreen({
    super.key,
    required this.streamTitle,
    required this.language,
    required this.isPrivate,
    required this.inviteCode,
    required this.audienceRange,
    this.microphoneEnabled = true,
    this.initialCameraController,
    this.cameras = const [],
    this.initialCameraIndex = 0,
    this.isHost = true,
    this.hostName,
  });

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraSwitching = false;
  bool _isMuted = false;

  late Timer _durationTimer;
  int _elapsedSeconds = 0;


  final TextEditingController _commentInputController = TextEditingController();
  final ScrollController _commentsScrollController = ScrollController();
  final List<_FloatingHeart> _reactionHearts = [];
  final Random _random = Random();
  int _peakAudience = 0;
  int _totalReactionsCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameras = List.from(widget.cameras);
    _selectedCameraIndex = widget.initialCameraIndex;
    _cameraController = widget.initialCameraController;
    _isMuted = !widget.microphoneEnabled;
    _peakAudience = widget.audienceRange.start.round();

    AudienceSimulationService.instance.addListener(_handleAudienceSimulationUpdate);
    AudienceSimulationService.instance.startSession(
      minAudience: widget.audienceRange.start.round(),
      maxAudience: widget.audienceRange.end.round(),
    );

    StreamingService.instance.startStream(
      streamKey: widget.inviteCode,
    );

    ContextualAiEngine.instance.startSession(
      onReactionBurst: (burstEvent) {
        _handleAiReactionBurst(burstEvent);
      },
    );

    LiveChatService.instance.startSession(
      streamTitle: widget.streamTitle,
      streamLanguage: widget.language,
      audienceCount: widget.audienceRange.start.round(),
    );

    if (widget.isHost) {
      if (widget.microphoneEnabled && !_isMuted) {
        SpeechService.instance.startListening(
          streamLanguage: widget.language,
          onHostSpoke: (words) {
            LiveChatService.instance.onHostSpeechContext(words);
            AudienceSimulationService.instance.surgeHostSpeech();
          },
        );
      }

      VisionService.instance.startSession(
        onVisualEvent: (event) {
          LiveChatService.instance.onHostVisualContext(event);
          AudienceSimulationService.instance.surgeVisualCue();
        },
      );
    }

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });

    if (widget.isHost) {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        _initFallbackCamera();
      } else {
        _bindCameraImageStream();
      }
    }
  }

  void _bindCameraImageStream() {
    if (_cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      try {
        _cameraController!.startImageStream((CameraImage image) {
          VisionService.instance.processCameraImage(image);
        });
      } catch (e) {
        debugPrint('[LiveRoom] Image stream start error: $e');
      }
    }
  }

  Future<void> _initFallbackCamera() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isNotEmpty) {
        final frontIdx = _cameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIndex = frontIdx != -1 ? frontIdx : 0;
        final controller = CameraController(
          _cameras[_selectedCameraIndex],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await controller.initialize();
        if (mounted) {
          setState(() {
            _cameraController = controller;
          });
          _bindCameraImageStream();
        }
      }
    } catch (e) {
      debugPrint('LiveRoom camera init error: $e');
    }
  }

  Future<void> _toggleCameraLens() async {
    if (_cameras.length < 2 || _isCameraSwitching) return;
    setState(() {
      _isCameraSwitching = true;
    });

    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    final nextDescription = _cameras[nextIndex];

    try {
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController?.stopImageStream();
      }
      await _cameraController?.dispose();
      final newController = CameraController(
        nextDescription,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await newController.initialize();
      if (mounted) {
        setState(() {
          _selectedCameraIndex = nextIndex;
          _cameraController = newController;
        });
        _bindCameraImageStream();
      }
    } catch (e) {
      debugPrint('Camera switch error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCameraSwitching = false;
        });
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    SpeechService.instance.setMuted(_isMuted);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isMuted ? 'Microphone muted (Speech paused)' : 'Microphone unmuted (AI listening)'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _submitComment(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _commentInputController.clear();
    String userName = widget.isHost ? (widget.hostName ?? 'You') : 'Invited Guest';
    if (widget.isHost && (widget.hostName != null && widget.hostName!.trim().isNotEmpty)) {
      userName = widget.hostName!.trim();
    } else {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.displayName?.isNotEmpty == true) {
          userName = currentUser!.displayName!.trim();
        }
      } catch (_) {
        // Safe fallback when Firebase is not initialized
      }
    }

    if (widget.isHost) {
      LiveChatService.instance.sendHostMessage(clean, hostName: userName);
      AudienceSimulationService.instance.surgeHostMessage();
    } else {
      LiveChatService.instance.sendViewerMessage(clean, viewerName: userName);
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_commentsScrollController.hasClients) {
        _commentsScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _spawnHeart({Color? color}) {
    final palette = [
      gvPink,
      gvPurple,
      const Color(0xFFFF4757),
      const Color(0xFFFFA502),
      const Color(0xFF2ED573),
      const Color(0xFF00CEC9),
    ];
    final chosenColor = color ?? palette[_random.nextInt(palette.length)];
    final heart = _FloatingHeart(
      key: UniqueKey(),
      startX: (_random.nextDouble() * 20) - 10,
      scale: 0.85 + (_random.nextDouble() * 0.45),
      color: chosenColor,
    );

    _totalReactionsCount++;
    setState(() {
      _reactionHearts.add(heart);
      if (_reactionHearts.length > 25) {
        _reactionHearts.removeAt(0);
      }
    });

    if (_random.nextInt(3) == 0) {
      AudienceSimulationService.instance.surgeReactionBurst();
    }
  }

  void _handleAiReactionBurst(ReactionBurstEvent event) {
    if (!mounted) return;
    _totalReactionsCount += event.count;
    AudienceSimulationService.instance.surgeReactionBurst();
    for (int i = 0; i < event.count; i++) {
      Future.delayed(Duration(milliseconds: i * 130), () {
        if (mounted) {
          _spawnHeart(color: event.primaryColor);
        }
      });
    }
  }

  Future<void> _confirmEndStream() async {
    if (!widget.isHost) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: gvSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.exit_to_app_rounded, color: gvPink, size: 26),
                SizedBox(width: 10),
                Text(
                  'Leave Live Stream?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to leave "${widget.streamTitle}"?',
              style: const TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: gvPink,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Leave'),
              ),
            ],
          );
        },
      );

      if (shouldLeave == true && mounted) {
        _durationTimer.cancel();
        Navigator.pop(context);
      }
      return;
    }

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: gvSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: gvPink, size: 26),
              SizedBox(width: 10),
              Text(
                'End Live Stream?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to end "${widget.streamTitle}"? All live viewers will be disconnected.',
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: gvPink,
                foregroundColor: Colors.white,
              ),
              child: const Text('End Live'),
            ),
          ],
        );
      },
    );

    if (shouldEnd == true && mounted) {
      String hostName = widget.hostName ?? 'Creator';
      if (widget.hostName == null || widget.hostName!.trim().isEmpty) {
        try {
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser?.displayName?.isNotEmpty == true) {
            hostName = currentUser!.displayName!.trim();
          }
        } catch (_) {}
      }

      final summaryData = LiveStreamSummaryData(
        streamTitle: widget.streamTitle,
        hostName: hostName,
        durationSeconds: _elapsedSeconds,
        peakAudience: max(_peakAudience, AudienceSimulationService.instance.currentCount),
        totalComments: LiveChatService.instance.messages.length,
        totalReactions: _totalReactionsCount,
        endedAt: DateTime.now(),
        language: widget.language,
        isPrivate: widget.isPrivate,
      );

      await _teardownHardwareAndServices();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LiveSummaryScreen(summary: summaryData),
          ),
        );
      }
    }
  }

  void _handleAudienceSimulationUpdate() {
    if (AudienceSimulationService.instance.currentCount > _peakAudience) {
      _peakAudience = AudienceSimulationService.instance.currentCount;
    }
  }

  Future<void> _teardownHardwareAndServices() async {
    try {
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController?.stopImageStream();
      }
    } catch (e) {
      debugPrint('[LiveRoom] stopImageStream error: $e');
    }

    try {
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      debugPrint('[LiveRoom] camera dispose error: $e');
    }

    AudienceSimulationService.instance.removeListener(_handleAudienceSimulationUpdate);
    _durationTimer.cancel();
    InvitationAuthService.instance.endSession(widget.inviteCode);
    await ZeroPersistenceService.instance.enforceTeardownZeroWipe();
  }

  void _showTelemetrySheet() {
    final streamService = StreamingService.instance;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: gvSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: streamService,
          builder: (context, _) {
            final currentTelemetry = streamService.telemetry;
            final config = streamService.config;
            final isRtmp = config.protocol == StreamProtocol.rtmp;

            return Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stream, color: gvPink, size: 24),
                      const SizedBox(width: 10),
                      const Text(
                        '720p HD Stream Infrastructure',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Close Telemetry',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242435),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        _telemetryRow('Protocol', isRtmp ? 'Custom RTMP Server' : 'WebRTC Server'),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Resolution', currentTelemetry.isDegraded ? '480p SD (Adaptive)' : '720p HD (1280x720)'),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Frame Rate', '${currentTelemetry.currentFps} FPS'),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Live Bitrate', '${currentTelemetry.currentBitrateKbps} kbps'),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Adaptive Target', '${currentTelemetry.adaptiveTargetBitrateKbps} kbps'),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Packet Loss', '${currentTelemetry.packetLossPercent}%'),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Connection Health', currentTelemetry.networkQuality.name.toUpperCase()),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Server Endpoint', config.serverUrl),
                        const Divider(color: Colors.white12, height: 14),
                        _telemetryRow('Stream Key', widget.inviteCode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ZeroPersistenceService.showZeroPersistenceDetails(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ED573).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2ED573).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: Color(0xFF2ED573), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zero Persistence Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'No video/audio saved. Tap to view privacy audit.',
                                  style: TextStyle(
                                    color: Color(0xFF2ED573),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Color(0xFF2ED573), size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            streamService.reconnect();
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Testing auto-reconnect recovery...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.sync, size: 18),
                          label: const Text('Test Reconnection Recovery'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _telemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineCameraView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF26123D),
            Color(0xFF101018),
            Color(0xFF1E102E),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: gvPink.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
              child: const CreatorAvatar(size: 90),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isHost ? 'Live Video Feed Ready' : widget.streamTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isHost
                  ? 'Connecting broadcast camera...'
                  : 'Connected to private live broadcast',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            if (!widget.isHost) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2ED573),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Live Private Stream • Audio & Video Active',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildCommentBubble(LiveChatMessage comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: comment.isHost
                    ? const Color(0xFFFF3D8D)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: ClipOval(
              child: comment.isHost
                  ? CircleAvatar(
                      backgroundColor: const Color(0xFFFF3D8D),
                      child: Text(
                        comment.senderName.isNotEmpty
                            ? comment.senderName[0].toUpperCase()
                            : 'Y',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : ((comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty)
                      ? Image.network(
                          comment.avatarUrl!,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFF262626),
                              child: const Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFF8E8E8E),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: const Color(0xFF262626),
                          child: const Icon(
                            Icons.person,
                            size: 18,
                            color: Color(0xFF8E8E8E),
                          ),
                        )),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: comment.senderName,
                      style: TextStyle(
                        color: comment.isHost
                            ? const Color(0xFFFF3D8D)
                            : Colors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    if (comment.isHost)
                      const TextSpan(
                        text: '  Host',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                      ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: comment.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.25,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
    Color backgroundColor = const Color(0x88000000),
    String? tooltip,
  }) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip ?? '',
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(icon, color: color, size: 21),
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isHost) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_cameraController?.value.isStreamingImages == true) {
        _cameraController?.stopImageStream();
      }
      SpeechService.instance.stopListening();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _bindCameraImageStream();
      }
      if (widget.microphoneEnabled && !_isMuted) {
        SpeechService.instance.startListening(
          streamLanguage: widget.language,
          onHostSpoke: (words) {
            LiveChatService.instance.onHostSpeechContext(words);
            AudienceSimulationService.instance.surgeHostSpeech();
          },
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ZeroPersistenceService.instance.enforceTeardownZeroWipe();
    if (_cameraController?.value.isStreamingImages == true) {
      _cameraController?.stopImageStream();
    }
    AudienceSimulationService.instance.removeListener(_handleAudienceSimulationUpdate);
    AudienceSimulationService.instance.stopSession();
    LiveChatService.instance.stopSession();
    ContextualAiEngine.instance.stopSession();
    StreamingService.instance.stopStream();
    _durationTimer.cancel();
    _cameraController?.dispose();
    _commentInputController.dispose();
    _commentsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasCamera = _cameraController != null &&
        _cameraController!.value.isInitialized;
    String hostName = widget.hostName ?? 'Creator';
    if (widget.hostName == null || widget.hostName!.trim().isEmpty) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser?.displayName?.isNotEmpty == true) {
          hostName = currentUser!.displayName!.trim();
        }
      } catch (_) {
        // Safe fallback when Firebase is uninitialized
      }
    }
    final hostInitial = hostName.isNotEmpty ? hostName[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. FULL-SCREEN CAMERA BROADCAST BACKGROUND (BoxFit.cover, Edge-to-Edge)
          if (hasCamera)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var cameraAspectRatio = _cameraController!.value.aspectRatio;
                  // Handle portrait sensor orientation
                  if (constraints.maxHeight > constraints.maxWidth &&
                      cameraAspectRatio > 1.0) {
                    cameraAspectRatio = 1.0 / cameraAspectRatio;
                  }
                  return ClipRect(
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: 1000,
                          height: 1000 / cameraAspectRatio,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Positioned.fill(
              child: _buildOfflineCameraView(),
            ),

          // 2. VIGNETTE GRADIENTS (Top and Bottom Scrims for Readability)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 320,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.black.withValues(alpha: 0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. TOP OVERLAY (EXACT INSTAGRAM LIVE STYLE)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Row(
                  children: [
                    // Creator Avatar
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: const Color(0xFFE1306C),
                      child: Text(
                        hostInitial,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Username
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Text(
                        hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // LIVE badge (Vibrant Instagram magenta pill)
                    GestureDetector(
                      onTap: _showTelemetrySheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE1306C), Color(0xFFC13584)],
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Viewer Count Pill (Direction-aware live animated pill)
                    ListenableBuilder(
                      listenable: AudienceSimulationService.instance,
                      builder: (context, _) {
                        final sim = AudienceSimulationService.instance;
                        final displayCount = sim.isActive
                            ? sim.currentCount
                            : widget.audienceRange.start.round();
                        final isIncreasing = sim.direction == FluctuationDirection.increasing;
                        final formattedText = AudienceSimulationService.formatAudienceCount(displayCount);

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.remove_red_eye,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                transitionBuilder: (child, animation) {
                                  final inOffset = isIncreasing
                                      ? const Offset(0, 0.30)
                                      : const Offset(0, -0.30);
                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: inOffset,
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  formattedText,
                                  key: ValueKey<String>(formattedText),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    // Close (✕) - End or Leave Stream
                    Tooltip(
                      message: widget.isHost ? 'End Live' : 'Leave Live',
                      child: GestureDetector(
                        key: const Key('end_live_button'),
                        onTap: _confirmEndStream,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3B. NETWORK QUALITY & RECONNECTING BANNER (Phase 26)
          Positioned(
            top: 56,
            left: 14,
            right: 14,
            child: SafeArea(
              bottom: false,
              child: ListenableBuilder(
                listenable: StreamingService.instance,
                builder: (context, _) {
                  final service = StreamingService.instance;
                  if (service.isReconnecting) {
                    return Container(
                      key: const Key('reconnecting_banner'),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE67E22).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 13,
                            height: 13,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reconnecting to broadcast... (Attempt ${service.reconnectAttempts}/${StreamingService.maxReconnectAttempts})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (service.isConnectionFailed) {
                    return Container(
                      key: const Key('connection_failed_banner'),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.signal_wifi_connected_no_internet_4_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Connection lost. Check network.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            key: const Key('retry_reconnect_button'),
                            onTap: () => service.retryConnection(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: Color(0xFFC0392B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (service.isDegraded) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        key: const Key('network_degraded_pill'),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.70),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFF39C12).withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.network_check_rounded,
                              color: Color(0xFFF39C12),
                              size: 13,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              service.networkQuality == NetworkQuality.critical
                                  ? 'Poor Signal • 360p Audio Priority'
                                  : 'Slow Signal • 480p Adaptive',
                              style: const TextStyle(
                                color: Color(0xFFF39C12),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // 4. FLOATING AUDIENCE COMMENTS STREAM (Lower-Left Overlay)
          Positioned(
            left: 14,
            right: 74,
            bottom: 68,
            height: 250,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white, Colors.white],
                  stops: [0.0, 0.15, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.dstIn,
              child: ListenableBuilder(
                      listenable: LiveChatService.instance,
                      builder: (context, _) {
                        final messages = LiveChatService.instance.messages;
                        return ListView.builder(
                          controller: _commentsScrollController,
                          reverse: true,
                          itemCount: messages.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final comment = messages[messages.length - 1 - index];
                            return _buildCommentBubble(comment);
                          },
                        );
                      },
                    ),
                  ),
                ),

          // 5. FLOATING HEART REACTIONS ANIMATION LAYER (Lower-Right Overlay)
          Positioned(
            right: 14,
            bottom: 68,
            width: 60,
            height: 250,
            child: IgnorePointer(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: _reactionHearts.map((heart) {
                  return _FloatingHeartWidget(
                    key: heart.key,
                    startX: heart.startX,
                    scale: heart.scale,
                    color: heart.color,
                    onComplete: () {
                      if (mounted) {
                        setState(() {
                          _reactionHearts.remove(heart);
                        });
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),

          // 6. BOTTOM HOST CONTROLS TOOLBAR (INSTAGRAM LIVE STYLE)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                  children: [
                    // Comment Input Bar
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: _commentInputController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  hintStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onSubmitted: _submitComment,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.send_rounded,
                                color: gvPink,
                                size: 19,
                              ),
                              tooltip: 'Send Comment',
                              onPressed: () =>
                                  _submitComment(_commentInputController.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (widget.isHost) ...[
                      // Camera Flip Button
                      _circleActionButton(
                        icon: Icons.flip_camera_ios,
                        color: _isCameraSwitching ? Colors.white38 : Colors.white,
                        backgroundColor: Colors.black.withValues(alpha: 0.55),
                        onTap: _toggleCameraLens,
                        tooltip: 'Flip Camera',
                      ),
                      const SizedBox(width: 8),

                      // Microphone Mute/Unmute Button
                      _circleActionButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        color: _isMuted ? Colors.redAccent : Colors.white,
                        backgroundColor: _isMuted
                            ? Colors.redAccent.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.55),
                        onTap: _toggleMute,
                        tooltip: _isMuted ? 'Unmute' : 'Mute',
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Heart Reaction Button
                    _circleActionButton(
                      icon: Icons.favorite,
                      color: gvPink,
                      backgroundColor: gvPink.withValues(alpha: 0.25),
                      onTap: () => _spawnHeart(),
                      tooltip: 'React',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// FLOATING REACTION MODELS
// ------------------------------------------------------------

class _FloatingHeart {
  final Key key;
  final double startX;
  final double scale;
  final Color color;

  _FloatingHeart({
    required this.key,
    required this.startX,
    required this.scale,
    required this.color,
  });
}

class _FloatingHeartWidget extends StatefulWidget {
  final double startX;
  final double scale;
  final Color color;
  final VoidCallback onComplete;

  const _FloatingHeartWidget({
    super.key,
    required this.startX,
    required this.scale,
    required this.color,
    required this.onComplete,
  });

  @override
  State<_FloatingHeartWidget> createState() => _FloatingHeartWidgetState();
}

class _FloatingHeartWidgetState extends State<_FloatingHeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateY;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _translateY = Tween<double>(begin: 0.0, end: -230.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.5 * widget.scale, end: 1.1 * widget.scale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final horizontalWobble = sin(_controller.value * pi * 3) * 14;
        return Transform.translate(
          offset: Offset(widget.startX + horizontalWobble, _translateY.value),
          child: Transform.scale(
            scale: _scale.value,
            child: Opacity(
              opacity: _fade.value.clamp(0.0, 1.0),
              child: Icon(
                Icons.favorite,
                color: widget.color,
                size: 26,
                shadows: [
                  Shadow(
                    color: widget.color.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------
// FIREBASE AUTHENTICATION SCREEN
// ------------------------------------------------------------

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Choose a stronger password with at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase.';
      case 'user-disabled':
        return 'This account is disabled.';
      default:
        return error.message ??
            'Authentication failed. Please try again.';
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final auth = FirebaseAuth.instance;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegistering) {
        await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      _showMessage(_friendlyError(error));
    } catch (_) {
      _showMessage(
        'Something went wrong. Check your connection and try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;

    setState(() {
      _isLoading = true;
      _isGoogleLoading = true;
    });

    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      _showMessage(_friendlyError(error));
    } catch (error) {
      final errorMsg = error.toString().toLowerCase();
      if (!errorMsg.contains('cancel') && !errorMsg.contains('aborted')) {
        _showMessage(
          'Google Sign-In was unable to complete. Please try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Enter your email address first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

      // Use a neutral message instead of revealing whether an account
      // exists for the submitted email address.
      _showMessage(
        'If an account exists for this email, a password reset email will be sent.',
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(_friendlyError(error));
    } catch (_) {
      _showMessage(
        'Unable to send the reset email. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoViral Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.bolt,
                      size: 70,
                      color: gvPink,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRegistering
                          ? 'Create your account'
                          : 'Welcome to GoViral',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegistering
                          ? 'Join GoViral and prepare to go live.'
                          : 'Sign in to continue to Go Live.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty || !email.contains('@')) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      autofillHints: [
                        _isRegistering
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final password = value ?? '';

                        if (password.isEmpty) {
                          return 'Enter your password.';
                        }

                        if (_isRegistering && password.length < 6) {
                          return 'Use at least 6 characters.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: gvPink,
                          foregroundColor: Colors.white,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRegistering
                                    ? 'Create Account'
                                    : 'Sign In',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (!_isRegistering) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed:
                            _isLoading ? null : _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Colors.white24),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Colors.white24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed:
                            (_isLoading || _isGoogleLoading) ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GoogleLogo(size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isRegistering = !_isRegistering;
                              });
                            },
                      child: Text(
                        _isRegistering
                            ? 'Already have an account? Sign in'
                            : 'New to GoViral? Create an account',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Authentication unlocks host broadcasting privileges, custom private invite codes, and cloud AI synthesis.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// GOOGLE LOGO VECTOR WIDGET
// ------------------------------------------------------------

class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double stroke = w * 0.22;
    final center = Offset(w / 2, h / 2);
    final radius = (w - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Google brand colors
    const red = Color(0xFFEA4335);
    const yellow = Color(0xFFFBBC05);
    const green = Color(0xFF34A853);
    const blue = Color(0xFF4285F4);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Blue arc (right: -45 deg to +45 deg)
    paint.color = blue;
    canvas.drawArc(rect, -0.785, 1.57, false, paint);

    // Green arc (bottom: 45 deg to 135 deg)
    paint.color = green;
    canvas.drawArc(rect, 0.785, 1.57, false, paint);

    // Yellow arc (left: 135 deg to 225 deg)
    paint.color = yellow;
    canvas.drawArc(rect, 2.356, 1.57, false, paint);

    // Red arc (top: 225 deg to 315 deg)
    paint.color = red;
    canvas.drawArc(rect, 3.927, 1.57, false, paint);

    // Horizontal blue bar in center
    final barPaint = Paint()
      ..color = blue
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTWH(
      w * 0.45,
      h / 2 - stroke / 2,
      w * 0.55,
      stroke,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}