import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/memory_model.dart';
import '../../../data/models/task_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/glass_widgets.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateAiTasks() async {
    setState(() => _isGenerating = true);
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final aiTasks = [
      TaskModel(
        id: const Uuid().v4(),
        title: 'Plan weekly goals & OKRs',
        description: 'Set clear objectives for the week ahead',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.pending.index,
        sourceIndex: TaskSource.aiGenerated.index,
        category: 'work',
        estimatedMinutes: 20,
        aiReason: 'Monday morning alignment sets the tone for the week',
        scheduledTime: DateTime.now().add(const Duration(hours: 12)),
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: '90-min deep work block',
        description: 'Leverage your 9–11 AM peak focus window',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.pending.index,
        sourceIndex: TaskSource.aiGenerated.index,
        category: 'work',
        estimatedMinutes: 90,
        aiReason: 'Your most productive window — protect it',
        scheduledTime: DateTime.now().add(const Duration(hours: 13)),
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'Evening review & journal',
        description: '15 min daily reflection practice',
        priorityIndex: TaskPriority.medium.index,
        statusIndex: TaskStatus.pending.index,
        sourceIndex: TaskSource.aiGenerated.index,
        category: 'personal',
        estimatedMinutes: 15,
        aiReason: 'Improves next-day preparation by ~35%',
        scheduledTime: DateTime.now().add(const Duration(hours: 20)),
        createdAt: DateTime.now(),
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'Read 20 pages',
        description: 'Maintain your reading habit streak',
        priorityIndex: TaskPriority.medium.index,
        statusIndex: TaskStatus.pending.index,
        sourceIndex: TaskSource.aiGenerated.index,
        category: 'learning',
        estimatedMinutes: 25,
        aiReason: 'Maintains your 7-day streak',
        scheduledTime: DateTime.now().add(const Duration(hours: 21)),
        createdAt: DateTime.now(),
      ),
    ];

    ref.read(tasksProvider.notifier).addAll(aiTasks);
    setState(() => _isGenerating = false);
    HapticFeedback.notificationSuccess();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Text('✦ ', style: TextStyle(color: AppTheme.accentSoft)),
              Text('4 tasks generated for tomorrow',
                style: TextStyle(
                  fontFamily: 'DMSans', color: Colors.white,
                  fontWeight: FontWeight.w500)),
            ],
          ),
          backgroundColor: AppTheme.bgCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            side: const BorderSide(color: AppTheme.border2),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 90),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks  = ref.watch(tasksProvider);
    final habits = ref.watch(habitsProvider);

    final doneCount  = tasks.where((t) => t.isDone).length;
    final totalCount = tasks.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _TasksHeader(
              done: doneCount,
              total: totalCount,
              tabController: _tabCtrl,
            ).animate().fadeIn(duration: 400.ms),

            // Tab body
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                physics: const BouncingScrollPhysics(),
                children: [
                  // Tab 1: Tasks
                  _TasksTab(
                    tasks: tasks,
                    onGenerate: _generateAiTasks,
                    isGenerating: _isGenerating,
                  ),
                  // Tab 2: Habits
                  _HabitsTab(habits: habits),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _TasksHeader extends StatelessWidget {
  final int done;
  final int total;
  final TabController tabController;

  const _TasksHeader({
    required this.done,
    required this.total,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.white, AppTheme.accentSoft],
                      ).createShader(bounds),
                      child: Text('Tasks & Habits',
                        style: AppTheme.displayMedium.copyWith(
                          color: Colors.white)),
                    ),
                    const SizedBox(height: 4),
                    Text('AI-generated · adaptive · smart',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textMuted)),
                  ],
                ),
              ),
              // Completion ring
              RingProgress(
                value: total == 0 ? 0 : done / total,
                size: 48,
                strokeWidth: 4,
                gradient: AppTheme.greenGradient,
                center: Text('$done',
                  style: AppTheme.caption.copyWith(
                    fontFamily: 'Syne', fontWeight: FontWeight.w800,
                    fontSize: 13, color: AppTheme.green)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: AppTheme.border),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(3),
              labelStyle: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelColor: AppTheme.textMuted,
              labelColor: Colors.white,
              tabs: const [
                Tab(text: 'Tasks'),
                Tab(text: 'Habits'),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Tasks Tab ─────────────────────────────────────────────────────────────────

class _TasksTab extends ConsumerWidget {
  final List<TaskModel> tasks;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const _TasksTab({
    required this.tasks,
    required this.onGenerate,
    required this.isGenerating,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending   = tasks.where((t) => !t.isDone).toList();
    final completed = tasks.where((t) => t.isDone).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        // AI suggestion banner
        const _AiSuggestionBanner()
            .animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 16),

        // Pending tasks
        if (pending.isNotEmpty) ...[
          _SectionTitle(
            title: 'Pending',
            badge: '${pending.length}',
            badgeColor: AppTheme.amber,
          ).animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 8),
          ...pending.asMap().entries.map((e) =>
            _TaskItem(task: e.value, index: e.key)
                .animate()
                .fadeIn(delay: (280 + e.key * 50).ms, duration: 400.ms)
                .slideY(begin: 0.05, end: 0,
                    delay: (280 + e.key * 50).ms,
                    curve: Curves.easeOutCubic)),
          const SizedBox(height: 16),
        ],

        // AI Generate button
        _AiGenerateButton(
          onTap: onGenerate,
          isLoading: isGenerating,
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 20),

        // Completed tasks
        if (completed.isNotEmpty) ...[
          _SectionTitle(
            title: 'Completed Today',
            badge: '${completed.length}',
            badgeColor: AppTheme.green,
          ).animate().fadeIn(delay: 550.ms),
          const SizedBox(height: 8),
          ...completed.asMap().entries.map((e) =>
            _TaskItem(task: e.value, index: e.key)
                .animate()
                .fadeIn(delay: (580 + e.key * 40).ms, duration: 400.ms)),
        ],

        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Task Item ─────────────────────────────────────────────────────────────────

class _TaskItem extends ConsumerStatefulWidget {
  final TaskModel task;
  final int index;

  const _TaskItem({required this.task, required this.index});

  @override
  ConsumerState<_TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends ConsumerState<_TaskItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _checkScale = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut));
    if (widget.task.isDone) _checkCtrl.value = 1.0;
  }

  @override
  void dispose() { _checkCtrl.dispose(); super.dispose(); }

  void _toggle() {
    HapticFeedback.lightImpact();
    ref.read(tasksProvider.notifier).toggleTask(widget.task.id);
    if (!widget.task.isDone) {
      _checkCtrl.forward().then((_) => _checkCtrl.reverse());
    }
  }

  Color get _priorityColor {
    switch (widget.task.priority) {
      case TaskPriority.high:   return AppTheme.red;
      case TaskPriority.medium: return AppTheme.amber;
      case TaskPriority.low:    return AppTheme.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.task.isDone;
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDone
              ? AppTheme.surface.withOpacity(0.5)
              : AppTheme.surface2,
          border: Border.all(
            color: isDone ? AppTheme.border : AppTheme.border2,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: Row(
          children: [
            // Check box
            ScaleTransition(
              scale: _checkScale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: isDone ? AppTheme.accent : Colors.transparent,
                  border: Border.all(
                    color: isDone ? AppTheme.accent : AppTheme.border2,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: isDone ? [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.3),
                      blurRadius: 8),
                  ] : null,
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isDone
                          ? AppTheme.textMuted
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (widget.task.aiReason != null && !isDone) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Text('✦ ',
                          style: TextStyle(
                            color: AppTheme.accentSoft, fontSize: 10)),
                        Expanded(
                          child: Text(widget.task.aiReason!,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textMuted)),
                        ),
                      ],
                    ),
                  ],
                  if (widget.task.estimatedMinutes > 0 && !isDone) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                          size: 10, color: AppTheme.textMuted),
                        const SizedBox(width: 3),
                        Text('${widget.task.estimatedMinutes} min',
                          style: AppTheme.caption),
                        if (widget.task.category != null) ...[
                          const SizedBox(width: 8),
                          Container(width: 2, height: 2,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.textMuted)),
                          const SizedBox(width: 8),
                          Text(widget.task.category!,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textMuted)),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Priority dot + AI badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppTheme.textMuted
                        : _priorityColor,
                    boxShadow: isDone ? null : [
                      BoxShadow(
                        color: _priorityColor.withOpacity(0.4),
                        blurRadius: 6),
                    ],
                  ),
                ),
                if (widget.task.isAiGenerated && !isDone) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.12),
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.25)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('AI',
                      style: TextStyle(
                        fontFamily: 'Syne', fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentSoft,
                        letterSpacing: 0.05)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Habits Tab ────────────────────────────────────────────────────────────────

class _HabitsTab extends ConsumerWidget {
  final List<HabitModel> habits;
  const _HabitsTab({required this.habits});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        // Weekly overview
        const _HabitWeeklyOverview()
            .animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 16),

        // Section title
        _SectionTitle(title: 'Active Habits', badge: '${habits.length}')
            .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 10),

        // Habit cards
        ...habits.asMap().entries.map((e) =>
          _HabitCard(habit: e.value)
              .animate()
              .fadeIn(delay: (230 + e.key * 70).ms, duration: 450.ms)
              .slideY(begin: 0.05, end: 0,
                  delay: (230 + e.key * 70).ms,
                  curve: Curves.easeOutCubic)),

        const SizedBox(height: 16),

        // Add habit CTA
        GestureDetector(
          onTap: () {},
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.accent.withOpacity(0.4)),
                    color: AppTheme.accent.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.add,
                    size: 16, color: AppTheme.accentSoft),
                ),
                const SizedBox(width: 10),
                Text('Add New Habit',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.accentSoft,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 600.ms),

        const SizedBox(height: 20),
      ],
    );
  }
}

