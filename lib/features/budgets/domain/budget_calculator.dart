import '../../../core/constants/transaction_type.dart';
import '../../categories/domain/category.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'budget.dart';

enum BudgetLevel {
  /// Below 75%.
  safe,

  /// 75% or more.
  caution,

  /// 90% or more (including exactly 100%).
  danger,

  /// Over 100%.
  exceeded;

  bool get needsAttention => this != BudgetLevel.safe;
}

class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.category,
    required this.spent,
  });

  final Budget budget;

  /// Null for the overall budget.
  final Category? category;
  final int spent;

  int get limit => budget.amount;
  int get remaining => limit - spent;
  bool get isOverall => category == null;
  String get label => category?.name ?? 'Anggaran Bulanan';

  /// Spent / limit. Can exceed 1.
  double get ratio => limit <= 0 ? 0 : spent / limit;
  int get percent => (ratio * 100).floor();

  BudgetLevel get level => levelFor(ratio);

  static BudgetLevel levelFor(double ratio) {
    if (ratio > 1.0) return BudgetLevel.exceeded;
    if (ratio >= 0.9) return BudgetLevel.danger;
    if (ratio >= 0.75) return BudgetLevel.caution;
    return BudgetLevel.safe;
  }

  /// Indonesian warning message, or null when spending is below 75%.
  String? get warningMessage => switch (level) {
        BudgetLevel.safe => null,
        BudgetLevel.caution => '$label sudah terpakai $percent%.',
        BudgetLevel.danger => '$label hampir habis ($percent%).',
        BudgetLevel.exceeded => '$label terlampaui $percent%!',
      };
}

abstract final class BudgetCalculator {
  /// For each category (null = overall), the budget row that applies to
  /// [year]/[month]: the latest one set on or before that month. A row with
  /// amount 0 means the budget was switched off, so it's omitted.
  static Map<int?, Budget> effectiveBudgets(List<Budget> all, int year, int month) {
    final target = monthKeyOf(year, month);
    final latest = <int?, Budget>{};
    for (final b in all) {
      if (b.monthKey > target) continue;
      final current = latest[b.categoryId];
      if (current == null || b.monthKey > current.monthKey) latest[b.categoryId] = b;
    }
    latest.removeWhere((_, b) => b.amount <= 0);
    return latest;
  }

  /// Expense totals for [year]/[month], keyed by category id.
  static Map<int, int> expensesByCategory(
    Iterable<FinanceTransaction> txs,
    int year,
    int month,
  ) {
    final result = <int, int>{};
    for (final t in txs) {
      if (t.type != TransactionType.expense) continue;
      if (t.date.year != year || t.date.month != month) continue;
      result.update(t.category.id, (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    return result;
  }

  /// Overall status first (if set), then category budgets sorted by usage.
  static List<BudgetStatus> statuses({
    required List<Budget> budgets,
    required List<Category> categories,
    required Iterable<FinanceTransaction> transactions,
    required int year,
    required int month,
  }) {
    final effective = effectiveBudgets(budgets, year, month);
    final spentByCategory = expensesByCategory(transactions, year, month);
    final totalSpent = spentByCategory.values.fold<int>(0, (a, b) => a + b);
    final byId = {for (final c in categories) c.id: c};

    final result = <BudgetStatus>[];
    final overall = effective[null];
    if (overall != null) {
      result.add(BudgetStatus(budget: overall, category: null, spent: totalSpent));
    }
    final categoryStatuses = <BudgetStatus>[];
    for (final entry in effective.entries) {
      final id = entry.key;
      if (id == null) continue;
      final category = byId[id];
      if (category == null || category.type != TransactionType.expense) continue;
      categoryStatuses.add(BudgetStatus(
        budget: entry.value,
        category: category,
        spent: spentByCategory[id] ?? 0,
      ));
    }
    categoryStatuses.sort((a, b) => b.ratio.compareTo(a.ratio));
    return result..addAll(categoryStatuses);
  }
}
