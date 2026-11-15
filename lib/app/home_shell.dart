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

enum HomeTab { home, transactions, statistics, settings }

class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.home;
  void select(HomeTab tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTab>(HomeTabNotifier.new);

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _items = [
    (HomeTab.home, Icons.home_outlined, Icons.home_rounded, 'Beranda'),
    (HomeTab.transactions, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Transaksi'),
    (HomeTab.statistics, Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded, 'Statistik'),
    (HomeTab.settings, Icons.settings_outlined, Icons.settings_rounded, 'Pengaturan'),
  ];

  /// Near-black floating bar in light mode; a lifted surface in dark mode so it
  /// still stands out against the dark background.
  static Color barColor(Brightness b) =>
      b == Brightness.dark ? const Color(0xFF1E2639) : const Color(0xFF111827);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    final theme = Theme.of(context);
    final bar = barColor(theme.brightness);

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
        // Sits centered on the bar's top edge; the ring in the bar color makes
        // it look cut into the bar.
        floatingActionButton: FloatingActionButton(
          tooltip: 'Catat transaksi',
          elevation: 2,
          shape: CircleBorder(side: BorderSide(color: bar, width: 5)),
          onPressed: () => showQuickAddSheet(context, type: TransactionType.expense),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.only(bottom: 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: bar,
                    borderRadius: BorderRadius.circular(26),
                    border: theme.brightness == Brightness.dark
                        ? Border.all(color: Colors.white.withValues(alpha: 0.06))
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      for (final (i, item) in _items.indexed) ...[
                        if (i == 2) const SizedBox(width: 68),
                        Expanded(
                          child: _NavItem(
                            icon: item.$2,
                            selectedIcon: item.$3,
                            label: item.$4,
                            selected: tab == item.$1,
                            onTap: () => ref.read(homeTabProvider.notifier).select(item.$1),
                          ),
                        ),
                      ],
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

/// Bottom-nav item. The selected one lifts up with a tinted pill behind its
/// icon; pressing shrinks it slightly, and a mouse hover shows a faint pill.
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
  static const _duration = Duration(milliseconds: 320);
  static const _lift = Curves.easeOutBack;

  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    // The bar is always dark, so colors are tuned for a dark background.
    // Lighten the theme color a little so darker festive colors stay visible.
    final accent = Color.lerp(scheme.primary, Colors.white, 0.18)!;
    final iconColor = selected ? accent : Colors.white.withValues(alpha: 0.6);
    final labelColor = selected ? Colors.white : Colors.white.withValues(alpha: 0.6);

    final pillColor = selected
        ? accent.withValues(alpha: 0.18)
        : _hovered || _pressed
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0);

    return Semantics(
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
          child: AnimatedSlide(
            // Lift the selected tab ~6px upward.
            offset: Offset(0, selected ? -0.12 : 0),
            duration: _duration,
            curve: _lift,
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: _duration,
                    curve: Curves.easeOutCubic,
                    width: selected ? 56 : 44,
                    height: 30,
                    decoration: BoxDecoration(
                      color: pillColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: AnimatedSwitcher(
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
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: _duration,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: labelColor,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    child: Text(widget.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
