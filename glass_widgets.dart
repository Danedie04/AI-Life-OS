import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../widgets/common/glass_widgets.dart';

class StatsRow extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int focusScore;
  final int streak;

  const StatsRow({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.focusScore,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Expanded(child: _StatCard(
            value: '$focusScore',
            label: 'Focus',
            color: AppTheme.green,
          )),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(
            value: '$streak🔥',
            label: 'Streak',
            color: AppTheme.amber,
          )),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(
            value: '$completedTasks/$totalTasks',
            label: 'Tasks',
            color: AppTheme.accentSoft,
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: color.withOpacity(0.06),
      borderColor: color.withOpacity(0.15),
      borderRadius: AppTheme.radiusLG,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        children: [
          Text(value, style: AppTheme.headlineLarge.copyWith(
            fontFamily: 'Syne', fontSize: 22, color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.caption),
        ],
      ),
    );
  }
}
