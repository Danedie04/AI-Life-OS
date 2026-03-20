import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/datasources/ai_service.dart';
import '../data/models/memory_model.dart';
import '../data/models/task_model.dart';
import '../data/models/habit_model.dart';

// ─── Core Services ────────────────────────────────────────────────────────────

final aiServiceProvider = Provider<AiService>((ref) {
  // Replace with your actual API key or use env variable
  return AiService(apiKey: const String.fromEnvironment('ANTHROPIC_API_KEY', defaultValue: 'your_api_key_here'));
});

// ─── User Profile ────────────────────────────────────────────────────────────

final userProfileProvider = StateProvider<UserProfile>((ref) {
  return UserProfile.demo;
});

// ─── Memory Engine ────────────────────────────────────────────────────────────

class MemoryNotifier extends StateNotifier<List<MemoryEntry>> {
  MemoryNotifier() : super(_defaultMemories());

  void addMemory(MemoryEntry entry) {
    state = [...state, entry];
  }

  void addAll(List<MemoryEntry> entries) {
    final existing = state.map((e) => e.title.toLowerCase()).toSet();
    final novel = entries.where((e) => !existing.contains(e.title.toLowerCase())).toList();
    if (novel.isNotEmpty) state = [...state, ...novel];
  }

  void updateConfidence(String id, double confidence) {
    state = state.map((e) => e.id == id
        ? (MemoryEntry(
            id: e.id, title: e.title, description: e.description,
            categoryIndex: e.categoryIndex, confidence: confidence,
            createdAt: e.createdAt, updatedAt: DateTime.now(),
            observationCount: e.observationCount + 1, emoji: e.emoji,
          ))
        : e).toList();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  static List<MemoryEntry> _defaultMemories() => [
    MemoryEntry(id:'m1', title:'Peak Focus: 9–11 AM',
      description:'Consistently completes 2.4× more complex tasks in this window. Observed across 23 sessions.',
      categoryIndex:0, confidence:0.96, createdAt:DateTime.now(), updatedAt:DateTime.now(),
      observationCount:23, emoji:'⚡'),
    MemoryEntry(id:'m2', title:'Gym preference: 5–6 PM',
      description:'Skips gym 3× more often when scheduled before 2 PM. Evening sessions 89% completion.',
      categoryIndex:1, confidence:0.89, createdAt:DateTime.now(), updatedAt:DateTime.now(),
      observationCount:18, emoji:'🏃'),
    MemoryEntry(id:'m3', title:'Learning style: Applied',
      description:'Retention improves 40% when building while learning. Prefers project-based approach.',
      categoryIndex:2, confidence:0.81, createdAt:DateTime.now(), updatedAt:DateTime.now(),
      observationCount:12, emoji:'📚'),
    MemoryEntry(id:'m4', title:'Sleep: Natural night owl',
      description:'Natural sleep time 12:30–8:00 AM. Energy correlates with 7.5+ hours of sleep.',
      categoryIndex:3, confidence:0.94, createdAt:DateTime.now(), updatedAt:DateTime.now(),
      observationCount:30, emoji:'🌙'),
    MemoryEntry(id:'m5', title:'Deep work: Requires silence',
      description:'Productivity drops 60% with background noise. Prefers complete silence or lo-fi music.',
      categoryIndex:3, confidence:0.77, createdAt:DateTime.now(), updatedAt:DateTime.now(),
      observationCount:15, emoji:'🎧'),
  ];
}

final memoryProvider = StateNotifierProvider<MemoryNotifier, List<MemoryEntry>>((ref) {
  return MemoryNotifier();
});

// ─── Tasks ────────────────────────────────────────────────────────────────────

class TasksNotifier extends StateNotifier<List<TaskModel>> {
  TasksNotifier() : super(_defaultTasks());

  void toggleTask(String id) {
    state = state.map((t) {
      if (t.id != id) return t;
      final newStatus = t.isDone ? TaskStatus.pending : TaskStatus.completed;
      return t.copyWith(status: newStatus,
          completedAt: newStatus == TaskStatus.completed ? DateTime.now() : null);
    }).toList();
  }

  void addTask(TaskModel task) => state = [...state, task];

  void addAll(List<TaskModel> tasks) => state = [...state, ...tasks];

  void removeTask(String id) => state = state.where((t) => t.id != id).toList();

  void reschedule(String id, DateTime newTime) {
    state = state.map((t) => t.id == id ? t.copyWith(scheduledTime: newTime) : t).toList();
  }

