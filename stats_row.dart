import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/memory_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/glass_widgets.dart';

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: const _MemoryHeader()
                  .animate()
                  .fadeIn(duration: 400.ms),
            ),

            // Stats rings
            SliverToBoxAdapter(
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _PatternRingsRow(),
              ).animate().fadeIn(delay: 150.ms, duration: 500.ms)
               .slideY(begin: 0.06, end: 0, delay: 150.ms),
            ),

            // Activity heatmap
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: const _ActivityHeatmap(),
              ).animate().fadeIn(delay: 250.ms, duration: 500.ms),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                child: Row(
                  children: [
                    Text('Stored Patterns',
                      style: AppTheme.headlineMedium),
                    const Spacer(),
                    AiTag('${memories.length} memories',
                      color: AppTheme.accent),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ),

            // Memory cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i >= memories.length) return null;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: _MemoryCard(entry: memories[i])
                        .animate()
                        .fadeIn(delay: (350 + i * 60).ms, duration: 450.ms)
                        .slideX(begin: 0.04, end: 0,
                            delay: (350 + i * 60).ms,
                            curve: Curves.easeOutCubic),
                  );
                },
                childCount: memories.length,
              ),
            ),

            // AI-generated summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: const _AiSummaryCard(),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Memory Header ─────────────────────────────────────────────────────────────

class _MemoryHeader extends StatelessWidget {
  const _MemoryHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.white, AppTheme.accentSoft],
                ).createShader(bounds),
                child: Text('Second Brain ◈',
                  style: AppTheme.displayMedium.copyWith(color: Colors.white)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.1),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    PulseDot(color: AppTheme.accent, size: 5),
                    SizedBox(width: 6),
                    Text('Learning',
                      style: TextStyle(
                        fontFamily: 'Syne', fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentSoft)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('AI-curated patterns & insights from your life',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Pattern Rings Row ─────────────────────────────────────────────────────────

class _PatternRingsRow extends StatelessWidget {
  const _PatternRingsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _RingCard(
          label: 'Habit\nConsistency',
          value: 0.75,
          gradient: AppTheme.accentGradient,
          valueColor: AppTheme.accentSoft,
        )),
        const SizedBox(width: 10),
        Expanded(child: _RingCard(
          label: 'Focus\nQuality',
          value: 0.87,
          gradient: AppTheme.greenGradient,
          valueColor: AppTheme.green,
        )),
        const SizedBox(width: 10),
        Expanded(child: _RingCard(
          label: 'Energy\nBalance',
          value: 0.67,
          gradient: AppTheme.amberGradient,
          valueColor: AppTheme.amber,
        )),
      ],
    );
  }
}

class _RingCard extends StatefulWidget {
  final String label;
  final double value;
  final Gradient gradient;
  final Color valueColor;

  const _RingCard({
    required this.label,
    required this.value,
    required this.gradient,
    required this.valueColor,
  });

  @override
  State<_RingCard> createState() => _RingCardState();
}

class _RingCardState extends State<_RingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => RingProgress(
              value: widget.value * _anim.value,
              size: 80,
              strokeWidth: 6,
              gradient: widget.gradient,
              center: Text(
                '${(widget.value * _anim.value * 100).round()}%',
                style: AppTheme.headlineMedium.copyWith(
                  fontSize: 17, color: widget.valueColor),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(widget.label,
            textAlign: TextAlign.center,
            style: AppTheme.caption.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

// ── Activity Heatmap ──────────────────────────────────────────────────────────

class _ActivityHeatmap extends StatelessWidget {
  const _ActivityHeatmap();

  static final _random = math.Random(42);
  static final List<int> _heat = List.generate(35, (_) =>
    _random.nextInt(5));

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Activity this month',
                style: AppTheme.headlineMedium.copyWith(fontSize: 13)),
              const Spacer(),
              Text(
                '${DateTime.now().month == 1 ? 'January' : DateTime.now().month == 2 ? 'February' : DateTime.now().month == 3 ? 'March' : 'April'} ${DateTime.now().year}',
                style: AppTheme.caption),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 35,
            itemBuilder: (_, i) => _HeatCell(level: _heat[i]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Less', style: AppTheme.caption),
              const SizedBox(width: 6),
              ...List.generate(5, (i) => Container(
                width: 11, height: 11,
                margin: const EdgeInsets.only(right: 3),
                decoration: BoxDecoration(
                  color: _heatColor(i),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
              const SizedBox(width: 3),
              Text('More', style: AppTheme.caption),
            ],
          ),
        ],
      ),
    );
  }

  static Color _heatColor(int level) {
    if (level == 0) return Colors.white.withOpacity(0.04);
    return AppTheme.accent.withOpacity(0.15 + level * 0.18);
  }
}

class _HeatCell extends StatelessWidget {
  final int level;
  const _HeatCell({required this.level});

  Color get _color {
    if (level == 0) return Colors.white.withOpacity(0.04);
    return AppTheme.accent.withOpacity(0.15 + level * 0.18);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ── Memory Card ───────────────────────────────────────────────────────────────

class _MemoryCard extends StatelessWidget {
  final MemoryEntry entry;
  const _MemoryCard({required this.entry});

  Color get _categoryColor {
    switch (entry.category) {
      case MemoryCategory.productivity: return AppTheme.accent;
      case MemoryCategory.health:       return AppTheme.green;
      case MemoryCategory.habits:       return AppTheme.accentSoft;
      case MemoryCategory.preferences:  return AppTheme.accentCyan;
      case MemoryCategory.schedule:     return AppTheme.amber;
      case MemoryCategory.social:       return AppTheme.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: _categoryColor.withOpacity(0.12),
              border: Border.all(color: _categoryColor.withOpacity(0.22)),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                entry.emoji ?? '◈',
                style: const TextStyle(fontSize: 19),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(entry.title,
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _categoryColor.withOpacity(0.12),
                        border: Border.all(
                          color: _categoryColor.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${(entry.confidence * 100).round()}% conf.',
                        style: AppTheme.caption.copyWith(
                          color: _categoryColor,
                          fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(entry.description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12, height: 1.55)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${entry.observationCount} observations',
                      style: AppTheme.caption,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3, height: 3,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.category.name,
                      style: AppTheme.caption.copyWith(
                        color: _categoryColor),
                    ),
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

// ── AI Summary Card ───────────────────────────────────────────────────────────

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: AppTheme.heroGradient,
      borderColor: AppTheme.accent.withOpacity(0.2),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('◈  ', style: TextStyle(
                color: AppTheme.accentSoft, fontSize: 15)),
              Text('AI Pattern Summary',
                style: AppTheme.headlineMedium.copyWith(fontSize: 14)),
              const Spacer(),
              AiTag('Weekly', color: AppTheme.accent),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your behavioral data shows a consistent peak performance window '
            'in the morning. Your gym completion rate improves dramatically '
            'when scheduled after 4 PM. Learning retention is highest when '
            'immediately applied to projects. Consider protecting your '
            '9–11 AM block as a sacred focus zone.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 13, height: 1.7),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _SummaryMetric(
                label: 'Patterns',
                value: '12',
                color: AppTheme.accentSoft,
              )),
              Expanded(child: _SummaryMetric(
                label: 'Avg. Confidence',
                value: '87%',
                color: AppTheme.green,
              )),
              Expanded(child: _SummaryMetric(
                label: 'Days tracked',
                value: '30',
                color: AppTheme.amber,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.headlineLarge.copyWith(
          fontFamily: 'Syne', fontSize: 20, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.caption, textAlign: TextAlign.center),
      ],
    );
  }
}
