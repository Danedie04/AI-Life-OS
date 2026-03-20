import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_widgets.dart';

class MorningBriefingCard extends StatefulWidget {
  const MorningBriefingCard({super.key});

  @override
  State<MorningBriefingCard> createState() => _MorningBriefingCardState();
}

class _MorningBriefingCardState extends State<MorningBriefingCard> {
  bool _playing = false;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌅  ', style: TextStyle(fontSize: 14)),
              Text('Morning Briefing',
                style: AppTheme.headlineMedium.copyWith(fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _playing = !_playing),
                child: _playing
                    ? const WaveformWidget(
                        color: AppTheme.accentSoft, bars: 7, height: 22)
                    : const Icon(Icons.play_circle_outline,
                        color: AppTheme.textSecondary, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 13, color: AppTheme.textSecondary, height: 1.7),
              children: const [
                TextSpan(text: 'Today looks like a '),
                TextSpan(
                  text: 'high-performance day',
                  style: TextStyle(
                    color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                TextSpan(
                  text: '. You have 2 deep work blocks, a team meeting, '
                      'and gym. Sleep quality was '),
                TextSpan(
                  text: 'above average',
                  style: TextStyle(color: AppTheme.green)),
                TextSpan(
                  text: ' last night. AI suggests front-loading the '
                      'roadmap work before 11 AM.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              AiTag('3 priorities', color: AppTheme.accentCyan),
              AiTag('1 deadline',   color: AppTheme.amber),
              AiTag('High energy'),
            ],
          ),
        ],
      ),
    );
  }
}