// ── Habit Card ────────────────────────────────────────────────────────────────

class _HabitCard extends ConsumerStatefulWidget {
  final HabitModel habit;
  const _HabitCard({required this.habit});

  @override
  ConsumerState<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<_HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() { _progressCtrl.dispose(); super.dispose(); }

  Color get _color {
    try {
      final hex = widget.habit.colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.accent;
    }
  }

  double get _progressValue =>
    (widget.habit.completionsThisWeek / widget.habit.targetPerWeek)
        .clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final habit  = widget.habit;
    final isDone = habit.isCompletedToday;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: isDone
          ? _color.withOpacity(0.25)
          : AppTheme.border,
      backgroundColor: isDone
          ? _color.withOpacity(0.06)
          : AppTheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(habit.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title, style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600)),
                    if (habit.description != null)
                      Text(habit.description!,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textMuted)),
                  ],
                ),
              ),
              // Streak badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.12),
                  border: Border.all(
                    color: AppTheme.amber.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('🔥',
                      style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text('${habit.currentStreak}',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.amber,
                        fontWeight: FontWeight.w800,
                        fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _progressValue * _progressAnim.value,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(_color),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Footer
          Row(
            children: [
              Text(
                '${habit.completionsThisWeek}/${habit.targetPerWeek} this week',
                style: AppTheme.caption,
              ),
              const Spacer(),
              // Check button
              GestureDetector(
                onTap: () {
                  if (!isDone) {
                    HapticFeedback.mediumImpact();
                    ref.read(habitsProvider.notifier).markDone(habit.id);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? _color : Colors.transparent,
                    border: Border.all(
                      color: isDone ? _color : AppTheme.border2,
                      width: 2,
                    ),
                    boxShadow: isDone ? [
                      BoxShadow(
                        color: _color.withOpacity(0.35),
                        blurRadius: 10),
                    ] : null,
                  ),
                  child: isDone
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Habit Weekly Overview ─────────────────────────────────────────────────────

class _HabitWeeklyOverview extends ConsumerWidget {
  const _HabitWeeklyOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final completed = habits.where((h) => h.isCompletedToday).length;
    final total = habits.length;

    return GlassCard(
      gradient: AppTheme.heroGradient,
      borderColor: AppTheme.accent.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today\'s Habits',
                  style: AppTheme.headlineMedium.copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  completed == total
                      ? '🎉 All habits complete!'
                      : '$completed of $total completed',
                  style: AppTheme.bodySmall.copyWith(
                    color: completed == total
                        ? AppTheme.green
                        : AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    backgroundColor: Colors.white.withOpacity(0.06),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.green),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Circle summary
          RingProgress(
            value: total == 0 ? 0 : completed / total,
            size: 56,
            strokeWidth: 5,
            gradient: AppTheme.greenGradient,
            center: Text('$completed',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.green, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? badge;
  final Color? badgeColor;

  const _SectionTitle({
    required this.title,
    this.badge,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.headlineMedium),
        if (badge != null) ...[
          const SizedBox(width: 8),
          AiTag(badge!, color: badgeColor ?? AppTheme.accent),
        ],
      ],
    );
  }
}

class _AiSuggestionBanner extends StatelessWidget {
  const _AiSuggestionBanner();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      backgroundColor: AppTheme.accent.withOpacity(0.06),
      borderColor: AppTheme.accent.withOpacity(0.2),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('✦',
                style: TextStyle(
                  color: AppTheme.accentSoft, fontSize: 14)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Suggestion',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.accentSoft,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08)),
                const SizedBox(height: 4),
                Text(
                  'Adding a 15-min evening review could improve your '
                  'next-day preparation by ~35%. Want me to add it?',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    AccentButton(
                      label: 'Add to schedule',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    ),
                    const SizedBox(width: 8),
                    AccentButton(
                      label: 'Dismiss',
                      isOutlined: true,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
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

class _AiGenerateButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _AiGenerateButton({
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.accent.withOpacity(isLoading ? 0.08 : 0.15),
              AppTheme.accentCyan.withOpacity(isLoading ? 0.04 : 0.08),
            ],
          ),
          border: Border.all(
            color: AppTheme.accent.withOpacity(isLoading ? 0.15 : 0.3)),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  color: AppTheme.accentSoft,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(Icons.bolt_rounded,
                size: 17, color: AppTheme.accentSoft),
            const SizedBox(width: 8),
            Text(
              isLoading
                  ? 'Analyzing patterns…'
                  : 'Generate AI Tasks for Tomorrow',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLoading
                    ? AppTheme.textMuted
                    : AppTheme.accentSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
