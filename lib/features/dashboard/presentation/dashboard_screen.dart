import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/home_shell.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/async_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../budgets/presentation/budget_progress.dart';
import '../../budgets/presentation/budget_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../statistics/presentation/charts.dart';
import '../../transactions/presentation/quick_add_sheet.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../../transactions/presentation/transaction_tile.dart';
import '../domain/dashboard_summary.dart';

final dashboardProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final now = DateTime.now();
  final txs = ref.watch(transactionsProvider);
  final budgets = ref.watch(budgetStatusesProvider((now.year, now.month)));
  return combineAsync(
    [txs, budgets],
    () => DashboardSummary.compute(
      transactions: txs.requireValue,
      budgetStatuses: budgets.requireValue,
      now: now,
    ),
  );
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final money = ref.watch(moneyFormatterProvider);
    final hasDemo = ref.watch(hasDemoDataProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(transactionsProvider)),
          data: (d) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              _Header(),
              const SizedBox(height: 16),
              if (hasDemo) ...[
                _DemoBanner(onRemove: () async {
                  final n = await ref.read(transactionRepositoryProvider).deleteDemoData();
                  showAppSnack('$n transaksi demo dihapus.');
                }),
                const SizedBox(height: 12),
              ],
              _BalanceCard(summary: d, money: money),
              const SizedBox(height: 16),
              _QuickActions(),
              if (d.budgetAlerts.isNotEmpty) ...[
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Peringatan Anggaran',
                  actionLabel: 'Kelola',
                  onAction: () => Navigator.pushNamed(context, AppRoutes.budgets),
                ),
                for (final s in d.budgetAlerts.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: BudgetStatusCard(
                      status: s,
                      money: money,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.budgets),
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              const SectionHeader(title: 'Ringkasan Bulanan'),
              _MonthlyOverview(summary: d, money: money),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Transaksi Terakhir',
                actionLabel: d.recent.isEmpty ? null : 'Lihat semua',
                onAction: () => ref.read(homeTabProvider.notifier).select(HomeTab.transactions),
              ),
              if (d.recent.isEmpty)
                AppCard(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada transaksi',
                    message: 'Catat pengeluaran pertamamu, hanya butuh beberapa detik.',
                    action: FilledButton.icon(
                      onPressed: () => showQuickAddSheet(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Catat Sekarang'),
                    ),
                  ),
                )
              else
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [for (final t in d.recent) TransactionTile(transaction: t)],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
            ? 'Selamat siang'
            : hour < 19
                ? 'Selamat sore'
                : 'Selamat malam';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(
            DateFormats.dayDate.format(DateTime.now()),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner({required this.onRemove});
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.warning.withValues(alpha: 0.12),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: AppColors.warning),
          const SizedBox(width: 12),
          const Expanded(child: Text('Mode demo aktif: sebagian data adalah contoh.')),
          TextButton(onPressed: onRemove, child: const Text('Hapus')),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.money});
  final DashboardSummary summary;
  final MoneyFormatter money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const onCard = Colors.white;
    final budget = summary.overallBudget;

    Widget stat(String label, int value, IconData icon) => Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: onCard, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        money.format(value),
                        style: const TextStyle(
                          color: onCard,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFeatures: tabularFigures,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              money.format(summary.balance),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: onCard,
                fontWeight: FontWeight.w800,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              stat('Pemasukan bulan ini', summary.monthIncome, Icons.south_west_rounded),
              const SizedBox(width: 12),
              stat('Pengeluaran bulan ini', summary.monthExpense, Icons.north_east_rounded),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.budgets),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: budget == null
                  ? const Row(
                      children: [
                        Icon(Icons.flag_outlined, color: onCard, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Atur anggaran bulanan',
                              style: TextStyle(color: onCard, fontWeight: FontWeight.w600)),
                        ),
                        Icon(Icons.chevron_right_rounded, color: onCard),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                budget.remaining >= 0
                                    ? 'Sisa anggaran ${money.format(budget.remaining)}'
                                    : 'Anggaran terlampaui ${money.format(-budget.remaining)}',
                                style: const TextStyle(color: onCard, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text('${budget.percent}%',
                                style: const TextStyle(color: onCard, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: budget.ratio.clamp(0, 1).toDouble(),
                            minHeight: 6,
                            color: budget.level.needsAttention ? budgetColor(budget.level) : Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget action(IconData icon, String label, Color color, VoidCallback onTap) => Expanded(
          child: AppCard(
            onTap: onTap,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                CategoryAvatar(icon: icon, color: color, size: 40),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        action(Icons.remove_rounded, 'Pengeluaran', AppColors.expense,
            () => showQuickAddSheet(context, type: TransactionType.expense)),
        const SizedBox(width: 10),
        action(Icons.add_rounded, 'Pemasukan', AppColors.income,
            () => showQuickAddSheet(context, type: TransactionType.income)),
        const SizedBox(width: 10),
        action(Icons.receipt_long_rounded, 'Riwayat', AppColors.primary,
            () => ref.read(homeTabProvider.notifier).select(HomeTab.transactions)),
      ],
    );
  }
}

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({required this.summary, required this.money});
  final DashboardSummary summary;
  final MoneyFormatter money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget metric(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: muted),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        );

    final hasData = summary.lastMonths.any((m) => m.income > 0 || m.expense > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            metric('Hari ini', money.format(summary.todayExpense)),
            metric('Rata-rata / hari', money.format(summary.averageDailyExpense)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            metric('Kategori terbesar', summary.topCategory?.category.name ?? '-'),
            metric('Transaksi bulan ini', '${summary.monthCount}'),
          ]),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text('6 bulan terakhir', style: theme.textTheme.labelLarge)),
              const ChartLegend(items: [('Masuk', AppColors.income), ('Keluar', AppColors.expense)]),
            ],
          ),
          const SizedBox(height: 12),
          if (hasData)
            IncomeExpenseBarChart(months: summary.lastMonths, format: money.format, height: 180)
          else
            SizedBox(
              height: 120,
              child: Center(child: Text('Grafik muncul setelah ada transaksi.', style: muted)),
            ),
        ],
      ),
    );
  }
}
