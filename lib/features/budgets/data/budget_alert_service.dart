import '../../../core/constants/transaction_type.dart';
import '../../transactions/data/transaction_repository.dart';
import '../domain/budget_calculator.dart';
import 'budget_repository.dart';

/// Checks budgets straight from the database right after a save, so the
/// warning reflects the transaction that was just written.
class BudgetAlertService {
  BudgetAlertService(this._budgets, this._transactions);
  final BudgetRepository _budgets;
  final TransactionRepository _transactions;

  /// Returns warning messages (75% / 90% / >100%) for the category budget and
  /// the overall budget of the transaction's month.
  Future<List<String>> warningsAfterSave({
    required TransactionType type,
    required int categoryId,
    required String categoryName,
    required DateTime date,
  }) async {
    if (type != TransactionType.expense) return const [];
    final effective =
        BudgetCalculator.effectiveBudgets(await _budgets.getAll(), date.year, date.month);
    final warnings = <String>[];

    final categoryBudget = effective[categoryId];
    if (categoryBudget != null) {
      final spent = await _transactions.monthlyExpense(date.year, date.month, categoryId: categoryId);
      final ratio = spent / categoryBudget.amount;
      final msg = _message('Anggaran $categoryName', ratio);
      if (msg != null) warnings.add(msg);
    }
    final overall = effective[null];
    if (overall != null) {
      final spent = await _transactions.monthlyExpense(date.year, date.month);
      final msg = _message('Anggaran bulanan', spent / overall.amount);
      if (msg != null) warnings.add(msg);
    }
    return warnings;
  }

  static String? _message(String label, double ratio) {
    final pct = (ratio * 100).floor();
    return switch (BudgetStatus.levelFor(ratio)) {
      BudgetLevel.safe => null,
      BudgetLevel.caution => '$label sudah terpakai $pct%.',
      BudgetLevel.danger => '$label hampir habis ($pct%).',
      BudgetLevel.exceeded => '$label terlampaui ($pct%)!',
    };
  }
}
