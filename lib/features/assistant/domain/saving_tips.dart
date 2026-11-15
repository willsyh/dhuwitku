import '../../../core/utils/formatters.dart';
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
      tips.add('${c.category.name} ${c.count}× bulan ini (${money.format(c.amount)}, rata-rata '
          '${money.format(avg)}). Kurangi 2× seminggu ≈ hemat ${money.format(saving)}/bulan.');
    }

    // 2. One category dominating.
    final top = byCat.first;
    if (top.share >= 0.35 && byCat.length > 1) {
      final saving = (top.amount * 0.1).round();
      tips.add('${top.category.name} menyerap ${(top.share * 100).round()}% pengeluaranmu bulan ini. '
          'Turunkan 10% ≈ hemat ${money.format(saving)}.');
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
      tips.add('Anggaran ${tight.label} sudah ${tight.percent}% terpakai. '
          'Tahan dulu pengeluaran ${tight.label} sampai akhir bulan.');
    }

    // 5. No budget yet.
    if (overall == null) {
      tips.add('Kamu belum punya anggaran bulanan. Atur di menu Anggaran supaya dapat peringatan '
          'otomatis saat pengeluaran mendekati batas.');
    }

    return tips.take(4).toList();
  }
}
