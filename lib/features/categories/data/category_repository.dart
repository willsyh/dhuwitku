import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/database/app_database.dart';
import '../domain/category.dart';

class CategoryRepository {
  CategoryRepository(this._db);
  final AppDatabase _db;

  static Category fromRow(CategoryRow r) => Category(
        id: r.id,
        name: r.name,
        iconKey: r.icon,
        colorValue: r.color,
        type: TransactionType.fromName(r.type),
        isDefault: r.isDefault,
      );

  Stream<List<Category>> watchAll() {
    final q = _db.select(_db.categories)..orderBy([(c) => OrderingTerm.asc(c.id)]);
    return q.watch().map((rows) => rows.map(fromRow).toList());
  }

  Future<List<Category>> getAll() async {
    final q = _db.select(_db.categories)..orderBy([(c) => OrderingTerm.asc(c.id)]);
    return (await q.get()).map(fromRow).toList();
  }

  Future<int> create({
    required String name,
    required String iconKey,
    required int colorValue,
    required TransactionType type,
  }) async {
    final clean = await _validateName(name, type);
    return _db.into(_db.categories).insert(CategoriesCompanion.insert(
          name: clean,
          icon: iconKey,
          color: colorValue,
          type: type.name,
        ));
  }

  /// Type can't change after creation: existing transactions depend on it.
  Future<void> update(Category category) async {
    final clean = await _validateName(category.name, category.type, excludeId: category.id);
    await (_db.update(_db.categories)..where((c) => c.id.equals(category.id))).write(
      CategoriesCompanion(
        name: Value(clean),
        icon: Value(category.iconKey),
        color: Value(category.colorValue),
      ),
    );
  }

  Future<int> transactionCount(int categoryId) async {
    final count = _db.transactions.id.count();
    final q = _db.selectOnly(_db.transactions)
      ..addColumns([count])
      ..where(_db.transactions.categoryId.equals(categoryId));
    return await q.map((r) => r.read(count)).getSingle() ?? 0;
  }

  /// Deletes a category. If transactions still use it, they are first moved to
  /// [reassignTo] (must be another category of the same type) in the same
  /// database transaction, so no transaction is ever left without a category.
  Future<void> delete(int categoryId, {int? reassignTo}) => _db.transaction(() async {
        final target = await (_db.select(_db.categories)..where((c) => c.id.equals(categoryId)))
            .getSingleOrNull();
        if (target == null) return;

        final sameType = await (_db.select(_db.categories)
              ..where((c) => c.type.equals(target.type)))
            .get();
        if (sameType.length <= 1) {
          throw const CategoryException('Minimal harus ada satu kategori untuk jenis ini.');
        }

        final used = await transactionCount(categoryId);
        if (used > 0) {
          if (reassignTo == null || reassignTo == categoryId) {
            throw const CategoryException('Pilih kategori pengganti untuk transaksi yang ada.');
          }
          final replacement = sameType.where((c) => c.id == reassignTo).firstOrNull;
          if (replacement == null) {
            throw const CategoryException('Kategori pengganti harus berjenis sama.');
          }
          await (_db.update(_db.transactions)..where((t) => t.categoryId.equals(categoryId)))
              .write(TransactionsCompanion(
            categoryId: Value(reassignTo),
            updatedAt: Value(DateTime.now()),
          ));
        }
        // Budgets for this category are removed by ON DELETE CASCADE.
        await (_db.delete(_db.categories)..where((c) => c.id.equals(categoryId))).go();
      });

  Future<String> _validateName(String name, TransactionType type, {int? excludeId}) async {
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) throw const CategoryException('Nama kategori wajib diisi.');
    if (clean.length > AppLimits.maxCategoryNameLength) {
      throw const CategoryException('Nama kategori maksimal 40 karakter.');
    }
    final existing = await (_db.select(_db.categories)
          ..where((c) => c.type.equals(type.name) & c.name.lower().equals(clean.toLowerCase())))
        .get();
    if (existing.any((c) => c.id != excludeId)) {
      throw const CategoryException('Kategori dengan nama ini sudah ada.');
    }
    return clean;
  }
}
