import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../data/models/memory_model.dart';
import '../../../widgets/common/glass_widgets.dart';

class TimelineSection extends StatelessWidget {
  final List<TimelineEvent> events;
  const TimelineSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Today's Flow", style: AppTheme.headlineMedium),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go(AppRouter.tasks),
              child: AiTag('View All →', color: AppTheme.accent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...events.map((e) => _TimelineItem(event: e)).toList(),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  const _TimelineItem({required this.event});

  Color get _dotColor {
    switch (event.category) {
      case 'work':     return AppTheme.accent;
      case 'health':   return AppTheme.green;
      case 'learning': return AppTheme.accentCyan;
      default:         return AppTheme.accentSoft;
    }
  }

  Color get _statusColor {
    switch (event.status) {
      case EventStatus.done:     return AppTheme.green;
      case EventStatus.current:  return AppTheme.accent;
      case EventStatus.upcoming: return AppTheme.amber;
      default:                   return AppTheme.textMuted;
    }
  }

  String get _statusLabel {
    switch (event.status) {
      case EventStatus.done:     return 'Done';
      case EventStatus.current:  return 'Now';
      case EventStatus.upcoming: return 'Soon';
      default:                   return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = event.status == EventStatus.current;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accent.withOpacity(0.09) : Colors.transparent,
        border: isActive
            ? Border.all(color: AppTheme.accent.withOpacity(0.2), width: 1)
            : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(event.timeString,
              style: AppTheme.caption.copyWith(
                fontFamily: 'Syne', fontWeight: FontWeight.w700,
                color: isActive ? AppTheme.textSecondary : AppTheme.textMuted)),
          ),
          const SizedBox(width: 10),
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: _dotColor,
              boxShadow: isActive
                  ? [BoxShadow(color: _dotColor.withOpacity(0.5), blurRadius: 8)]
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: AppTheme.bodyMedium.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                if (event.subtitle != null)
                  Text(event.subtitle!, style: AppTheme.caption),
              ],
            ),
          ),
          if (_statusLabel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                border: Border.all(color: _statusColor.withOpacity(0.25)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_statusLabel, style: AppTheme.caption.copyWith(
                color: _statusColor, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}