  int get completedCount => state.where((t) => t.isDone).length;
  int get totalCount     => state.length;

  static List<TaskModel> _defaultTasks() {
    final now = DateTime.now();
    return [
      TaskModel(id:'t1', title:'Review PRs from yesterday', priorityIndex:0,
        statusIndex:2, sourceIndex:0, category:'work', estimatedMinutes:20,
        scheduledTime: DateTime(now.year,now.month,now.day,8,30), createdAt:now),
      TaskModel(id:'t2', title:'Update API documentation', priorityIndex:1,
        statusIndex:2, sourceIndex:1, category:'work', estimatedMinutes:30,
        aiReason:'Pending for 3 days — team is blocked',
        scheduledTime: DateTime(now.year,now.month,now.day,9,0), createdAt:now),
      TaskModel(id:'t3', title:'Finish product roadmap doc', priorityIndex:0,
        statusIndex:0, sourceIndex:0, category:'work', estimatedMinutes:90,
        scheduledTime: DateTime(now.year,now.month,now.day,9,30), createdAt:now),
      TaskModel(id:'t4', title:'Prepare standup brief', priorityIndex:1,
        statusIndex:0, sourceIndex:1, category:'work', estimatedMinutes:10,
        aiReason:'Meeting in 45 min — prepare talking points now',
        scheduledTime: DateTime(now.year,now.month,now.day,10,15), createdAt:now),
      TaskModel(id:'t5', title:'Review Flutter architecture PR', priorityIndex:0,
        statusIndex:0, sourceIndex:0, category:'work', estimatedMinutes:45,
        scheduledTime: DateTime(now.year,now.month,now.day,13,0), createdAt:now),
      TaskModel(id:'t6', title:'Send weekly report to team', priorityIndex:1,
        statusIndex:0, sourceIndex:1, category:'work', estimatedMinutes:15,
        aiReason:'End-of-week routine — maintains team alignment',
        scheduledTime: DateTime(now.year,now.month,now.day,17,0), createdAt:now),
    ];
  }
}

final tasksProvider = StateNotifierProvider<TasksNotifier, List<TaskModel>>((ref) {
  return TasksNotifier();
});

// ─── Habits ───────────────────────────────────────────────────────────────────

class HabitsNotifier extends StateNotifier<List<HabitModel>> {
  HabitsNotifier() : super(_defaultHabits());

  void markDone(String id) {
    state = state.map((h) {
      if (h.id != id || h.isCompletedToday) return h;
      final updated = HabitModel(
        id: h.id, title: h.title, emoji: h.emoji, description: h.description,
        frequencyIndex: h.frequencyIndex, categoryIndex: h.categoryIndex,
        targetPerWeek: h.targetPerWeek,
        currentStreak: h.currentStreak + 1,
        longestStreak: h.longestStreak < h.currentStreak + 1 ? h.currentStreak + 1 : h.longestStreak,
        completedDates: [...h.completedDates, DateTime.now()],
        targetTimeHour: h.targetTimeHour, createdAt: h.createdAt,
        aiCoachTip: h.aiCoachTip, difficultyScore: h.difficultyScore,
        colorHex: h.colorHex,
      );
      return updated;
    }).toList();
  }

  static List<HabitModel> _defaultHabits() => [
    HabitModel(id:'h1', title:'Meditation', emoji:'🧘', description:'10 min daily mindfulness',
      categoryIndex:3, currentStreak:12, longestStreak:18, targetPerWeek:7,
      completedDates: List.generate(12, (i) => DateTime.now().subtract(Duration(days: i))),
      colorHex:'#7B6EF6', createdAt: DateTime.now().subtract(const Duration(days:30))),
    HabitModel(id:'h2', title:'Read 20 Pages', emoji:'📖', description:'Daily reading habit',
      categoryIndex:2, currentStreak:7, longestStreak:14, targetPerWeek:7,
      completedDates: List.generate(7, (i) => DateTime.now().subtract(Duration(days: i))),
      colorHex:'#A78BFA', createdAt: DateTime.now().subtract(const Duration(days:45))),
    HabitModel(id:'h3', title:'Gym', emoji:'💪', description:'Strength training 5x/week',
      categoryIndex:1, currentStreak:5, longestStreak:21, targetPerWeek:5,
      completedDates: List.generate(5, (i) => DateTime.now().subtract(Duration(days: i * 1 + (i > 1 ? 1 : 0)))),
      colorHex:'#F59E0B', createdAt: DateTime.now().subtract(const Duration(days:60))),
    HabitModel(id:'h4', title:'Cold Shower', emoji:'🚿', description:'2-min cold exposure',
      categoryIndex:1, currentStreak:3, longestStreak:9, targetPerWeek:5,
      completedDates: List.generate(3, (i) => DateTime.now().subtract(Duration(days: i))),
      colorHex:'#06B6D4', createdAt: DateTime.now().subtract(const Duration(days:14))),
  ];
}

final habitsProvider = StateNotifierProvider<HabitsNotifier, List<HabitModel>>((ref) {
  return HabitsNotifier();
});

// ─── Chat ─────────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super(_initialMessages());

