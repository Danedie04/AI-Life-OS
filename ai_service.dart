import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      extendBody: true,
      body: Stack(
        children: [
          // Ambient glows
          const _AmbientGlow(),
          // Main content
          child,
          // Nav bar
          const Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomNavBar(),
          ),
        ],
      ),
    );
  }
}

// ── Ambient Glow Background ──────────────────────────────────────────────────

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.2,
          left: -size.width * 0.2,
          child: Container(
            width: size.width * 1.2,
            height: size.width * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accent.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.1,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentCyan.withOpacity(0.07),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  static const _items = [
    _NavItem(label: 'Home',   icon: '⌂',  route: AppRouter.home),
    _NavItem(label: 'AI',     icon: '◈',  route: AppRouter.chat),
    _NavItem(label: 'Memory', icon: '◉',  route: AppRouter.memory),
    _NavItem(label: 'Tasks',  icon: '◫',  route: AppRouter.tasks),
  ];

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusNav),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xD90D0D1A),
                borderRadius: BorderRadius.circular(AppTheme.radiusNav),
                border: Border.all(color: AppTheme.border2, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: _items.map((item) {
                  final isActive = item.route == '/'
                      ? currentRoute == '/'
                      : currentRoute.startsWith(item.route);
                  return Expanded(
                    child: _NavButton(item: item, isActive: isActive),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String icon;
  final String route;
  const _NavItem({required this.label, required this.icon, required this.route});
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  const _NavButton({required this.item, required this.isActive});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 1.25)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    if (widget.isActive) _ctrl.forward();
  }

  @override
  void didUpdateWidget(covariant _NavButton old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) _ctrl.forward();
    else if (!widget.isActive && old.isActive) _ctrl.reverse();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(widget.item.route),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppTheme.animFast,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isActive
              ? AppTheme.accent.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scale,
              child: Text(
                widget.item.icon,
                style: TextStyle(
                  fontSize: widget.isActive ? 20 : 18,
                  color: widget.isActive ? AppTheme.accentSoft : AppTheme.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 3),
            if (widget.isActive)
              Container(
                width: 4, height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent,
                  boxShadow: [BoxShadow(color: AppTheme.accent, blurRadius: 6)],
                ),
              )
            else
              Text(
                widget.item.label,
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
