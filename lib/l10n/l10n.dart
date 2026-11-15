import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'app_language.dart';
import 'gen/app_localizations.dart';

export 'app_language.dart';
export 'gen/app_localizations.dart';

/// The active language for code that has no BuildContext (domain logic,
/// controllers, formatters). Widgets should use `context.l10n`, which also
/// rebuilds them when the language changes.
AppLanguage _language = AppLanguage.id;
AppLocalizations _strings = lookupAppLocalizations(AppLanguage.id.locale);

AppLanguage get currentLanguage => _language;

/// Translations for the active language.
AppLocalizations get l10n => _strings;

/// Switches the active language (call before rebuilding the app).
void applyLanguage(AppLanguage language) {
  _language = language;
  _strings = lookupAppLocalizations(language.locale);
  Intl.defaultLocale = language.intlLocale;
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
