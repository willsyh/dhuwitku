import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme/festive_theme.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/l10n.dart';
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

class FestiveThemeNotifier extends Notifier<FestiveTheme> {
  static const _key = 'festive_theme';

  @override
  FestiveTheme build() =>
      FestiveTheme.fromName(ref.watch(sharedPreferencesProvider).getString(_key));

  Future<void> set(FestiveTheme theme) async {
    state = theme;
    await ref.read(sharedPreferencesProvider).setString(_key, theme.name);
  }
}

final festiveThemeProvider =
    NotifierProvider<FestiveThemeNotifier, FestiveTheme>(FestiveThemeNotifier.new);

/// App language, stored on the device. Applying it also switches the text used
/// by non-widget code (see `l10n`).
class LanguageNotifier extends Notifier<AppLanguage> {
  static const _key = 'language';

  @override
  AppLanguage build() {
    final language = AppLanguage.fromCode(ref.watch(sharedPreferencesProvider).getString(_key));
    applyLanguage(language);
    return language;
  }

  Future<void> set(AppLanguage language) async {
    applyLanguage(language);
    state = language;
    await ref.read(sharedPreferencesProvider).setString(_key, language.code);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

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
