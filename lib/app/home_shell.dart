import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);

    return PopScope(
      canPop: tab == HomeTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(homeTabProvider.notifier).select(HomeTab.home);
      },
      child: Scaffold(
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
          tooltip: 'Catat transaksi',
          onPressed: () => showQuickAddSheet(context, type: TransactionType.expense),
          child: const Icon(Icons.add_rounded, size: 30),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          height: 68,
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              for (final (i, item) in _items.indexed) ...[
                if (i == 2) const SizedBox(width: 72),
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
    );
  }
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(selected ? selectedIcon : icon, key: ValueKey(selected), color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
