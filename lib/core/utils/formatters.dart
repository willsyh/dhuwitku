import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';

/// Locale for Rupiah amounts. Grouping stays "Rp 15.000" in every app
/// language: it is the currency's convention, and matches the keypad.
const appLocale = 'id_ID';

/// Formats whole-unit amounts, e.g. `Rp 15.000`.
class MoneyFormatter {
  MoneyFormatter({this.symbol = 'Rp'});

  final String symbol;
  static final NumberFormat _grouping = NumberFormat.decimalPattern(appLocale);

  String format(int amount) {
    final sign = amount < 0 ? '-' : '';
    return '$sign$symbol ${_grouping.format(amount.abs())}';
  }

  /// With an explicit `+`/`-` sign, used for transaction amounts.
  String signed(int amount, {required bool positive}) =>
      '${positive ? '+' : '-'}${format(amount.abs())}';

  /// Short form for chart axes and tight spaces: 15rb / 15k / 1.5万.
  String compact(num amount) => compactNumber(amount);
}

String groupDigits(int value) => NumberFormat.decimalPattern(appLocale).format(value);

/// Short number in the active language: 15rb, 1,5jt (id) · 15k, 1.5M (en) ·
/// 1.5万, 2亿 (zh) · 1.5万, 2億 (ja) · 1.5만, 2억 (ko).
String compactNumber(num value, {AppLanguage? language}) {
  final lang = language ?? currentLanguage;
  final abs = value.abs();
  final sign = value < 0 ? '-' : '';
  final comma = lang == AppLanguage.id;
  String trim(double v) {
    var s = v.toStringAsFixed(v >= 100 ? 0 : 1);
    if (s.endsWith('.0')) s = s.substring(0, s.length - 2);
    return comma ? s.replaceAll('.', ',') : s;
  }

  // Scales per language, largest first.
  final scales = switch (lang) {
    AppLanguage.id => [(1e12, 'T'), (1e9, 'M'), (1e6, 'jt'), (1e3, 'rb')],
    AppLanguage.en => [(1e12, 'T'), (1e9, 'B'), (1e6, 'M'), (1e3, 'k')],
    AppLanguage.zh => [(1e8, '亿'), (1e4, '万')],
    AppLanguage.ja => [(1e8, '億'), (1e4, '万')],
    AppLanguage.ko => [(1e8, '억'), (1e4, '만')],
  };
  for (final (scale, unit) in scales) {
    if (abs >= scale) return '$sign${trim(abs / scale)}$unit';
  }
  return '$sign${abs.round()}';
}

/// Date formats in the active language. Indonesian keeps the app's
/// DD MMM YYYY style; other languages use their natural order
/// (Nov 15, 2026 · 2026年11月15日 · 2026년 11월 15일).
abstract final class DateFormats {
  static final _cache = <String, DateFormat>{};

  static DateFormat _get(String key, DateFormat Function(String locale) indonesian,
      DateFormat Function(String locale) other) {
    final lang = currentLanguage;
    return _cache.putIfAbsent('$key/${lang.code}', () {
      final locale = lang.intlLocale;
      return lang == AppLanguage.id ? indonesian(locale) : other(locale);
    });
  }

  /// 04 Nov 2026
  static DateFormat get date =>
      _get('date', (l) => DateFormat('dd MMM yyyy', l), (l) => DateFormat.yMMMd(l));

  /// Rabu, 04 Nov 2026
  static DateFormat get dayDate => _get(
      'dayDate', (l) => DateFormat('EEEE, dd MMM yyyy', l), (l) => DateFormat.yMMMEd(l));

  /// November 2026
  static DateFormat get monthYear =>
      _get('monthYear', (l) => DateFormat('MMMM yyyy', l), (l) => DateFormat.yMMMM(l));

  /// Nov
  static DateFormat get shortMonth =>
      _get('shortMonth', (l) => DateFormat('MMM', l), (l) => DateFormat.MMM(l));

  /// 04 Nov
  static DateFormat get dayMonth =>
      _get('dayMonth', (l) => DateFormat('dd MMM', l), (l) => DateFormat.MMMd(l));

  /// 14:05
  static DateFormat get time => _get('time', (l) => DateFormat('HH:mm', l), (l) => DateFormat.Hm(l));

  /// 04 Nov 2026, 14:05
  static DateFormat get dateTime => _get('dateTime', (l) => DateFormat('dd MMM yyyy, HH:mm', l),
      (l) => DateFormat.yMMMd(l).add_Hm());
}

/// "Hari ini" / "Kemarin" (in the active language), or a formatted date.
String relativeDayLabel(DateTime date, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final d = dateOnly(date);
  final diff = today.difference(d).inDays;
  if (diff == 0) return l10n.today;
  if (diff == 1) return l10n.yesterday;
  return DateFormats.date.format(date);
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
