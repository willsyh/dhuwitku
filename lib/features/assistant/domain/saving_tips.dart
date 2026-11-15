import '../../../core/utils/formatters.dart';
import '../../../l10n/l10n.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../statistics/domain/insights_generator.dart';
import '../../statistics/domain/statistics_calculator.dart';
import 'assistant_engine.dart';

/// Rule-based saving tips computed from the user's own data (no AI).
abstract final class SavingTips {
  /// Weeks per month, for "cut N times a week" estimates.
  static const _weeksPerMonth = 30 / 7;

  static List<String> generate(AssistantData d, MoneyFormatter money) {
    final month = Period.of(PeriodType.month, d.now);
    final byCat = StatisticsCalculator.expenseByCategory(d.transactions, month);
    if (byCat.isEmpty) return const [];

    final tips = <String>[];

    // 1. Frequent small purchases add up.
    final frequent = byCat.where((c) => c.count >= 6 && c.amount / c.count <= 60000).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    if (frequent.isNotEmpty) {
      final c = frequent.first;
      final avg = (c.amount / c.count).round();
      final saving = (avg * 2 * _weeksPerMonth).round();
      tips.add(l10n.tipFrequent(c.category.label, c.count, money.format(c.amount),
          money.format(avg), money.format(saving)));
    }

    // 2. One category dominating.
    final top = byCat.first;
    if (top.share >= 0.35 && byCat.length > 1) {
      final saving = (top.amount * 0.1).round();
      tips.add(l10n.tipDominant(top.category.label, (top.share * 100).round(), money.format(saving)));
    }

    // 3. Warnings from the regular insights (increases, budget pace, overspending).
    final statuses = BudgetCalculator.statuses(
      budgets: d.budgets,
      categories: d.categories,
      transactions: d.transactions,
      year: d.now.year,
      month: d.now.month,
    );
    final overall = statuses.where((s) => s.isOverall).firstOrNull;
    final insights = InsightsGenerator.generate(
      transactions: d.transactions,
      month: DateTime(d.now.year, d.now.month),
      money: money,
      overallBudget: overall,
      now: d.now,
    );
    tips.addAll(insights
        .where((i) => i.tone == InsightTone.warning || i.tone == InsightTone.negative)
        .map((i) => i.message)
        .take(2));

    // 4. Category budgets already under pressure.
    final tight = statuses.where((s) => !s.isOverall && s.level.needsAttention).firstOrNull;
    if (tight != null) {
      tips.add(l10n.tipTightBudget(tight.label, tight.percent));
    }

    // 5. No budget yet.
    if (overall == null) {
      tips.add(l10n.tipNoBudget);
    }

    return tips.take(4).toList();
  }
}
