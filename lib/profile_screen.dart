
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

const Color profilePink = Color(0xFFFF3D71);
const Color profileBackground = Color(0xFF101014);
const Color profileSurface = Color(0xFF202027);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String displayName = 'GoViral Creator';
  String username = 'your_username';
  String bio = 'Sharing moments and connecting with people.';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('user_display_name') ?? prefs.getString('pref_stream_user_name');
      final savedUser = prefs.getString('user_handle');
      final savedBio = prefs.getString('user_bio');

      if (!mounted) return;
      setState(() {
        if (savedName != null && savedName.trim().isNotEmpty) {
          displayName = savedName.trim();
        } else {
          final user = FirebaseAuth.instance.currentUser;
          if (user?.displayName?.isNotEmpty == true) {
            displayName = user!.displayName!.trim();
          }
        }
        if (savedUser != null && savedUser.trim().isNotEmpty) {
          username = savedUser.trim();
        } else {
          final user = FirebaseAuth.instance.currentUser;
          if (user?.email != null && user!.email!.contains('@')) {
            username = user.email!.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
          }
        }
        if (savedBio != null && savedBio.trim().isNotEmpty) {
          bio = savedBio.trim();
        }
      });
    } catch (_) {}
  }

  Future<void> _saveProfileData(String name, String handle, String newBio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', name);
      await prefs.setString('pref_stream_user_name', name);
      await prefs.setString('user_handle', handle);
      await prefs.setString('user_bio', newBio);
    } catch (_) {}
  }

  void editProfile() {
    final nameController =
        TextEditingController(text: displayName);
    final usernameController =
        TextEditingController(text: username);
    final bioController = TextEditingController(text: bio);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                  ),
                ),
                TextField(
                  controller: usernameController,
                  maxLength: 24,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixText: '@',
                  ),
                ),
                TextField(
                  controller: bioController,
                  maxLength: 150,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
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
                final newName = nameController.text.trim();
                final newUsername = usernameController.text
                    .trim()
                    .replaceAll('@', '');
                final newBio = bioController.text.trim();

                if (newName.isEmpty || newUsername.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Name and username are required.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  displayName = newName;
                  username = newUsername;
                  bio = newBio;
                });

                _saveProfileData(newName, newUsername, newBio);

                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) {
      nameController.dispose();
      usernameController.dispose();
      bioController.dispose();
    });
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
      backgroundColor: profileBackground,
      appBar: AppBar(
        backgroundColor: profileBackground,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: openSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // PROFILE AVATAR

          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF7928CA),
                    profilePink,
                    Color(0xFFFF914D),
                  ],
                ),
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: profileSurface,
                backgroundImage: (FirebaseAuth.instance.currentUser?.photoURL != null &&
                        FirebaseAuth.instance.currentUser!.photoURL!.isNotEmpty)
                    ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                    : null,
                child: (FirebaseAuth.instance.currentUser?.photoURL == null ||
                        FirebaseAuth.instance.currentUser!.photoURL!.isEmpty)
                    ? const Icon(
                        Icons.person_rounded,
                        size: 58,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // DISPLAY NAME

          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '@$username',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60),
          ),

          const SizedBox(height: 14),

          // BIO

          Text(
            bio,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 24),

          // LIVE STREAMS ONLY — NO FOLLOWERS OR FOLLOWING

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: profileSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.videocam_rounded,
                  color: profilePink,
                  size: 28,
                ),
                SizedBox(height: 8),
                Text(
                  '0',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Live streams',
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // EDIT PROFILE

          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: editProfile,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit profile'),
              style: FilledButton.styleFrom(
                backgroundColor: profilePink,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ACTIVITY SECTION

          const Text(
            'Your activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: profileSurface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.video_camera_front_outlined,
                  size: 42,
                  color: profilePink,
                ),
                SizedBox(height: 12),
                Text(
                  'Your live journey starts here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  'Zero-Persistence Architecture: Livestreams are broadcast '
                  'live with zero server recordings or disk storage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}