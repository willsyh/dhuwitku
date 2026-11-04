import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../budgets/presentation/budget_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../domain/insights_generator.dart';
import '../domain/statistics_calculator.dart';
import 'charts.dart';

class StatsPeriodNotifier extends Notifier<Period> {
  @override
  Period build() => Period.of(PeriodType.month, DateTime.now());

  void setType(PeriodType type) {
    final now = DateTime.now();
    // Keep the anchor inside the current view; prefer today when it's visible.
    final anchor = state.contains(now) ? now : state.start;
    state = Period.of(type, anchor);
  }

  void shift(int steps) => state = state.shift(steps);
}

final statsPeriodProvider = NotifierProvider<StatsPeriodNotifier, Period>(StatsPeriodNotifier.new);

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final txAsync = ref.watch(transactionsProvider);
    final money = ref.watch(moneyFormatterProvider);
    final now = DateTime.now();
    // Only allow moving forward into periods that have already started.
    final canGoNext = !period.end.isAfter(now);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: txAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e),
        data: (txs) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<PeriodType>(
                showSelectedIcon: false,
                segments: [
                  for (final t in PeriodType.values)
                    ButtonSegment(value: t, label: Text(t.label, style: const TextStyle(fontSize: 12.5))),
                ],
                selected: {period.type},
                onSelectionChanged: (s) => ref.read(statsPeriodProvider.notifier).setType(s.first),
              ),
            ),
            const SizedBox(height: 4),
            PeriodSwitcher(
              label: period.label,
              onPrevious: () => ref.read(statsPeriodProvider.notifier).shift(-1),
              onNext: canGoNext ? () => ref.read(statsPeriodProvider.notifier).shift(1) : null,
            ),
            if (txs.isEmpty)
              const AppCard(
                child: EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'Belum ada data',
                  message: 'Statistik dan insight akan muncul setelah kamu mencatat transaksi.',
                ),
              )
            else
              ..._content(context, ref, txs, period, money, now),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    List<FinanceTransaction> txs,
    Period period,
    MoneyFormatter money,
    DateTime now,
  ) {
    final theme = Theme.of(context);
    final summary = StatisticsCalculator.summarize(txs, period, now: now);
    final byCategory = StatisticsCalculator.expenseByCategory(txs, period);
    final lastDay = period.end.subtract(const Duration(days: 1));
    final refMonth = period.contains(now) ? now : lastDay;
    final monthStatuses =
        ref.watch(budgetStatusesProvider((refMonth.year, refMonth.month))).value ?? const [];
    final insights = InsightsGenerator.generate(
      transactions: txs,
      month: DateTime(refMonth.year, refMonth.month),
      money: money,
      overallBudget: monthStatuses.where((s) => s.isOverall).firstOrNull,
      now: now,
    );

    // Spending trend appropriate for the selected period.
    final (String trendTitle, List<DayTotal> trend, String Function(DateTime) trendLabel, int every) =
        switch (period.type) {
      PeriodType.day => (
          'Pengeluaran 7 hari terakhir',
          StatisticsCalculator.dailyExpenses(
              txs, period.start.subtract(const Duration(days: 6)), period.end),
          (d) => DateFormats.dayMonth.format(d),
          2,
        ),
      PeriodType.week => (
          'Pengeluaran harian minggu ini',
          StatisticsCalculator.dailyExpenses(txs, period.start, period.end),
          (d) => DateFormats.dayMonth.format(d),
          2,
        ),
      PeriodType.month => (
          'Tren pengeluaran harian',
          StatisticsCalculator.dailyExpenses(txs, period.start, period.end),
          (d) => '${d.day}',
          5,
        ),
      PeriodType.year => (
          'Pengeluaran per bulan',
          StatisticsCalculator.monthlyExpensesOfYear(txs, period.start.year),
          (d) => DateFormats.shortMonth.format(d),
          2,
        ),
    };
    final monthly12 = StatisticsCalculator.monthlyTotals(txs, refMonth, 12);
    final last6 = monthly12.sublist(6);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget metric(String label, String value, {Color? color}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: muted),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFeatures: tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        );

    return [
      AppCard(
        child: Column(
          children: [
            Row(children: [
              metric('Pengeluaran', money.format(summary.expense), color: AppColors.expense),
              const SizedBox(width: 12),
              metric('Pemasukan', money.format(summary.income), color: AppColors.income),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              metric('Selisih', money.format(summary.net),
                  color: summary.net >= 0 ? AppColors.income : AppColors.expense),
              const SizedBox(width: 12),
              metric(
                period.type == PeriodType.day ? 'Transaksi' : 'Rata-rata / hari',
                period.type == PeriodType.day
                    ? '${summary.count}'
                    : money.format(summary.averageDailyExpense),
              ),
            ]),
          ],
        ),
      ),
      const SizedBox(height: 20),
      SectionHeader(title: 'Insight ${DateFormats.monthYear.format(refMonth)}'),
      AppCard(
        child: Column(
          children: [
            for (final (i, insight) in insights.indexed) ...[
              if (i > 0) const Divider(height: 20),
              _InsightRow(insight: insight),
            ],
          ],
        ),
      ),
      const SizedBox(height: 20),
      SectionHeader(title: trendTitle),
      AppCard(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
        child: TrendLineChart(
          values: [for (final d in trend) d.amount],
          labelFor: (i) => trendLabel(trend[i].day),
          format: money.format,
          labelEvery: every,
        ),
      ),
      const SizedBox(height: 20),
      const SectionHeader(title: 'Pengeluaran per Kategori'),
      AppCard(
        child: byCategory.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Tidak ada pengeluaran pada periode ini.', style: muted)),
              )
            : CategoryDonutChart(totals: byCategory, format: money.format),
      ),
      const SizedBox(height: 20),
      const SectionHeader(title: 'Pemasukan vs Pengeluaran'),
      AppCard(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ChartLegend(items: [('Masuk', AppColors.income), ('Keluar', AppColors.expense)]),
            const SizedBox(height: 12),
            IncomeExpenseBarChart(months: last6, format: money.format),
          ],
        ),
      ),
      const SizedBox(height: 20),
      const SectionHeader(title: 'Tren Pengeluaran Bulanan'),
      AppCard(
        padding: const EdgeInsets.fromLTRB(8, 20, 16, 8),
        child: TrendLineChart(
          values: [for (final m in monthly12) m.expense],
          labelFor: (i) => DateFormats.shortMonth.format(monthly12[i].month),
          format: money.format,
          color: AppColors.primary,
          labelEvery: 2,
        ),
      ),
    ];
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});
  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (insight.tone) {
      InsightTone.info => (Icons.lightbulb_outline_rounded, AppColors.primary),
      InsightTone.positive => (Icons.thumb_up_alt_outlined, AppColors.income),
      InsightTone.warning => (Icons.trending_up_rounded, AppColors.warning),
      InsightTone.negative => (Icons.warning_amber_rounded, AppColors.expense),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CategoryAvatar(icon: icon, color: color, size: 34),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(insight.message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
