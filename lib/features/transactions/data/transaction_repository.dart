import 'package:drift/drift.dart';

import '../../../core/constants/transaction_type.dart';
import '../../../core/database/app_database.dart';
import '../../categories/data/category_repository.dart';
import '../domain/finance_transaction.dart';

class TransactionRepository {
  TransactionRepository(this._db);
  final AppDatabase _db;

  JoinedSelectStatement<HasResultSet, dynamic> _joined() {
    return _db.select(_db.transactions).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
    ])
      ..orderBy([
        OrderingTerm.desc(_db.transactions.transactionDate),
        OrderingTerm.desc(_db.transactions.id),
      ]);
  }

  FinanceTransaction _map(TypedResult r) {
    final t = r.readTable(_db.transactions);
    final c = r.readTable(_db.categories);
    return FinanceTransaction(
      id: t.id,
      type: TransactionType.fromName(t.type),
      amount: t.amount,
      category: CategoryRepository.fromRow(c),
      date: t.transactionDate,
      description: t.description,
      paymentMethod: t.paymentMethod,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
      isDemo: t.isDemo,
    );
  }

  /// All transactions, newest first. Re-emits whenever data changes.
  Stream<List<FinanceTransaction>> watchAll() =>
      _joined().watch().map((rows) => rows.map(_map).toList());

  Future<List<FinanceTransaction>> getAll() async =>
      (await _joined().get()).map(_map).toList();

  Future<int> add(TransactionDraft draft, {bool isDemo = false}) async {
    await _check(draft);
    return _db.into(_db.transactions).insert(TransactionsCompanion.insert(
          type: draft.type.name,
          amount: draft.amount,
          categoryId: draft.categoryId!,
          description: Value(draft.normalizedDescription),
          transactionDate: draft.date,
          paymentMethod: Value(draft.paymentMethod),
          isDemo: Value(isDemo),
        ));
  }

  Future<void> update(int id, TransactionDraft draft) async {
    await _check(draft);
    final updated = await (_db.update(_db.transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        type: Value(draft.type.name),
        amount: Value(draft.amount),
        categoryId: Value(draft.categoryId!),
        description: Value(draft.normalizedDescription),
        transactionDate: Value(draft.date),
        paymentMethod: Value(draft.paymentMethod),
        updatedAt: Value(DateTime.now()),
      ),
    );
    if (updated == 0) throw const TransactionException('Transaksi tidak ditemukan.');
  }

  Future<void> delete(int id) =>
      (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();

  Future<int> deleteDemoData() =>
      (_db.delete(_db.transactions)..where((t) => t.isDemo.equals(true))).go();

  Future<bool> hasDemoData() async {
    final q = _db.select(_db.transactions)
      ..where((t) => t.isDemo.equals(true))
      ..limit(1);
    return (await q.get()).isNotEmpty;
  }

  Future<void> addAll(List<TransactionDraft> drafts, {bool isDemo = false}) =>
      _db.transaction(() async {
        for (final d in drafts) {
          await add(d, isDemo: isDemo);
        }
      });

  /// Sum of expenses in a month, optionally for one category.
  Future<int> monthlyExpense(int year, int month, {int? categoryId}) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    final sum = _db.transactions.amount.sum();
    final q = _db.selectOnly(_db.transactions)
      ..addColumns([sum])
      ..where(_db.transactions.type.equals(TransactionType.expense.name) &
          _db.transactions.transactionDate.isBiggerOrEqualValue(start) &
          _db.transactions.transactionDate.isSmallerThanValue(end));
    if (categoryId != null) q.where(_db.transactions.categoryId.equals(categoryId));
    return await q.map((r) => r.read(sum)).getSingle() ?? 0;
  }

  Future<void> _check(TransactionDraft draft) async {
    final error = draft.validate();
    if (error != null) throw TransactionException(error);
    final category = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(draft.categoryId!)))
        .getSingleOrNull();
    if (category == null) throw const TransactionException('Kategori tidak ditemukan.');
    if (category.type != draft.type.name) {
      throw const TransactionException('Kategori tidak sesuai dengan jenis transaksi.');
    }
  }
}
