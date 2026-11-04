import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/app_database.dart';

/// Settings stored in the `app_settings` table (travel with backups).
class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  static const currencyKey = 'currency_code';

  Stream<String?> watch(String key) =>
      (_db.select(_db.appSettings)..where((s) => s.settingKey.equals(key)))
          .watchSingleOrNull()
          .map((r) => r?.settingValue);

  Future<void> set(String key, String value) => _db.into(_db.appSettings).insert(
        AppSettingsCompanion.insert(settingKey: key, settingValue: value),
        onConflict: DoUpdate(
          (_) => AppSettingsCompanion(settingValue: Value(value)),
          target: [_db.appSettings.settingKey],
        ),
      );
}

/// Device-level preferences that must be available before the database opens.
class ThemePreferences {
  ThemePreferences(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeMode read() => ThemeMode.values.firstWhere(
        (m) => m.name == _prefs.getString(_key),
        orElse: () => ThemeMode.system,
      );

  Future<void> write(ThemeMode mode) => _prefs.setString(_key, mode.name);
}
