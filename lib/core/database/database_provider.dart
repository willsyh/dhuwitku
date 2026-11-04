import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The single database connection. Invalidating it (after a restore) closes
/// the old connection and makes every dependent provider reload.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});
