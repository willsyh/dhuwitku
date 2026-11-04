import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utils/async_utils.dart';
import '../../categories/presentation/category_providers.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../data/budget_repository.dart';
import '../domain/budget.dart';
import '../domain/budget_calculator.dart';

final budgetRepositoryProvider = Provider((ref) => BudgetRepository(ref.watch(databaseProvider)));

final budgetsProvider =
    StreamProvider<List<Budget>>((ref) => ref.watch(budgetRepositoryProvider).watchAll());

/// Budget statuses for a (year, month).
final budgetStatusesProvider =
    Provider.family<AsyncValue<List<BudgetStatus>>, (int, int)>((ref, ym) {
  final budgets = ref.watch(budgetsProvider);
  final categories = ref.watch(categoriesProvider);
  final txs = ref.watch(transactionsProvider);
  return combineAsync(
    [budgets, categories, txs],
    () => BudgetCalculator.statuses(
      budgets: budgets.requireValue,
      categories: categories.requireValue,
      transactions: txs.requireValue,
      year: ym.$1,
      month: ym.$2,
    ),
  );
});

class SelectedBudgetMonth extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void shift(int months) => state = DateTime(state.year, state.month + months);
}

final selectedBudgetMonthProvider =
    NotifierProvider<SelectedBudgetMonth, DateTime>(SelectedBudgetMonth.new);
