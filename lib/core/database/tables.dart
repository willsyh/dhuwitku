// Drift column checks reference their own getter by design.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

// Monetary amounts are whole Rupiah stored as INTEGER to avoid floating-point
// rounding. Types are stored as 'expense' / 'income'.

@DataClassName('CategoryRow')
@TableIndex(name: 'idx_categories_type', columns: {#type})
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  TextColumn get icon => text()();
  IntColumn get color => integer()();
  TextColumn get type => text().check(type.isIn(const ['expense', 'income']))();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name, type},
      ];
}

@DataClassName('TransactionRow')
@TableIndex(name: 'idx_transactions_date', columns: {#transactionDate})
@TableIndex(name: 'idx_transactions_category', columns: {#categoryId})
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text().check(type.isIn(const ['expense', 'income']))();
  IntColumn get amount => integer().check(amount.isBiggerThanValue(0))();

  /// RESTRICT: a category can only be removed after its transactions have been
  /// moved elsewhere (handled in CategoryRepository.delete).
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.restrict)();
  TextColumn get description => text().nullable().withLength(max: 200)();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get paymentMethod => text().nullable().withLength(max: 40)();

  /// Rows created by the optional demo mode, so they can be removed in one go.
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// A budget applies from its month onward until a later row for the same
/// category replaces it. `category_id` NULL means the overall monthly budget.
/// An amount of 0 switches the budget off from that month on.
@DataClassName('BudgetRow')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer()
      .nullable()
      .references(Categories, #id, onDelete: KeyAction.cascade)();
  IntColumn get amount => integer().check(amount.isBiggerOrEqualValue(0))();
  IntColumn get month => integer().check(month.isBetweenValues(1, 12))();
  IntColumn get year => integer().check(year.isBetweenValues(2000, 2100))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, month, year},
      ];
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get settingKey => text().unique()();
  TextColumn get settingValue => text()();
}
