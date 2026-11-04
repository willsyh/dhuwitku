import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

import '../../../core/database/app_database.dart';

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Backs up and restores the whole SQLite database file.
class BackupService {
  const BackupService();

  static const _requiredTables = {'categories', 'transactions', 'budgets', 'app_settings'};

  /// A consistent snapshot of the live database (VACUUM INTO is safe while the
  /// database is open and in use).
  Future<Uint8List> createBackup(AppDatabase db) async {
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'dhuwitku_backup_${DateTime.now().millisecondsSinceEpoch}.sqlite'));
    if (await file.exists()) await file.delete();
    await db.customStatement('VACUUM INTO ?', [file.path]);
    try {
      return await file.readAsBytes();
    } finally {
      await file.delete();
    }
  }

  /// Validates [bytes] as a Dhuwitku backup, then replaces the database file.
  /// [current] is closed first; the caller must reopen the database afterwards.
  /// The previous file is kept until the copy succeeds.
  Future<void> restore(Uint8List bytes, AppDatabase current) async {
    final dir = await getTemporaryDirectory();
    final candidate = File(p.join(dir.path, 'dhuwitku_restore_candidate.sqlite'));
    await candidate.writeAsBytes(bytes, flush: true);
    try {
      validateFile(candidate.path);

      final target = File(await AppDatabase.databaseFilePath());
      final safety = File('${target.path}.before-restore');
      await current.close();

      if (await target.exists()) await target.copy(safety.path);
      try {
        for (final suffix in const ['-wal', '-shm', '-journal']) {
          final f = File('${target.path}$suffix');
          if (await f.exists()) await f.delete();
        }
        await candidate.copy(target.path);
      } catch (_) {
        if (await safety.exists()) await safety.copy(target.path);
        rethrow;
      }
      if (await safety.exists()) await safety.delete();
    } finally {
      if (await candidate.exists()) await candidate.delete();
    }
  }

  /// Throws [BackupException] unless [path] is an intact, compatible backup.
  static void validateFile(String path) {
    final header = File(path).openSync()..setPositionSync(0);
    final magic = header.readSync(16);
    header.closeSync();
    if (String.fromCharCodes(magic) != 'SQLite format 3\u0000') {
      throw const BackupException('File bukan cadangan Dhuwitku yang valid.');
    }

    final db = sql.sqlite3.open(path, mode: sql.OpenMode.readOnly);
    try {
      final tables = db
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((r) => r['name'] as String)
          .toSet();
      if (!tables.containsAll(_requiredTables)) {
        throw const BackupException('File cadangan tidak berisi data Dhuwitku.');
      }
      final version = db.userVersion;
      if (version < 1 || version > AppDatabase.currentSchemaVersion) {
        throw const BackupException(
            'Cadangan dibuat oleh versi aplikasi yang lebih baru. Perbarui aplikasi terlebih dahulu.');
      }
      final integrity = db.select('PRAGMA integrity_check').first.values.first;
      if (integrity != 'ok') throw const BackupException('File cadangan rusak.');
      if (db.select('PRAGMA foreign_key_check').isNotEmpty) {
        throw const BackupException('Data dalam cadangan tidak konsisten.');
      }
    } on sql.SqliteException {
      throw const BackupException('File cadangan tidak dapat dibaca.');
    } finally {
      db.close();
    }
  }
}
