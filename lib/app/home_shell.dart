import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/transaction_type.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/statistics/presentation/statistics_screen.dart';
import '../features/transactions/presentation/quick_add_sheet.dart';
import '../features/transactions/presentation/transactions_screen.dart';
import '../l10n/l10n.dart';

enum HomeTab { home, transactions, statistics, settings }

class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.home;
  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTab>(HomeTabNotifier.new);

/// Bar geometry. The FAB (56) is docked on the bar's top edge and sits in a
/// curved notch of radius [_fabRadius] + [_notchMargin].
const double _barHeight = 64;
const double _barRadius = 32;
const double _fabRadius = 28;
const double _notchMargin = 7;

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _items = [
    (HomeTab.home, Icons.home_outlined, Icons.home_rounded),
    (HomeTab.transactions, Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    (HomeTab.statistics, Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded),
    (HomeTab.settings, Icons.settings_outlined, Icons.settings_rounded),
  ];

  /// Near-black floating bar in light mode; a lifted surface in dark mode so it
  /// still stands out against the dark background.
  static Color barColor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1E2639) : const Color(0xFF111827);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final theme = Theme.of(context);
    final l = context.l10n;
    final labels = [l.navHome, l.navTransactions, l.navStatistics, l.navSettings];

    Widget item(int i) {
      final it = _items[i];
      return _NavItem(
        icon: it.$2,
        selectedIcon: it.$3,
        label: labels[i],
        selected: tab == it.$1,
        onTap: () => ref.read(homeTabProvider.notifier).select(it.$1),
      );
    }

    // One half of the bar. The selected item takes more of the half; the
    // flex weights are animated so the width change is smooth.
    Widget side(int a, int b) {
      final target = Offset(tab == _items[a].$1 ? 1 : 0, tab == _items[b].$1 ? 1 : 0);
      return Expanded(
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(end: target),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, w, _) => Row(
            children: [
              Expanded(flex: (100 + 120 * w.dx).round(), child: item(a)),
              Expanded(flex: (100 + 120 * w.dy).round(), child: item(b)),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: tab == HomeTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(homeTabProvider.notifier).select(HomeTab.home);
      },
      child: Scaffold(
        // Content scrolls behind the floating bar (screens keep ~100px of
        // bottom padding so the last items stay reachable).
        extendBody: true,
        body: IndexedStack(
          index: tab.index,
          children: const [
            DashboardScreen(),
            TransactionsScreen(),
            StatisticsScreen(),
            SettingsScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: l.addTransactionTooltip,
          elevation: 4,
          onPressed: () => showQuickAddSheet(context, type: TransactionType.expense),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
        // Centers the FAB on the bar's top edge, i.e. inside the notch.
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: PhysicalShape(
                  clipper: const _NotchedBarClipper(),
                  color: barColor(theme.brightness),
                  elevation: 10,
                  shadowColor: Colors.black.withValues(alpha: 0.5),
                  child: SizedBox(
                    height: _barHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          side(0, 1),
                          // Narrower than the notch's top opening: the pills sit lower, where
                          // the curve is narrower.
                          const SizedBox(width: 60),
                          side(2, 3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded "stadium" bar with a smooth circular notch in the top center, so
/// the + button sits in its own curve instead of merging with the bar.
class _NotchedBarClipper extends CustomClipper<Path> {
  const _NotchedBarClipper();

  @override
  Path getClip(Size size) {
    final host = Offset.zero & size;
    final guest = Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: _fabRadius + _notchMargin,
    );
    // CircularNotchedRectangle gives the notch smooth shoulders; intersecting
    // with a rounded rect gives the bar its rounded ends.
    final notched = const CircularNotchedRectangle().getOuterPath(host, guest);
    final rounded = Path()
      ..addRRect(RRect.fromRectAndRadius(host, const Radius.circular(_barRadius)));
    return Path.combine(PathOperation.intersect, notched, rounded);
  }

  @override
  bool shouldReclip(_NotchedBarClipper oldClipper) => false;
}

/// Nav item. The selected one grows into a pill showing the icon and its name
/// side by side; others show only the icon (name on long-press tooltip).
class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeOutCubic;

  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    // The bar is always dark. Lighten the theme color a little so darker
    // festive colors stay visible on it.
    final accent = Color.lerp(scheme.primary, Colors.white, 0.2)!;
    final iconColor = selected ? accent : Colors.white.withValues(alpha: 0.62);

    final pillColor = selected
        ? accent.withValues(alpha: 0.2)
        : _hovered || _pressed
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0);

    return Tooltip(
      message: widget.label,
      excludeFromSemantics: true,
      child: Semantics(
        selected: selected,
        button: true,
        label: widget.label,
        excludeSemantics: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          // Hover only makes sense for a real mouse; touch has no hover state.
          onEnter: (e) {
            if (e.kind == PointerDeviceKind.mouse) setState(() => _hovered = true);
          },
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: () {
              if (!selected) HapticFeedback.selectionClick();
              widget.onTap();
            },
            child: Center(
              child: AnimatedScale(
                scale: _pressed ? 0.92 : 1,
                duration: const Duration(milliseconds: 120),
                child: AnimatedContainer(
                  duration: _duration,
                  curve: _curve,
                  height: 42,
                  padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 9),
                  decoration: BoxDecoration(
                    color: pillColor,
                    borderRadius: BorderRadius.circular(21),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          selected ? widget.selectedIcon : widget.icon,
                          key: ValueKey(selected),
                          color: iconColor,
                          size: 22,
                        ),
                      ),
                      // Name slides out next to the icon when selected.
                      Flexible(
                        child: AnimatedSize(
                          duration: _duration,
                          curve: _curve,
                          child: selected
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      widget.label,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
