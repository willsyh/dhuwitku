import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/home_shell.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/festive_theme.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/async_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../budgets/presentation/budget_progress.dart';
import '../../assistant/presentation/cloud_mascot.dart';
import '../../../l10n/l10n.dart';
import '../../budgets/presentation/budget_providers.dart';
import '../../receipt_scan/presentation/receipt_scan_flow.dart';
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
    final l = context.l10n;
    final async = ref.watch(dashboardProvider);
    final money = ref.watch(moneyFormatterProvider);
    final hasDemo = ref.watch(hasDemoDataProvider);
    final festive = ref.watch(festiveThemeProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(error: e, onRetry: () => ref.invalidate(transactionsProvider)),
          data: (d) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            children: [
              _Header(festive: festive, onScan: () => startReceiptScan(context, ref)),
              const SizedBox(height: 14),
              const _AssistantBar(),
              const SizedBox(height: 16),
              if (hasDemo) ...[
                _DemoBanner(
                  onRemove: () async {
                    final n = await ref.read(transactionRepositoryProvider).deleteDemoData();
                    showAppSnack(l.demoRemoved(n));
                  },
                ),
                const SizedBox(height: 12),
              ],
              _BalanceCard(summary: d, money: money, festive: festive),
              const SizedBox(height: 16),
              _QuickActions(),
              if (d.budgetAlerts.isNotEmpty) ...[
                const SizedBox(height: 20),
                SectionHeader(
                  title: l.dashBudgetAlerts,
                  actionLabel: l.manage,
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
              SectionHeader(title: l.dashMonthlySummary),
              _MonthlyOverview(summary: d, money: money),
              const SizedBox(height: 20),
              SectionHeader(
                title: l.dashRecent,
                actionLabel: d.recent.isEmpty ? null : l.seeAll,
                onAction: () => ref.read(homeTabProvider.notifier).select(HomeTab.transactions),
              ),
              if (d.recent.isEmpty)
                AppCard(
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l.noTransactionsYet,
                    message: l.dashEmptyMessage,
                    action: FilledButton.icon(
                      onPressed: () => showQuickAddSheet(context),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l.recordNow),
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
  const _Header({required this.festive, required this.onScan});
  final FestiveTheme festive;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? l.greetingMorning
        : hour < 15
        ? l.greetingAfternoon
        : hour < 19
        ? l.greetingEvening
        : l.greetingNight;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festive.isActive ? festive.greeting : greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  festive.isActive
                      ? '${festive.subtitle} · ${DateFormats.date.format(DateTime.now())}'
                      : DateFormats.dayDate.format(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (festive.isActive) ...[
            const SizedBox(width: 12),
            ExcludeSemantics(
              child: CategoryAvatar(icon: festive.icon, color: theme.colorScheme.primary, size: 44),
            ),
          ],
          const SizedBox(width: 10),
          // Scan a receipt into a new transaction.
          IconButton.filledTonal(
            tooltip: l.scanReceipt,
            onPressed: onScan,
            iconSize: 24,
            style: IconButton.styleFrom(
              fixedSize: const Size(48, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.document_scanner_outlined),
          ),
        ],
      ),
    );
  }
}

/// Opens the offline assistant ("Tanya atau catat...").
class _AssistantBar extends StatelessWidget {
  const _AssistantBar();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      onTap: () => Navigator.pushNamed(context, AppRoutes.assistant),
      child: Row(
        children: [
          const CloudMascot(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.assistantBarTitle,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  l.assistantBarHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
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
    final l = context.l10n;
    return AppCard(
      color: AppColors.warning.withValues(alpha: 0.12),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(child: Text(l.demoActive)),
          TextButton(onPressed: onRemove, child: Text(l.delete)),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.summary, required this.money, required this.festive});
  final FestiveTheme festive;
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Festive banner behind the figures, darkened (more on the left
          // where the text is, and at the bottom) so white text stays readable.
          if (festive.bannerAsset case final banner?) ...[
            Positioned.fill(
              child: Image.asset(
                banner,
                fit: BoxFit.cover,
                alignment: festive.bannerAlignment,
                gaplessPlayback: true,
                // Undecodable asset -> plain theme color (the card's own color).
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: (0.62 + festive.bannerDim).clamp(0, 0.85)),
                      Colors.black.withValues(alpha: (0.22 + festive.bannerDim).clamp(0, 0.85)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.45, 1],
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                  ),
                ),
              ),
            ),
          ],
          Padding(padding: const EdgeInsets.all(20), child: _content(context, theme, budget, stat)),
        ],
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ThemeData theme,
    BudgetStatus? budget,
    Widget Function(String, int, IconData) stat,
  ) {
    const onCard = Colors.white;
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.totalBalance, style: const TextStyle(color: Colors.white70)),
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
            stat(l.incomeThisMonth, summary.monthIncome, Icons.south_west_rounded),
            const SizedBox(width: 12),
            stat(l.expenseThisMonth, summary.monthExpense, Icons.north_east_rounded),
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
                ? Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: onCard, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l.setMonthlyBudget,
                          style: const TextStyle(color: onCard, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: onCard),
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
                                  ? l.budgetRemaining(money.format(budget.remaining))
                                  : l.budgetExceededBy(money.format(-budget.remaining)),
                              style: const TextStyle(color: onCard, fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            '${budget.percent}%',
                            style: const TextStyle(color: onCard, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: budget.ratio.clamp(0, 1).toDouble(),
                          minHeight: 6,
                          color: budget.level.needsAttention
                              ? budgetColor(budget.level)
                              : Colors.white,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
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
        action(
          Icons.remove_rounded,
          l.typeExpense,
          AppColors.expense,
          () => showQuickAddSheet(context, type: TransactionType.expense),
        ),
        const SizedBox(width: 10),
        action(
          Icons.add_rounded,
          l.typeIncome,
          AppColors.income,
          () => showQuickAddSheet(context, type: TransactionType.income),
        ),
        const SizedBox(width: 10),
        action(
          Icons.receipt_long_rounded,
          l.history,
          Theme.of(context).colorScheme.primary,
          () => ref.read(homeTabProvider.notifier).select(HomeTab.transactions),
        ),
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
    final l = context.l10n;
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget metric(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    final hasData = summary.lastMonths.any((m) => m.income > 0 || m.expense > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              metric(l.today, money.format(summary.todayExpense)),
              metric(l.avgPerDay, money.format(summary.averageDailyExpense)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              metric(l.topCategory, summary.topCategory?.category.label ?? '-'),
              metric(l.transactionsThisMonth, '${summary.monthCount}'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(l.last6Months, style: theme.textTheme.labelLarge)),
              ChartLegend(
                items: [(l.legendIn, AppColors.income), (l.legendOut, AppColors.expense)],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasData)
            IncomeExpenseBarChart(months: summary.lastMonths, format: money.format, height: 180)
          else
            SizedBox(
              height: 120,
              child: Center(child: Text(l.chartEmpty, style: muted)),
            ),
        ],
      ),
    );
  }
}
