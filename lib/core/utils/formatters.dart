import 'package:intl/intl.dart';

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

  /// Short form for chart axes and tight spaces: 15rb, 1,5jt, 2,3M.
  String compact(num amount) => compactNumber(amount);
}

String groupDigits(int value) => NumberFormat.decimalPattern(appLocale).format(value);

String compactNumber(num value) {
  final abs = value.abs();
  final sign = value < 0 ? '-' : '';
  String trim(double v) {
    final s = v.toStringAsFixed(v >= 100 ? 0 : 1).replaceAll('.', ',');
    return s.endsWith(',0') ? s.substring(0, s.length - 2) : s;
  }

  if (abs >= 1e12) return '$sign${trim(abs / 1e12)}T';
  if (abs >= 1e9) return '$sign${trim(abs / 1e9)}M';
  if (abs >= 1e6) return '$sign${trim(abs / 1e6)}jt';
  if (abs >= 1e3) return '$sign${trim(abs / 1e3)}rb';
  return '$sign${abs.round()}';
}

abstract final class DateFormats {
  /// 04 Nov 2026
  static final date = DateFormat('dd MMM yyyy', appLocale);

  /// Rabu, 04 Nov 2026
  static final dayDate = DateFormat('EEEE, dd MMM yyyy', appLocale);

  /// November 2026
  static final monthYear = DateFormat('MMMM yyyy', appLocale);

  /// Nov
  static final shortMonth = DateFormat('MMM', appLocale);

  /// 04 Nov
  static final dayMonth = DateFormat('dd MMM', appLocale);

  /// 14:05
  static final time = DateFormat('HH:mm', appLocale);

  /// 04 Nov 2026, 14:05
  static final dateTime = DateFormat('dd MMM yyyy, HH:mm', appLocale);
}

/// "Hari ini", "Kemarin", or a formatted date.
String relativeDayLabel(DateTime date, {DateTime? now}) {
  final today = dateOnly(now ?? DateTime.now());
  final d = dateOnly(date);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return DateFormats.date.format(date);
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
