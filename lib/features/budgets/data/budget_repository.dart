import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../domain/budget.dart';
import '../domain/budget_calculator.dart';

class BudgetRepository {
  BudgetRepository(this._db);
  final AppDatabase _db;

  static Budget _map(BudgetRow r) => Budget(
        id: r.id,
        categoryId: r.categoryId,
        amount: r.amount,
        month: r.month,
        year: r.year,
      );

  Stream<List<Budget>> watchAll() =>
      _db.select(_db.budgets).watch().map((rows) => rows.map(_map).toList());

  Future<List<Budget>> getAll() async => (await _db.select(_db.budgets).get()).map(_map).toList();

  /// Sets the budget for [categoryId] (null = overall) from [year]/[month] on.
  Future<void> setBudget({
    required int? categoryId,
    required int year,
    required int month,
    required int amount,
  }) async {
    if (amount <= 0) throw const BudgetException('Masukkan anggaran lebih dari 0.');
    if (amount > AppLimits.maxAmount) throw const BudgetException('Anggaran terlalu besar.');
    await _upsert(categoryId, year, month, amount);
  }

  /// Stops the budget applying from [year]/[month] onward. Earlier months keep
  /// their history.
  Future<void> removeBudget({
    required int? categoryId,
    required int year,
    required int month,
  }) =>
      _db.transaction(() async {
        await _rowFor(categoryId, year, month).go();
        final remaining = await getAll();
        final stillActive =
            BudgetCalculator.effectiveBudgets(remaining, year, month).containsKey(categoryId);
        if (stillActive) await _upsert(categoryId, year, month, 0);
      });

  DeleteStatement<$BudgetsTable, BudgetRow> _rowFor(int? categoryId, int year, int month) =>
      _db.delete(_db.budgets)..where((b) => _match(b, categoryId, year, month));

  Expression<bool> _match($BudgetsTable b, int? categoryId, int year, int month) {
    final cat = categoryId == null ? b.categoryId.isNull() : b.categoryId.equals(categoryId);
    return cat & b.year.equals(year) & b.month.equals(month);
  }

  // SQLite treats NULLs as distinct in UNIQUE constraints, so the overall
  // budget's uniqueness is enforced here rather than by the index.
  Future<void> _upsert(int? categoryId, int year, int month, int amount) =>
      _db.transaction(() async {
        final existing = await (_db.select(_db.budgets)
              ..where((b) => _match(b, categoryId, year, month)))
            .get();
        if (existing.isEmpty) {
          await _db.into(_db.budgets).insert(BudgetsCompanion.insert(
                categoryId: Value(categoryId),
                amount: amount,
                month: month,
                year: year,
              ));
        } else {
          await (_db.update(_db.budgets)..where((b) => b.id.equals(existing.first.id)))
              .write(BudgetsCompanion(amount: Value(amount)));
          for (final dup in existing.skip(1)) {
            await (_db.delete(_db.budgets)..where((b) => b.id.equals(dup.id))).go();
          }
        }
      });
}
