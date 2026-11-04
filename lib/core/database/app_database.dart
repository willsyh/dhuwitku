import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'default_categories.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, Budgets, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Opens the on-device database file (offline, no network involved).
  factory AppDatabase.open() => AppDatabase(
        driftDatabase(
          name: databaseFileName,
          native: const DriftNativeOptions(databasePath: databaseFilePath),
        ),
      );

  static const databaseFileName = 'dhuwitku';

  static Future<String> databaseFilePath() async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, '$databaseFileName.sqlite');
  }

  /// Bump this and add a step in [migration] whenever the schema changes.
  static const currentSchemaVersion = 1;

  @override
  int get schemaVersion => currentSchemaVersion;

  bool _closed = false;

  @override
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await super.close();
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedDefaultCategories();
        },
        onUpgrade: (m, from, to) async {
          // Future schema changes go here, one step per version, e.g.
          // if (from < 2) { await m.addColumn(transactions, transactions.note); }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(
        categories,
        [
          for (final c in defaultCategories)
            CategoriesCompanion.insert(
              name: c.name,
              icon: c.icon,
              color: c.color,
              type: c.type.name,
              isDefault: const Value(true),
            ),
        ],
      );
    });
  }

  /// Removes every user record and restores the default categories.
  Future<void> resetAllData() => transaction(() async {
        await delete(budgets).go();
        await delete(transactions).go();
        await delete(categories).go();
        await delete(appSettings).go();
        await seedDefaultCategories();
      });
}
