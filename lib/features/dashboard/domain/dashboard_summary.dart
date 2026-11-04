import '../../budgets/domain/budget_calculator.dart';
import '../../statistics/domain/statistics_calculator.dart';
import '../../transactions/domain/finance_transaction.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
    required this.monthCount,
    required this.averageDailyExpense,
    required this.overallBudget,
    required this.budgetAlerts,
    required this.recent,
    required this.lastMonths,
    required this.topCategory,
    required this.todayExpense,
  });

  /// All-time income minus all-time expense.
  final int balance;
  final int monthIncome;
  final int monthExpense;
  final int monthCount;
  final int averageDailyExpense;
  final int todayExpense;
  final BudgetStatus? overallBudget;

  /// Budgets at 75% or more this month.
  final List<BudgetStatus> budgetAlerts;
  final List<FinanceTransaction> recent;
  final List<MonthTotal> lastMonths;
  final CategoryTotal? topCategory;

  static DashboardSummary compute({
    required List<FinanceTransaction> transactions,
    required List<BudgetStatus> budgetStatuses,
    required DateTime now,
  }) {
    var balance = 0;
    for (final t in transactions) {
      balance += t.signedAmount;
    }
    final month = Period.of(PeriodType.month, now);
    final summary = StatisticsCalculator.summarize(transactions, month, now: now);
    final today = StatisticsCalculator.summarize(
        transactions, Period.of(PeriodType.day, now), now: now);
    final byCategory = StatisticsCalculator.expenseByCategory(transactions, month);
    final recent = [...transactions]..sort((a, b) {
        final c = b.date.compareTo(a.date);
        return c != 0 ? c : b.id.compareTo(a.id);
      });

    return DashboardSummary(
      balance: balance,
      monthIncome: summary.income,
      monthExpense: summary.expense,
      monthCount: summary.count,
      averageDailyExpense: summary.averageDailyExpense,
      todayExpense: today.expense,
      overallBudget: budgetStatuses.where((s) => s.isOverall).firstOrNull,
      budgetAlerts: budgetStatuses.where((s) => s.level.needsAttention).toList(),
      recent: recent.take(5).toList(),
      lastMonths: StatisticsCalculator.monthlyTotals(transactions, now, 6),
      topCategory: byCategory.firstOrNull,
    );
  }
}
