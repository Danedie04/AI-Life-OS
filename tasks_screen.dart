// lib/presentation/screens/home/widgets/nba_card.dart

import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/memory_model.dart';
import '../../../widgets/common/glass_widgets.dart';

class NbaCard extends StatefulWidget {
  final NextBestAction action;
  final VoidCallback? onStart;

  const NbaCard({super.key, required this.action, this.onStart});

  @override
  State<NbaCard> createState() => _NbaCardState();
}

class _NbaCardState extends State<NbaCard> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.action.countdown ?? Duration.zero;
    if (_remaining.inSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted && _remaining.inSeconds > 0) {
          setState(() => _remaining -= const Duration(seconds: 1));
        }
      });
    }
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  double get _progress {
    final total = widget.action.countdown?.inSeconds ?? 1;
    return 1.0 - (_remaining.inSeconds / total).clamp(0.0, 1.0);
  }

  String get _timeString {
    final mins = _remaining.inMinutes;
    final secs = _remaining.inSeconds % 60;
    if (mins > 0) return '${mins}m ${secs.toString().padLeft(2,'0')}s left';
    return '${secs}s left';
  }

  @override
  Widget build(BuildContext context) {
    return HeroGlassCard(
      onTap: widget.onStart,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              const Text('✦ ', style: TextStyle(color: AppTheme.accentSoft)),
              Text('Next Best Action',
                style: AppTheme.labelCaps.copyWith(
                  color: AppTheme.accentSoft, fontSize: 11)),
              const Spacer(),
              AiTag(widget.action.urgency.toUpperCase(),
                color: widget.action.isHighUrgency ? AppTheme.red : AppTheme.amber),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar + countdown
          if (_remaining.inSeconds > 0) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: 1.0 - _progress,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.action.isHighUrgency ? AppTheme.red : AppTheme.accent),
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(_timeString, style: AppTheme.caption.copyWith(
                  color: AppTheme.accentSoft, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Action text
          Text(
            widget.action.action,
            style: AppTheme.bodyLarge.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(widget.action.reason,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary)),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              AccentButton(label: 'Start Now →', onTap: widget.onStart),
              const SizedBox(width: 10),
              AccentButton(label: 'Snooze', isOutlined: true),
            ],
          ),
        ],
      ),
    );
  }
}
