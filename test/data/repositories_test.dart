import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/core/database/app_database.dart';
import 'package:dhuwitku/core/database/default_categories.dart';
import 'package:dhuwitku/features/budgets/data/budget_alert_service.dart';
import 'package:dhuwitku/features/budgets/data/budget_repository.dart';
import 'package:dhuwitku/features/budgets/domain/budget_calculator.dart';
import 'package:dhuwitku/features/categories/data/category_repository.dart';
import 'package:dhuwitku/features/categories/domain/category.dart';
import 'package:dhuwitku/features/settings/data/demo_data.dart';
import 'package:dhuwitku/features/settings/data/settings_repository.dart';
import 'package:dhuwitku/features/transactions/data/transaction_repository.dart';
import 'package:dhuwitku/features/transactions/domain/finance_transaction.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late CategoryRepository categories;
  late TransactionRepository transactions;
  late BudgetRepository budgets;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    categories = CategoryRepository(db);
    transactions = TransactionRepository(db);
    budgets = BudgetRepository(db);
  });
  tearDown(() => db.close());

  Future<Category> cat(String name, [TransactionType type = TransactionType.expense]) async =>
      (await categories.getAll()).firstWhere((c) => c.name == name && c.type == type);

  TransactionDraft draft(Category c, int amount, {DateTime? date, String? note}) => TransactionDraft(
        type: c.type,
        amount: amount,
        categoryId: c.id,
        date: date ?? DateTime(2026, 11, 4, 12),
        description: note,
      );

  test('default categories are seeded on first launch', () async {
    final all = await categories.getAll();
    expect(all.length, defaultCategories.length);
    expect(all.where((c) => c.type == TransactionType.expense).map((c) => c.name),
        containsAll(['Makan', 'Kopi', 'Bensin', 'Parkir', 'Lainnya']));
    expect(all.every((c) => c.isDefault), isTrue);
  });

  test('add, read, update and delete a transaction', () async {
    final makan = await cat('Makan');
    final id = await transactions.add(draft(makan, 15000, note: '  Nasi goreng '));
    var list = await transactions.getAll();
    expect(list.single.amount, 15000);
    expect(list.single.description, 'Nasi goreng');
    expect(list.single.category.name, 'Makan');

    final kopi = await cat('Kopi');
    await transactions.update(id, draft(kopi, 22000));
    list = await transactions.getAll();
    expect(list.single.amount, 22000);
    expect(list.single.category.id, kopi.id);
    expect(list.single.description, isNull);

    await transactions.delete(id);
    expect(await transactions.getAll(), isEmpty);
  });

  test('watchAll emits again after a change', () async {
    final makan = await cat('Makan');
    final stream = transactions.watchAll();
    final expectation = expectLater(
      stream.map((l) => l.length),
      emitsInOrder([0, 1]),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await transactions.add(draft(makan, 10000));
    await expectation;
  });

  test('rejects invalid input and mismatched category type', () async {
    final makan = await cat('Makan');
    final gaji = await cat('Gaji', TransactionType.income);
    expect(() => transactions.add(draft(makan, 0)), throwsA(isA<TransactionException>()));
    expect(
      () => transactions.add(TransactionDraft(
          type: TransactionType.expense, amount: 1000, categoryId: gaji.id, date: DateTime.now())),
      throwsA(isA<TransactionException>()),
    );
  });

  test('database CHECK constraint blocks non-positive amounts', () async {
    final makan = await cat('Makan');
    expect(
      () => db.into(db.transactions).insert(TransactionsCompanion.insert(
          type: 'expense', amount: -5, categoryId: makan.id, transactionDate: DateTime.now())),
      throwsA(anything),
    );
  });

  test('foreign key prevents deleting a used category directly', () async {
    final makan = await cat('Makan');
    await transactions.add(draft(makan, 10000));
    expect(
      () => (db.delete(db.categories)..where((c) => c.id.equals(makan.id))).go(),
      throwsA(anything),
    );
  });

  test('deleting a used category moves its transactions to the replacement', () async {
    final custom = await categories.create(
        name: 'Jajan', iconKey: 'snack', colorValue: 0xFFEC4899, type: TransactionType.expense);
    final lainnya = await cat('Lainnya');
    final jajan = (await categories.getAll()).firstWhere((c) => c.id == custom);
    await transactions.add(draft(jajan, 5000));
    await transactions.add(draft(jajan, 7000));
    await budgets.setBudget(categoryId: custom, year: 2026, month: 11, amount: 100000);

    expect(() => categories.delete(custom), throwsA(isA<CategoryException>()));
    await categories.delete(custom, reassignTo: lainnya.id);

    final list = await transactions.getAll();
    expect(list.length, 2);
    expect(list.every((t) => t.category.id == lainnya.id), isTrue);
    expect((await budgets.getAll()).where((b) => b.categoryId == custom), isEmpty); // cascade
  });

  test('category names are unique per type (case-insensitive)', () async {
    expect(
      () => categories.create(name: 'makan', iconKey: 'other', colorValue: 0, type: TransactionType.expense),
      throwsA(isA<CategoryException>()),
    );
    // Same name for the other type is fine.
    await categories.create(name: 'Makan', iconKey: 'other', colorValue: 0, type: TransactionType.income);
  });

  test('budgets: overall budget upserts, carries forward and can be removed', () async {
    await budgets.setBudget(categoryId: null, year: 2026, month: 10, amount: 3000000);
    await budgets.setBudget(categoryId: null, year: 2026, month: 10, amount: 3500000);
    var all = await budgets.getAll();
    expect(all.length, 1); // updated, not duplicated
    expect(BudgetCalculator.effectiveBudgets(all, 2026, 12)[null]!.amount, 3500000);

    await budgets.removeBudget(categoryId: null, year: 2026, month: 12);
    all = await budgets.getAll();
    expect(BudgetCalculator.effectiveBudgets(all, 2026, 11)[null]!.amount, 3500000);
    expect(BudgetCalculator.effectiveBudgets(all, 2026, 12).containsKey(null), isFalse);
  });

  test('budget alert service warns at 75%+ right after saving', () async {
    final kopi = await cat('Kopi');
    await budgets.setBudget(categoryId: kopi.id, year: 2026, month: 11, amount: 100000);
    await transactions.add(draft(kopi, 92000));
    final warnings = await BudgetAlertService(budgets, transactions).warningsAfterSave(
      type: TransactionType.expense,
      categoryId: kopi.id,
      categoryName: 'Kopi',
      date: DateTime(2026, 11, 4),
    );
    expect(warnings.single, contains('92%'));
    expect(await transactions.monthlyExpense(2026, 11), 92000);
  });

  test('demo data is labeled and removable without touching real data', () async {
    final makan = await cat('Makan');
    await transactions.add(draft(makan, 12345));
    final demo = DemoData.build(await categories.getAll(), now: DateTime(2026, 11, 4, 22));
    await transactions.addAll(demo, isDemo: true);
    expect(await transactions.hasDemoData(), isTrue);

    final removed = await transactions.deleteDemoData();
    expect(removed, demo.length);
    final remaining = await transactions.getAll();
    expect(remaining.single.amount, 12345);
  });

  test('settings upsert and reset restores defaults', () async {
    final settings = SettingsRepository(db);
    await settings.set(SettingsRepository.currencyKey, 'USD');
    await settings.set(SettingsRepository.currencyKey, 'IDR');
    expect(await settings.watch(SettingsRepository.currencyKey).first, 'IDR');

    await transactions.add(draft(await cat('Makan'), 1000));
    await db.resetAllData();
    expect(await transactions.getAll(), isEmpty);
    expect((await categories.getAll()).length, defaultCategories.length);
    expect(await settings.watch(SettingsRepository.currencyKey).first, isNull);
  });
}
