import '../../../core/utils/formatters.dart';
import '../../../l10n/l10n.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'statistics_calculator.dart';

enum InsightTone { info, positive, warning, negative }

class Insight {
  const Insight(this.message, this.tone);
  final String message;
  final InsightTone tone;

  @override
  String toString() => message;
}

/// Rule-based insights computed from local data only (no AI, no network).
///
/// Month-over-month comparisons use the same number of days in both months
/// (e.g. 1–4 Nov vs 1–4 Oct) so a half-finished month isn't compared against
/// a full one.
abstract final class InsightsGenerator {
  static List<Insight> generate({
    required List<FinanceTransaction> transactions,
    required DateTime month,
    required MoneyFormatter money,
    BudgetStatus? overallBudget,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final current = Period.of(PeriodType.month, month);
    final isCurrentMonth = current.contains(today);
    final l = l10n;
    final monthName =
        isCurrentMonth ? l.insThisMonth : l.insMonthOf(DateFormats.monthYear.format(month));
    final insights = <Insight>[];

    final summary = StatisticsCalculator.summarize(transactions, current, now: today);
    if (summary.count == 0) {
      return [Insight(l.insNoTransactions(monthName), InsightTone.info)];
    }

    // 1. Largest expense category.
    final byCategory = StatisticsCalculator.expenseByCategory(transactions, current);
    if (byCategory.isNotEmpty) {
      final top = byCategory.first;
      insights.add(Insight(
        l.insTopCategory(
            monthName, top.category.label, money.format(top.amount), (top.share * 100).round()),
        InsightTone.info,
      ));
    }

    // Comparable window in the previous month.
    final elapsed = current.elapsedDays(today);
    final thisWindow = Period(PeriodType.month, current.start,
        isCurrentMonth ? DateTime(today.year, today.month, today.day + 1) : current.end);
    final prev = current.previous();
    final prevEnd = isCurrentMonth
        ? _minDate(DateTime(prev.start.year, prev.start.month, elapsed + 1), prev.end)
        : prev.end;
    final prevWindow = Period(PeriodType.month, prev.start, prevEnd);
    final comparison = isCurrentMonth ? l.insCompareSamePeriod : l.insComparePrevMonth;

    // 2. Total expense change.
    final nowExpense = StatisticsCalculator.summarize(transactions, thisWindow, now: today).expense;
    final prevExpense = StatisticsCalculator.summarize(transactions, prevWindow, now: today).expense;
    if (prevExpense > 0 && nowExpense > 0) {
      final change = ((nowExpense - prevExpense) / prevExpense * 100).round();
      if (change.abs() >= 5) {
        insights.add(change > 0
            ? Insight(l.insTotalUp(change, comparison), InsightTone.warning)
            : Insight(l.insTotalDown(change.abs(), comparison), InsightTone.positive));
      }
    }

    // 3. Category with the biggest increase.
    final prevByCategory = {
      for (final c in StatisticsCalculator.expenseByCategory(transactions, prevWindow))
        c.category.id: c.amount,
    };
    CategoryTotal? biggest;
    var biggestChange = 0;
    for (final c in StatisticsCalculator.expenseByCategory(transactions, thisWindow)) {
      final before = prevByCategory[c.category.id] ?? 0;
      if (before <= 0) continue;
      final change = ((c.amount - before) / before * 100).round();
      if (change > biggestChange) {
        biggestChange = change;
        biggest = c;
      }
    }
    if (biggest != null && biggestChange >= 10) {
      insights.add(Insight(
        l.insCategoryUp(biggest.category.label, biggestChange, comparison),
        InsightTone.warning,
      ));
    }

    // 4. Budget usage and projection.
    if (overallBudget != null) {
      final b = overallBudget;
      final tone = switch (b.level) {
        BudgetLevel.safe => InsightTone.positive,
        BudgetLevel.caution => InsightTone.warning,
        _ => InsightTone.negative,
      };
      insights.add(Insight(
        b.level == BudgetLevel.exceeded
            ? l.insBudgetExceeded(money.format(-b.remaining))
            : l.insBudgetUsed(b.percent),
        tone,
      ));
      if (isCurrentMonth && elapsed > 0 && elapsed < current.dayCount && b.level != BudgetLevel.exceeded) {
        final projected = (summary.expense / elapsed * current.dayCount).round();
        if (projected > b.limit) {
          insights.add(Insight(
            l.insProjection(money.format(projected)),
            InsightTone.warning,
          ));
        }
      }
    }

    // 5. Saving rate.
    if (summary.income > 0) {
      final rate = (summary.net / summary.income * 100).round();
      insights.add(rate >= 0
          ? Insight(l.insSavingRate(rate, monthName),
              rate >= 20 ? InsightTone.positive : InsightTone.info)
          : Insight(l.insOverspend(monthName, money.format(-summary.net)), InsightTone.negative));
    }

    // 6. Most frequent category.
    final frequent = [...byCategory]..sort((a, b) => b.count.compareTo(a.count));
    if (frequent.isNotEmpty && frequent.first.count >= 3) {
      final f = frequent.first;
      insights.add(Insight(
        l.insMostFrequent(
            f.category.label, f.count, monthName, money.format((f.amount / f.count).round())),
        InsightTone.info,
      ));
    }

    // 7. Average daily spending.
    if (summary.averageDailyExpense > 0) {
      insights.add(Insight(
        l.insAvgDaily(monthName, money.format(summary.averageDailyExpense)),
        InsightTone.info,
      ));
    }

    return insights;
  }

  static DateTime _minDate(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
