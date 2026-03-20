<div align="center">

<!-- BANNER -->
<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=7B6EF6&height=200&section=header&text=AI%20Life%20OS%20◈&fontSize=60&fontColor=ffffff&fontAlignY=38&desc=Your%20Personal%20AI%20CEO%20%7C%20Flutter%20%2B%20Claude%20API&descAlignY=58&descColor=A78BFA&fontFamily=Syne" alt="AI Life OS Banner"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Claude AI](https://img.shields.io/badge/Claude-claude--sonnet--4-7B6EF6?style=for-the-badge&logo=anthropic&logoColor=white)](https://anthropic.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-00BCD4?style=for-the-badge)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-10B981?style=for-the-badge)](LICENSE)

<br/>

> **A futuristic AI-first personal operating system.**
> Think proactively. Learn continuously. Execute intelligently.

<br/>

[**Live Demo**](#) · [**Screenshots**](#-screenshots) · [**Architecture**](#-architecture) · [**Getting Started**](#-getting-started)

</div>

---

## ✦ What is AI Life OS?

AI Life OS is not a productivity app. It's an **intelligent personal operating system** that acts as your AI CEO — proactively managing your day, learning your behavioral patterns, and always knowing the next best move.

```
Traditional app:  You tell it what to do.
AI Life OS:       It tells you what to do next — and why.
```

Built with **Flutter**, powered by **Claude claude-sonnet-4**, and designed to feel like an Apple product from the future.

---

## 📱 Screenshots

<div align="center">
<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://via.placeholder.com/220x476/0D0D1A/7B6EF6?text=Home+Dashboard" alt="Home Screen" width="200" style="border-radius:20px;"/>
      <br/><sub><b>🏠 Home Dashboard</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://via.placeholder.com/220x476/0D0D1A/06B6D4?text=AI+Chat" alt="Chat Screen" width="200" style="border-radius:20px;"/>
      <br/><sub><b>◈ AI Chat</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://via.placeholder.com/220x476/0D0D1A/10B981?text=Memory+Brain" alt="Memory Screen" width="200" style="border-radius:20px;"/>
      <br/><sub><b>🧠 Second Brain</b></sub>
    </td>
    <td align="center" width="25%">
      <img src="https://via.placeholder.com/220x476/0D0D1A/F59E0B?text=Tasks+%26+Habits" alt="Tasks Screen" width="200" style="border-radius:20px;"/>
      <br/><sub><b>◫ Tasks & Habits</b></sub>
    </td>
  </tr>
</table>

> 🖼️ **[View full visual canvas →](screenshots.html)**

</div>

---

## ✨ Core Features

<table>
<tr>
<td width="50%">

### 🧠 Memory Engine
- Extracts behavioral patterns from every conversation
- Stores habits, preferences, and routines persistently
- Injects context into every AI response
- Learns and improves with each session

</td>
<td width="50%">

### ⚡ Next Best Action Engine
- Proactively surfaces one high-leverage action
- Context-aware: time, energy, schedule, memory
- Live countdown with urgency detection
- Falls back gracefully offline

</td>
</tr>
<tr>
<td width="50%">

### ◈ Streaming AI Chat
- Real-time character-by-character streaming
- Full conversation memory context injection
- Intelligent fallback responses (offline)
- Auto-extracts patterns from chat history

</td>
<td width="50%">

### 📅 Dynamic Scheduling
- AI-generated daily task plans
- Peak energy window detection (9–11 AM)
- Auto-reschedule on deviation
- Habit-aware task sequencing

</td>
</tr>
<tr>
<td width="50%">

### 🔥 Habit Intelligence
- Adaptive difficulty scoring (0.0–1.0)
- Streak tracking with AI coaching tips
- Completion rate analytics
- Pattern-based scheduling optimization

</td>
<td width="50%">

### 🌅 Daily AI Briefing
- Personalized morning summary
- Energy forecast from sleep/habit data
- Priority focus recommendation
- Voice playback via TTS *(roadmap)*

</td>
</tr>
</table>

---

## 🏗 Architecture

```
lib/
├── main.dart                              # Entry point + Hive init + SystemUI
│
├── core/
│   ├── constants/app_constants.dart       # AI prompts, keys, config
│   ├── router/app_router.dart             # GoRouter + cinematic page transitions
│   └── theme/app_theme.dart              # Full design token system
│
├── data/
│   ├── datasources/
│   │   └── ai_service.dart               # Claude API: stream, NBA, memory extraction
│   └── models/
│       ├── task_model.dart    + .g.dart  # Hive-persisted task entity
│       ├── habit_model.dart   + .g.dart  # Hive-persisted habit entity
│       └── memory_model.dart  + .g.dart  # Chat, memories, NBA, timeline
│
└── presentation/
    ├── providers/app_providers.dart       # All Riverpod StateNotifiers
    ├── screens/
    │   ├── home/                          # Dashboard + 5 sub-widgets
    │   │   ├── home_screen.dart
    │   │   └── widgets/
    │   │       ├── nba_card.dart          # Hero NBA card with countdown
    │   │       ├── timeline_section.dart  # Today's flow timeline
    │   │       ├── stats_row.dart         # Focus/Streak/Tasks stats
    │   │       ├── insight_card.dart      # AI behavioral insight
    │   │       ├── morning_briefing_card.dart
    │   │       └── ai_ticker.dart         # Scrolling status ticker
    │   ├── chat/chat_screen.dart          # Streaming AI conversation
    │   ├── memory/memory_screen.dart      # Second brain + heatmap + rings
    │   └── tasks/tasks_screen.dart        # Tasks + Habits (1008 lines)
    └── widgets/common/
        ├── app_shell.dart                 # Navigation shell + ambient glows
        └── glass_widgets.dart             # 8 reusable design system components
```

### System Architecture Diagram

```
┌─────────────────────────────────────┐
│         Flutter Frontend            │
│  Riverpod · GoRouter · flutter_animate│
└──────────────────┬──────────────────┘
                   │
       ┌───────────▼───────────┐
       │     AI Service Layer   │
       │  (ai_service.dart)     │
       └───┬───────┬───────┬───┘
           │       │       │
    ┌──────▼──┐ ┌──▼────┐ ┌▼──────────┐
    │AI Agent │ │Memory │ │Task Engine │
    │streaming│ │extract│ │generation  │
    └──────┬──┘ └──┬────┘ └┬──────────┘
           │       │        │
    ┌──────▼───────▼────────▼──────────┐
    │          Claude claude-sonnet-4            │
    │   Streaming · JSON · Structured  │
    └──────────────────────────────────┘
           │
    ┌──────▼──────────────────────────┐
    │     Local Storage (Hive)        │
    │  Tasks · Habits · Memories      │
    └─────────────────────────────────┘
```

---

## 🎨 Design System

```
glass_widgets.dart — 8 production-ready components
```

| Component | Description |
|-----------|-------------|
| `GlassCard` | Backdrop blur card · configurable opacity/border/gradient/shadow |
| `HeroGlassCard` | NBA hero card with purple gradient and ambient glow |
| `AccentButton` | Filled (gradient) or outlined with haptic feedback |
| `PulseDot` | Animated status indicator with outer ring pulse |
| `WaveformWidget` | 7-bar audio waveform animation |
| `RingProgress` | SVG circular progress with gradient shader |
| `AiTag` | Color-tinted label chip with optional emoji |
| `ShimmerBox` | Skeleton loading placeholder |

**Design Language:**
- 🌑 Dark-first (`#070710` base)
- 🪟 Glassmorphism via `BackdropFilter` (20–30 blur)
- 🎨 Syne (headings) + DM Sans (body) typography
- ✨ Flutter Animate for all transitions
- 💜 Electric Indigo (`#7B6EF6`) as primary accent

---

## ⚙️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Frontend** | Flutter 3.x | Cross-platform UI |
| **Language** | Dart 3.x | Type-safe, modern |
| **State** | Riverpod 2.x | Reactive, scalable |
| **Navigation** | GoRouter | Declarative routing |
| **AI** | Claude claude-sonnet-4 | Streaming, NBA, memory |
| **Storage** | Hive Flutter | Local persistence |
| **Animation** | flutter_animate | Cinematic transitions |
| **HTTP** | http package | SSE streaming |
| **Charts** | fl_chart | Data visualization |
| **Code Gen** | build_runner + freezed | Type adapters |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- An [Anthropic API key](https://console.anthropic.com)
- Android Studio / Xcode / VS Code

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/ai_life_os.git
cd ai_life_os

# 2. Add required fonts (Syne + DM Sans from Google Fonts)
# → Place in assets/fonts/

# 3. Install Flutter dependencies
flutter pub get

# 4. Generate Hive adapters and Riverpod code
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-your-key-here
```

### 🔑 API Key Configuration

```bash
# Development
flutter run --dart-define=ANTHROPIC_API_KEY=sk-ant-...

# Release build
flutter build apk --dart-define=ANTHROPIC_API_KEY=sk-ant-...
flutter build ipa --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

> **No API key?** The app runs fully with intelligent offline fallbacks — all 4 screens work out of the box.

### Required Font Assets

Download from Google Fonts and place in `assets/fonts/`:

| Font | Weights Needed |
|------|---------------|
| [Syne](https://fonts.google.com/specimen/Syne) | 400, 500, 600, 700, 800 |
| [DM Sans](https://fonts.google.com/specimen/DM+Sans) | 300, 400, 500, 600 |

---

## 🤖 AI Integration Details

### Streaming Chat

```dart
// Real-time SSE streaming from Claude API
final stream = aiService.streamResponse(
  userMessage:  text,
  user:         user,
  memories:     memories,    // Behavioral patterns injected
  todayEvents:  timeline,    // Calendar context injected
  currentNba:   nba,         // Current priority injected
);

await for (final chunk in stream) {
  // Character-by-character token delivery
  ref.read(chatProvider.notifier).finalizeLastMessage(buffer);
}
```

### Next Best Action

```dart
// Structured JSON response from Claude
final nba = await aiService.generateNextBestAction(
  user:        user,
  memories:    memories,
  todayEvents: timeline,
);
// Returns: { action, reason, urgency, category }
```

### Memory Extraction

```dart
// Auto-runs after each conversation
final patterns = await aiService.extractMemories(messages);
// Returns MemoryEntry list with title, description, confidence score
ref.read(memoryProvider.notifier).addAll(patterns);
```

---

## 🗺 Roadmap

- [x] Core 4-screen architecture
- [x] Streaming Claude AI chat
- [x] Memory engine with pattern extraction
- [x] NBA (Next Best Action) engine
- [x] Hive local persistence
- [x] Riverpod state management
- [x] Cinematic page transitions
- [x] Glassmorphism design system
- [ ] Voice input via `speech_to_text`
- [ ] TTS morning briefing via `flutter_tts`
- [ ] Google Calendar sync
- [ ] iOS/Android home screen widget
- [ ] Supabase cloud sync
- [ ] Push notifications (NBA-driven)
- [ ] Onboarding personalization flow
- [ ] Emotion-aware response tuning
- [ ] Apple Watch companion app

---

## 📁 Project Stats

```
Total Dart files:    25
Lines of code:       ~3,500
Screens:             4 (Home, Chat, Memory, Tasks/Habits)
Reusable widgets:    8 (glass_widgets.dart)
AI capabilities:     3 (stream, NBA, memory extraction)
State providers:     8 (Riverpod)
Data models:         5 (Task, Habit, Memory, Chat, Timeline)
Animations:          6+ (custom AnimationController instances)
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/voice-input`)
3. Commit your changes (`git commit -m 'Add voice input with waveform'`)
4. Push to the branch (`git push origin feature/voice-input`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ◈ and Flutter**

*If this project helped you, please consider giving it a ⭐*

[![GitHub stars](https://img.shields.io/github/stars/yourusername/ai_life_os?style=social)](https://github.com/yourusername/ai_life_os)

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=7B6EF6&height=100&section=footer" alt="footer"/>

</div>