  void addMessage(ChatMessage msg) => state = [...state, msg];

  void updateLastMessage(String content) {
    if (state.isEmpty) return;
    final last = state.last;
    state = [...state.sublist(0, state.length - 1),
      ChatMessage(id: last.id, content: content, roleIndex: last.roleIndex,
          timestamp: last.timestamp, isStreaming: true)];
  }

  void finalizeLastMessage(String content) {
    if (state.isEmpty) return;
    final last = state.last;
    state = [...state.sublist(0, state.length - 1),
      ChatMessage(id: last.id, content: content, roleIndex: last.roleIndex,
          timestamp: last.timestamp, isStreaming: false)];
  }

  static List<ChatMessage> _initialMessages() => [
    ChatMessage(id:'c1',
      content:'Good morning, Pawan. I\'ve analyzed your calendar — you have a focused, high-output day ahead. Your team meeting starts in 45 minutes. Want me to brief you on key talking points?',
      roleIndex:1, timestamp: DateTime.now().subtract(const Duration(minutes:5))),
    ChatMessage(id:'c2',
      content:'Also — I noticed you\'ve been in deep work mode since 9 AM. I\'ve silenced non-critical notifications and adjusted your schedule to protect this block. 🎯',
      roleIndex:1, timestamp: DateTime.now().subtract(const Duration(minutes:5))),
  ];
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

// Chat loading/streaming state
final chatLoadingProvider = StateProvider<bool>((ref) => false);

// ─── NBA ─────────────────────────────────────────────────────────────────────

final nbaProvider = StateProvider<NextBestAction>((ref) {
  return NextBestAction.placeholder;
});

// ─── Today's Timeline ─────────────────────────────────────────────────────────

final timelineProvider = Provider<List<TimelineEvent>>((ref) {
  final now = DateTime.now();
  return [
    TimelineEvent(id:'e1', title:'Morning Meditation',
      subtitle:'10 min · Mindfulness',
      time: DateTime(now.year,now.month,now.day,8,30),
      status: EventStatus.done, category:'health',
      duration: const Duration(minutes:10)),
    TimelineEvent(id:'e2', title:'Deep Work Session',
      subtitle:'Product roadmap · 2 hrs',
      time: DateTime(now.year,now.month,now.day,9,0),
      status: EventStatus.current, category:'work',
      duration: const Duration(hours:2)),
    TimelineEvent(id:'e3', title:'Team Stand-up',
      subtitle:'Google Meet · 30 min',
      time: DateTime(now.year,now.month,now.day,11,0),
      status: EventStatus.upcoming, category:'work',
      duration: const Duration(minutes:30)),
    TimelineEvent(id:'e4', title:'Gym · Strength',
      subtitle:'45 min · Push day',
      time: DateTime(now.year,now.month,now.day,17,0),
      status: EventStatus.upcoming, category:'health',
      duration: const Duration(minutes:45)),
    TimelineEvent(id:'e5', title:'Learning Block',
      subtitle:'Flutter + AI · 1 hr',
      time: DateTime(now.year,now.month,now.day,19,0),
      status: EventStatus.upcoming, category:'learning',
      duration: const Duration(hours:1)),
  ];
});

// ─── Insights ────────────────────────────────────────────────────────────────

final aiInsightsProvider = Provider<List<String>>((ref) => [
  '⚡ You complete 2.4× more tasks between 9–11 AM. Block this time daily.',
  '🔥 Your 12-day meditation streak is your longest this year. Keep it up.',
  '📈 Task completion is up 23% this week vs last week.',
  '💡 You tend to skip gym when it\'s scheduled before 2 PM. Rescheduled to 5 PM.',
]);
