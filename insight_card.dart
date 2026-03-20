import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/memory_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/glass_widgets.dart';
import 'widgets/nba_card.dart';
import 'widgets/timeline_section.dart';
import 'widgets/stats_row.dart';
import 'widgets/insight_card.dart';
import 'widgets/morning_briefing_card.dart';
import 'widgets/ai_ticker.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(userProfileProvider);
    final nba      = ref.watch(nbaProvider);
    final timeline = ref.watch(timelineProvider);
    final insights = ref.watch(aiInsightsProvider);
    final tasks    = ref.watch(tasksProvider);
    final memories = ref.watch(memoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Status indicator
            SliverToBoxAdapter(
              child: _buildStatusBar(context)
                  .animate().fadeIn(duration: 400.ms),
            ),

            // Header
            SliverToBoxAdapter(
              child: _HomeHeader(user: user)
                  .animate().fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.05, end: 0, delay: 100.ms),
            ),

            // Scrolling AI ticker
            SliverToBoxAdapter(
              child: const AiTickerWidget()
                  .animate().fadeIn(delay: 150.ms, duration: 400.ms),
            ),

            // NBA Hero Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: NbaCard(action: nba, onStart: () => context.go(AppRouter.chat))
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.08, end: 0, delay: 200.ms),
              ),
            ),

            // Stats Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StatsRow(
                  completedTasks: tasks.where((t) => t.isDone).length,
                  totalTasks:     tasks.length,
                  focusScore:     87,
                  streak:         12,
                ).animate().fadeIn(delay: 280.ms, duration: 500.ms),
              ),
            ),

            // Timeline Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: TimelineSection(events: timeline)
                    .animate().fadeIn(delay: 350.ms, duration: 500.ms),
              ),
            ),

            // AI Insight
            if (insights.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: InsightCard(insight: insights.first)
                      .animate().fadeIn(delay: 420.ms, duration: 500.ms),
                ),
              ),

            // Morning Briefing
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: const MorningBriefingCard()
                    .animate().fadeIn(delay: 480.ms, duration: 500.ms),
              ),
            ),

            // Memory teaser
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _MemoryTeaser(memories: memories.take(2).toList())
                    .animate().fadeIn(delay: 540.ms, duration: 500.ms),
              ),
            ),

            // Bottom spacing for nav bar
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(BuildContext context) {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$h:$m',
            style: AppTheme.headlineMedium.copyWith(
              fontSize: 15, fontWeight: FontWeight.w700)),
          Row(
            children: [
              Icon(Icons.wifi, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 5),
              Icon(Icons.battery_5_bar, size: 14, color: AppTheme.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Home Header ───────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final UserProfile user;
  const _HomeHeader({required this.user});

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    if (h < 20) return 'Good Evening,';
    return 'Good Night,';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting, style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary)),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      const LinearGradient(
                        colors: [Colors.white, AppTheme.accentSoft],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  child: Text(
                    '${user.name} ✦',
                    style: AppTheme.displayMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    PulseDot(),
                    SizedBox(width: 7),
                    Text('AI Active · Monitoring 4 contexts',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        color: AppTheme.green,
                        fontWeight: FontWeight.w500,
                      )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.3),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0] : 'U',
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Memory Teaser ─────────────────────────────────────────────────────────────

class _MemoryTeaser extends ConsumerWidget {
  final List<MemoryEntry> memories;
  const _MemoryTeaser({required this.memories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (memories.isEmpty) return const SizedBox.shrink();
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('◈ ', style: TextStyle(color: AppTheme.accentSoft, fontSize: 14)),
              Text('Second Brain', style: AppTheme.headlineMedium.copyWith(fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(AppRouter.memory),
                child: Text('View All →',
                  style: AppTheme.caption.copyWith(color: AppTheme.accent)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...memories.map((m) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(m.emoji ?? '•', style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.title, style: AppTheme.bodyMedium.copyWith(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(m.description,
                        style: AppTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                AiTag('${(m.confidence * 100).round()}%',
                  color: AppTheme.green),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
