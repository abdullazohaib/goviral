import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';
import 'invitation_auth_service.dart';

/// Phase 25: Interactive Viewer Entry Modal for Private Live Streams
/// Enables authorized invitees to enter a host's GV-XXXX code, validates authorization,
/// and routes directly into the private broadcast room.
class JoinPrivateStreamSheet extends StatefulWidget {
  const JoinPrivateStreamSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: gvSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => const JoinPrivateStreamSheet(),
    );
  }

  @override
  State<JoinPrivateStreamSheet> createState() => _JoinPrivateStreamSheetState();
}

class _JoinPrivateStreamSheetState extends State<JoinPrivateStreamSheet> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      final normalized = InvitationAuthService.normalizeCode(text);
      setState(() {
        _codeController.text = normalized;
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleJoin() async {
    final rawInput = _codeController.text.trim();
    if (rawInput.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an invitation code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String viewerId = 'anon_guest';
    String viewerName = 'Invited Guest';
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        viewerId = user.uid;
        viewerName = user.displayName ?? 'Invited Guest';
      }
    } catch (_) {}

    final result = await InvitationAuthService.instance.verifyAndAuthorize(
      rawCode: rawInput,
      viewerId: viewerId,
      viewerName: viewerName,
    );

    if (!mounted) return;

    if (result.isSuccess && result.session != null) {
      final session = result.session!;
      Navigator.pop(context); // Close sheet

      // Navigate to live room as authorized invitee
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LiveRoomScreen(
            streamTitle: session.streamTitle,
            language: session.language,
            isPrivate: true,
            inviteCode: session.inviteCode,
            audienceRange: RangeValues(
              session.minAudience.toDouble(),
              session.maxAudience.toDouble(),
            ),
            microphoneEnabled: false, // Viewer mode
            isHost: false, // Viewer mode
            hostName: session.hostName,
          ),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(22, 20, 22, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [gvPink, gvPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.vpn_key_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join Private Stream',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Enter host invitation code (GV-XXXX)',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Code Input Field
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
            decoration: InputDecoration(
              hintText: 'GV-XXXX',
              hintStyle: const TextStyle(
                color: Colors.white24,
                letterSpacing: 3,
              ),
              filled: true,
              fillColor: const Color(0xFF242435),
              prefixIcon: const Icon(Icons.lock_outline, color: gvPink),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_codeController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white60),
                      onPressed: () {
                        setState(() {
                          _codeController.clear();
                          _errorMessage = null;
                        });
                      },
                    ),
                  TextButton.icon(
                    onPressed: _handlePaste,
                    icon: const Icon(Icons.content_paste, size: 16, color: gvPurple),
                    label: const Text('Paste', style: TextStyle(color: gvPurple, fontSize: 12)),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: gvPink, width: 2),
              ),
            ),
            onChanged: (val) {
              if (_errorMessage != null) {
                setState(() {
                  _errorMessage = null;
                });
              }
            },
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFFF4757), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFFF4757), fontSize: 12),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFF2ED573), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Invite-only access with Zero Persistence real-time streaming.',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _handleJoin,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.login),
              label: Text(
                _isLoading ? 'Verifying Code...' : 'Join Broadcast',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: gvPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
