import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AiTickerWidget extends StatefulWidget {
  const AiTickerWidget({super.key});

  @override
  State<AiTickerWidget> createState() => _AiTickerWidgetState();
}

class _AiTickerWidgetState extends State<AiTickerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _messages = [
    'Sleeping pattern: improving',
    'Productivity score: 87/100',
    'Next optimal focus: 9–11 AM',
    'Weekly goal: 68% complete',
    'Energy level: High',
    '12-day streak maintained',
    'Deep work block: Protected',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(left: 20),
            controller: ScrollController(
              initialScrollOffset: _ctrl.value * 1400,
            ),
            itemBuilder: (_, i) {
              final msg = _messages[i % _messages.length];
              return Row(
                children: [
                  Container(
                    width: 3, height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent,
                    ),
                  ),
                  Text(msg, style: AppTheme.caption.copyWith(
                    color: AppTheme.textMuted, letterSpacing: 0.02)),
                ],
              );
            },
            itemCount: _messages.length * 4,
          );
        },
      ),
    );
  }
}
