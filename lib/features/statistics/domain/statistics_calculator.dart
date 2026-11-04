import '../../../core/utils/formatters.dart';
import '../../categories/domain/category.dart';
import '../../transactions/domain/finance_transaction.dart';

enum PeriodType {
  day('Harian'),
  week('Mingguan'),
  month('Bulanan'),
  year('Tahunan');

  const PeriodType(this.label);
  final String label;
}

/// Half-open range [start, end).
class Period {
  const Period(this.type, this.start, this.end);
  final PeriodType type;
  final DateTime start;
  final DateTime end;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  int get dayCount => DateTime.utc(end.year, end.month, end.day)
      .difference(DateTime.utc(start.year, start.month, start.day))
      .inDays;

  /// Days from start up to today (or the whole period if it's in the past).
  int elapsedDays(DateTime now) {
    if (!now.isAfter(start)) return 0;
    if (!now.isBefore(end)) return dayCount;
    return dateOnly(now).difference(dateOnly(start)).inDays + 1;
  }

  /// The period of the same type immediately before this one.
  Period previous() => Period.of(type, start.subtract(const Duration(days: 1)));

  Period shift(int steps) {
    final anchor = switch (type) {
      PeriodType.day => DateTime(start.year, start.month, start.day + steps),
      PeriodType.week => DateTime(start.year, start.month, start.day + 7 * steps),
      PeriodType.month => DateTime(start.year, start.month + steps),
      PeriodType.year => DateTime(start.year + steps),
    };
    return Period.of(type, anchor);
  }

  factory Period.of(PeriodType type, DateTime anchor) {
    final d = dateOnly(anchor);
    switch (type) {
      case PeriodType.day:
        return Period(type, d, DateTime(d.year, d.month, d.day + 1));
      case PeriodType.week:
        final monday = DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
        return Period(type, monday, DateTime(monday.year, monday.month, monday.day + 7));
      case PeriodType.month:
        return Period(type, DateTime(d.year, d.month), DateTime(d.year, d.month + 1));
      case PeriodType.year:
        return Period(type, DateTime(d.year), DateTime(d.year + 1));
    }
  }

  String get label {
    switch (type) {
      case PeriodType.day:
        return DateFormats.dayDate.format(start);
      case PeriodType.week:
        final last = DateTime(end.year, end.month, end.day - 1);
        return '${DateFormats.dayMonth.format(start)} – ${DateFormats.date.format(last)}';
      case PeriodType.month:
        return DateFormats.monthYear.format(start);
      case PeriodType.year:
        return '${start.year}';
    }
  }

  @override
  bool operator ==(Object other) =>
      other is Period && other.type == type && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(type, start, end);
}

class PeriodSummary {
  const PeriodSummary({
    required this.income,
    required this.expense,
    required this.count,
    required this.averageDailyExpense,
  });
  final int income;
  final int expense;
  final int count;
  final int averageDailyExpense;
  int get net => income - expense;
}

class CategoryTotal {
  const CategoryTotal(this.category, this.amount, this.count, this.share);
  final Category category;
  final int amount;
  final int count;

  /// 0..1 share of the total.
  final double share;
}

class MonthTotal {
  const MonthTotal(this.month, this.income, this.expense);

  /// First day of the month.
  final DateTime month;
  final int income;
  final int expense;
}

class DayTotal {
  const DayTotal(this.day, this.amount);
  final DateTime day;
  final int amount;
}

abstract final class StatisticsCalculator {
  static Iterable<FinanceTransaction> inPeriod(
    Iterable<FinanceTransaction> txs,
    Period period,
  ) =>
      txs.where((t) => period.contains(t.date));

  static PeriodSummary summarize(
    Iterable<FinanceTransaction> txs,
    Period period, {
    DateTime? now,
  }) {
    var income = 0, expense = 0, count = 0;
    for (final t in inPeriod(txs, period)) {
      count++;
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final days = period.elapsedDays(now ?? DateTime.now());
    return PeriodSummary(
      income: income,
      expense: expense,
      count: count,
      averageDailyExpense: days == 0 ? 0 : (expense / days).round(),
    );
  }

  /// Expense totals by category in [period], largest first.
  static List<CategoryTotal> expenseByCategory(
    Iterable<FinanceTransaction> txs,
    Period period,
  ) {
    final amounts = <int, int>{};
    final counts = <int, int>{};
    final cats = <int, Category>{};
    for (final t in inPeriod(txs, period)) {
      if (!t.isExpense) continue;
      amounts.update(t.category.id, (v) => v + t.amount, ifAbsent: () => t.amount);
      counts.update(t.category.id, (v) => v + 1, ifAbsent: () => 1);
      cats[t.category.id] = t.category;
    }
    final total = amounts.values.fold<int>(0, (a, b) => a + b);
    final result = [
      for (final e in amounts.entries)
        CategoryTotal(cats[e.key]!, e.value, counts[e.key]!, total == 0 ? 0 : e.value / total),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
    return result;
  }

  /// [count] months ending with the month of [endMonth], oldest first.
  static List<MonthTotal> monthlyTotals(
    Iterable<FinanceTransaction> txs,
    DateTime endMonth,
    int count,
  ) {
    final first = DateTime(endMonth.year, endMonth.month - (count - 1));
    final income = List.filled(count, 0);
    final expense = List.filled(count, 0);
    for (final t in txs) {
      final idx = (t.date.year - first.year) * 12 + (t.date.month - first.month);
      if (idx < 0 || idx >= count) continue;
      if (t.isIncome) {
        income[idx] += t.amount;
      } else {
        expense[idx] += t.amount;
      }
    }
    return [
      for (var i = 0; i < count; i++)
        MonthTotal(DateTime(first.year, first.month + i), income[i], expense[i]),
    ];
  }

  /// Expense per day for every day in [start, end).
  static List<DayTotal> dailyExpenses(
    Iterable<FinanceTransaction> txs,
    DateTime start,
    DateTime end,
  ) {
    final s = dateOnly(start);
    final days = <DayTotal>[];
    final byDay = <DateTime, int>{};
    for (final t in txs) {
      if (!t.isExpense || t.date.isBefore(s) || !t.date.isBefore(end)) continue;
      byDay.update(dateOnly(t.date), (v) => v + t.amount, ifAbsent: () => t.amount);
    }
    for (var d = s; d.isBefore(end); d = DateTime(d.year, d.month, d.day + 1)) {
      days.add(DayTotal(d, byDay[d] ?? 0));
    }
    return days;
  }

  /// Expense totals per month of a year (12 entries).
  static List<DayTotal> monthlyExpensesOfYear(Iterable<FinanceTransaction> txs, int year) {
    final totals = List.filled(12, 0);
    for (final t in txs) {
      if (t.isExpense && t.date.year == year) totals[t.date.month - 1] += t.amount;
    }
    return [for (var m = 0; m < 12; m++) DayTotal(DateTime(year, m + 1), totals[m])];
  }
}
