import 'package:flutter/widgets.dart';

/// Languages the app can be shown in. Stored by [code].
enum AppLanguage {
  id('id', 'Bahasa Indonesia', 'id_ID'),
  en('en', 'English', 'en_US'),
  zh('zh', '中文（简体）', 'zh_CN'),
  ja('ja', '日本語', 'ja_JP'),
  ko('ko', '한국어', 'ko_KR');

  const AppLanguage(this.code, this.nativeName, this.intlLocale);

  /// Language code used for translations and preferences.
  final String code;

  /// Name shown in the language picker, in the language itself.
  final String nativeName;

  /// Locale used by `intl` for dates.
  final String intlLocale;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.id);
}
