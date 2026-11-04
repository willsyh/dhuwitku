import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../data/settings_repository.dart';
import '../domain/currency.dart';

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  late final ThemePreferences _prefs;

  @override
  ThemeMode build() {
    _prefs = ThemePreferences(ref.watch(sharedPreferencesProvider));
    return _prefs.read();
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.write(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final settingsRepositoryProvider =
    Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));

final currencyProvider = StreamProvider<CurrencyOption>((ref) => ref
    .watch(settingsRepositoryProvider)
    .watch(SettingsRepository.currencyKey)
    .map(currencyFor));

/// Formatter for the selected currency; falls back to Rupiah while loading.
final moneyFormatterProvider = Provider<MoneyFormatter>((ref) {
  final currency = ref.watch(currencyProvider).value ?? currencyOptions.first;
  return MoneyFormatter(symbol: currency.symbol);
});
