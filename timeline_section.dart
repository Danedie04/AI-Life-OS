import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/ai_service.dart';
import '../../../data/models/memory_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/glass_widgets.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController      _scrollCtrl = ScrollController();
  bool _isLoading = false;
  String _streamBuffer = '';

  static const _suggestions = [
    'What\'s my priority now?',
    'How\'s my week looking?',
    'Add a new task',
    'My morning summary',
    'Coach me on habits',
    'Reschedule gym',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _inputCtrl.text).trim();
    if (text.isEmpty || _isLoading) return;

    _inputCtrl.clear();
    HapticFeedback.lightImpact();

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      content: text,
      roleIndex: MessageRole.user.index,
      timestamp: DateTime.now(),
    );
    ref.read(chatProvider.notifier).addMessage(userMsg);
    _scrollToBottom();

    setState(() {
      _isLoading    = true;
      _streamBuffer = '';
    });

    // Add placeholder AI message
    final aiId = const Uuid().v4();
    ref.read(chatProvider.notifier).addMessage(ChatMessage(
      id: aiId,
      content: '',
      roleIndex: MessageRole.assistant.index,
      timestamp: DateTime.now(),
      isStreaming: true,
    ));

    try {
      final aiService  = ref.read(aiServiceProvider);
      final user       = ref.read(userProfileProvider);
      final memories   = ref.read(memoryProvider);
      final timeline   = ref.read(timelineProvider);
      final nba        = ref.read(nbaProvider);

      final stream = aiService.streamResponse(
        userMessage:  text,
        user:         user,
        memories:     memories,
        todayEvents:  timeline,
        currentNba:   nba,
      );

      await for (final chunk in stream) {
        _streamBuffer += chunk;
        ref.read(chatProvider.notifier).finalizeLastMessage(_streamBuffer);
        _scrollToBottom();
      }
    } on AiServiceException catch (e) {
      // Fallback mock response
      await _mockStream(_getFallbackResponse(text));
    } catch (_) {
      await _mockStream(_getFallbackResponse(text));
    } finally {
      ref.read(chatProvider.notifier).finalizeLastMessage(_streamBuffer);
      setState(() => _isLoading = false);
      _scrollToBottom();

      // Background memory extraction
      _extractMemories();
    }
  }

  Future<void> _mockStream(String text) async {
    _streamBuffer = '';
    for (var i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 18));
      _streamBuffer += text[i];
      ref.read(chatProvider.notifier).finalizeLastMessage(_streamBuffer);
      if (mounted) _scrollToBottom();
    }
  }

  Future<void> _extractMemories() async {
    try {
      final aiService = ref.read(aiServiceProvider);
      final messages  = ref.read(chatProvider);
      if (messages.length < 4) return;
      final recent = messages.where((m) => m.isUser || m.isAI).toList();
      final extracted = await aiService.extractMemories(recent);
      if (extracted.isNotEmpty) {
        ref.read(memoryProvider.notifier).addAll(extracted);
      }
    } catch (_) {}
  }

  String _getFallbackResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('priority') || lower.contains('next')) {
      return 'Based on your current context, your top priority is finishing the product roadmap document. You have a deep work block active right now — this is your peak focus window. The team meeting starts in 45 minutes, so aim to draft the core sections before then. Want me to outline the structure? 🎯';
    }
    if (lower.contains('week') || lower.contains('schedule')) {
      return 'Your week looks strong — 8 of 12 tasks completed, 3 active habit streaks, and your focus quality is trending upward (+12% vs last week). Wednesday has your heaviest workload. I\'d suggest moving the product review to Thursday when your calendar is lighter. 📈';
    }
    if (lower.contains('gym') || lower.contains('reschedule')) {
      return 'Done ✓ I\'ve shifted gym to 5:30 PM and adjusted your evening flow: Gym → Dinner → Learning block → Wind down. This matches your historical 89% completion rate for evening sessions. 💪';
    }
    if (lower.contains('habit') || lower.contains('coach')) {
      return 'Your meditation streak (12 days 🔥) is your longest this year — the 14-day mark is where habits become automatic. Your gym consistency is at 3/5 this week. One nudge: your cold shower habit (3-day streak) has the highest energy correlation in your data. Worth protecting. 🧘';
    }
    if (lower.contains('morning') || lower.contains('summary') || lower.contains('brief')) {
      return 'Morning debrief:\n\n✅ Completed 2 tasks before 9 AM\n⚡ Deep work block active (9–11 AM)\n📅 Team standup in 45 min\n🔥 Meditation streak: 12 days\n\nYour energy score is High today. Front-load the complex work — you\'re sharp right now.';
    }
    return 'Understood. Based on your patterns and current context, I\'d recommend starting with the highest-leverage task in your current block. You\'re in peak focus mode right now — deep work tasks complete 2.4× faster between 9–11 AM. Want me to break this down into a focused action plan? 🎯';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: AppTheme.animFast,
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            _ChatHeader()
                .animate().fadeIn(duration: 400.ms),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: messages.length + (_isLoading && messages.last.isAI && messages.last.isStreaming ? 0 : 0),
                itemBuilder: (context, i) {
                  final msg = messages[i];
                  return _MessageBubble(message: msg)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0, duration: 300.ms,
                          curve: Curves.easeOutCubic);
                },
              ),
            ),

            // Input area
            _ChatInputArea(
              controller: _inputCtrl,
              isLoading: _isLoading,
              onSend: _sendMessage,
              suggestions: _suggestions,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat Header ───────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          decoration: BoxDecoration(
            color: AppTheme.bgDeep.withOpacity(0.8),
            border: const Border(
              bottom: BorderSide(color: AppTheme.border, width: 1)),
          ),
          child: Row(
            children: [
              // AI Orb
              Stack(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accentCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: const Center(
                      child: Text('◈',
                        style: TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(-3),
                      child: _OrbRingAnimation(),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Life OS · AI',
                      style: AppTheme.headlineMedium.copyWith(fontSize: 16)),
                    Row(
                      children: const [
                        PulseDot(size: 5),
                        SizedBox(width: 5),
                        Text('Online · Context-aware',
                          style: TextStyle(
                            fontFamily: 'DMSans', fontSize: 11,
                            color: AppTheme.green, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              WaveformWidget(color: AppTheme.textMuted, bars: 5, height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbRingAnimation extends StatefulWidget {
  @override
  State<_OrbRingAnimation> createState() => _OrbRingAnimationState();
}

class _OrbRingAnimationState extends State<_OrbRingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        painter: _RingPainter(opacity: 0.3 + 0.3 * _anim.value),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double opacity;
  _RingPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()
        ..color = AppTheme.accent.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override bool shouldRepaint(covariant _RingPainter old) => old.opacity != opacity;
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 28, height: 28,
              margin: const EdgeInsets.only(right: 8, bottom: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accent, AppTheme.accentCyan]),
              ),
              child: const Center(
                child: Text('◈',
                  style: TextStyle(color: Colors.white, fontSize: 12))),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.76),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppTheme.accentGradient : null,
                    color: isUser ? null : AppTheme.surface2,
                    border: isUser ? null
                        : Border.all(color: AppTheme.border, width: 1),
                    borderRadius: BorderRadius.only(
                      topLeft:     const Radius.circular(18),
                      topRight:    const Radius.circular(18),
                      bottomLeft:  isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    boxShadow: isUser ? [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.25),
                        blurRadius: 20, offset: const Offset(0, 4)),
                    ] : null,
                  ),
                  child: message.isStreaming && message.content.isEmpty
                      ? const _TypingIndicator()
                      : Text(
                          message.content,
                          style: AppTheme.bodyMedium.copyWith(
                            color: isUser ? Colors.white : AppTheme.textPrimary)),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: AppTheme.caption.copyWith(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2,'0');
    final m = t.minute.toString().padLeft(2,'0');
    return '$h:$m';
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (_ctrl.value - i * 0.15).clamp(0.0, 1.0);
          final y = -4 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
          return Transform.translate(
            offset: Offset(0, y),
            child: Container(
              width: 7, height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentSoft.withOpacity(0.6 + 0.4 * (1 - phase)),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Chat Input Area ───────────────────────────────────────────────────────────

class _ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Future<void> Function([String?]) onSend;
  final List<String> suggestions;

  const _ChatInputArea({
    required this.controller,
    required this.isLoading,
    required this.onSend,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 10,
            bottom: MediaQuery.of(context).padding.bottom + 80,
          ),
          decoration: BoxDecoration(
            color: AppTheme.bgDeep.withOpacity(0.9),
            border: const Border(
              top: BorderSide(color: AppTheme.border, width: 1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Suggestion chips
              SizedBox(
                height: 34,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: suggestions.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => onSend(suggestions[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          border: Border.all(color: AppTheme.border, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(suggestions[i],
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary, fontSize: 12)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Input row
              Row(
                children: [
                  // Voice button
                  _CircleButton(
                    child: const Icon(Icons.mic_none, size: 20,
                        color: AppTheme.textSecondary),
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),

                  // Text input
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppTheme.surface2,
                        border: Border.all(color: AppTheme.border, width: 1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: controller,
                        style: AppTheme.bodyMedium.copyWith(fontSize: 14),
                        textAlignVertical: TextAlignVertical.center,
                        maxLines: 1,
                        onSubmitted: (_) => onSend(),
                        decoration: InputDecoration(
                          hintText: 'Ask your AI CEO anything…',
                          hintStyle: AppTheme.bodyMedium.copyWith(
                            fontSize: 14, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Send button
                  _CircleButton(
                    gradient: AppTheme.accentGradient,
                    shadow: AppTheme.glowShadow,
                    onTap: () => onSend(),
                    child: isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                        : Transform.rotate(
                            angle: -0.3,
                            child: const Icon(Icons.send_rounded,
                                size: 18, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;
  final VoidCallback? onTap;

  const _CircleButton({
    required this.child,
    this.gradient,
    this.shadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          color: gradient == null ? AppTheme.surface2 : null,
          border: gradient == null
              ? Border.all(color: AppTheme.border, width: 1)
              : null,
          boxShadow: shadow,
        ),
        child: Center(child: child),
      ),
    );
  }
}
