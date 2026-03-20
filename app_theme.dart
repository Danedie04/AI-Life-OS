import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_widgets.dart';

class InsightCard extends StatelessWidget {
  final String insight;
  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.14),
              border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: const Center(child: Text('🧠', style: TextStyle(fontSize: 17))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: const [
                    AiTag('+2.4× output', color: AppTheme.accent),
                    AiTag('Recommended', color: AppTheme.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
