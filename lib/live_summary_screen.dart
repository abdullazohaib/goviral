import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main.dart';
import 'audience_simulation_service.dart';
import 'zero_persistence_service.dart';

/// Phase 23: Live Video Post-Broadcast Analytics Summary Data Model
class LiveStreamSummaryData {
  final String streamTitle;
  final String hostName;
  final int durationSeconds;
  final int peakAudience;
  final int totalComments;
  final int totalReactions;
  final DateTime endedAt;
  final String language;
  final bool isPrivate;

  const LiveStreamSummaryData({
    required this.streamTitle,
    required this.hostName,
    required this.durationSeconds,
    required this.peakAudience,
    required this.totalComments,
    required this.totalReactions,
    required this.endedAt,
    required this.language,
    required this.isPrivate,
  });

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String get formattedPeakAudience =>
      AudienceSimulationService.formatAudienceCount(peakAudience);
}

/// Phase 23: Instagram Live-Style Post-Broadcast Summary Screen
/// Displays session metrics (duration, peak viewers, comments, reactions),
/// confirms zero-persistence hardware disposal, and provides clean return navigation.
class LiveSummaryScreen extends StatelessWidget {
  final LiveStreamSummaryData summary;

  const LiveSummaryScreen({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final hostInitial = summary.hostName.isNotEmpty
        ? summary.hostName[0].toUpperCase()
        : 'C';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: gvBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 1),

                // 1. Host Avatar with Instagram gradient ring
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFE1306C), Color(0xFF833AB4), Color(0xFFF77737)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: gvSurface,
                    child: Text(
                      hostInitial,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 2. Title & Stream Name
                const Text(
                  'Live Video Ended',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.streamTitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Analytics Grid (2x2)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.timer_outlined,
                        iconColor: const Color(0xFFFFA502),
                        label: 'Duration',
                        value: summary.formattedDuration,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.remove_red_eye_outlined,
                        iconColor: const Color(0xFF00CEC9),
                        label: 'Peak Viewers',
                        value: summary.formattedPeakAudience,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.chat_bubble_outline,
                        iconColor: gvPurple,
                        label: 'Comments',
                        value: summary.totalComments.toString(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildMetricCard(
                        icon: Icons.favorite_border,
                        iconColor: gvPink,
                        label: 'Reactions',
                        value: summary.totalReactions.toString(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 4. Zero Persistence / Privacy Disclosure Banner
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => ZeroPersistenceService.showZeroPersistenceDetails(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181824),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2ED573).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: Color(0xFF2ED573), size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Zero Persistence Verified: Stream audio, video, and frames were processed ephemerally and never stored.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.chevron_right, color: Color(0xFF2ED573), size: 18),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // 5. Actions: Share Stats & Return Home
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final statsText = '''GoViral Live Summary: "${summary.streamTitle}"
Duration: ${summary.formattedDuration}
Peak Viewers: ${summary.formattedPeakAudience}
Comments: ${summary.totalComments}
Reactions: ${summary.totalReactions}''';
                          Clipboard.setData(ClipboardData(text: statsText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Live stream summary copied to clipboard!'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share Stats'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: gvPink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: gvSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
