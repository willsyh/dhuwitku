import 'package:dhuwitku/core/utils/formatters.dart';
import 'package:dhuwitku/features/budgets/domain/budget.dart';
import 'package:dhuwitku/features/budgets/domain/budget_calculator.dart';
import 'package:dhuwitku/features/dashboard/domain/dashboard_summary.dart';
import 'package:dhuwitku/features/settings/domain/csv_builder.dart';
import 'package:dhuwitku/features/statistics/domain/insights_generator.dart';
import 'package:dhuwitku/features/statistics/domain/statistics_calculator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));
  final money = MoneyFormatter();

  group('Period', () {
    test('week starts on Monday', () {
      final p = Period.of(PeriodType.week, DateTime(2026, 11, 4)); // Wednesday
      expect(p.start, DateTime(2026, 11, 2));
      expect(p.end, DateTime(2026, 11, 9));
      expect(p.dayCount, 7);
    });
    test('month shift crosses years', () {
      final p = Period.of(PeriodType.month, DateTime(2026, 1, 15)).shift(-1);
      expect(p.start, DateTime(2025, 12));
      expect(p.dayCount, 31);
    });
    test('elapsed days for current month', () {
      final p = Period.of(PeriodType.month, DateTime(2026, 11, 4));
      expect(p.elapsedDays(DateTime(2026, 11, 4, 10)), 4);
      expect(p.elapsedDays(DateTime(2027, 1, 1)), 30);
    });
  });

  group('StatisticsCalculator', () {
    final txs = [
      tx(30000, DateTime(2026, 11, 1)),
      tx(20000, DateTime(2026, 11, 3), category: coffee),
      tx(50000, DateTime(2026, 11, 3), category: food),
      tx(6000000, DateTime(2026, 10, 25), category: salary),
      tx(100000, DateTime(2026, 10, 10), category: fuel),
    ];

    test('summary of a month', () {
      final s = StatisticsCalculator.summarize(
          txs, Period.of(PeriodType.month, DateTime(2026, 11)), now: DateTime(2026, 11, 4));
      expect(s.expense, 100000);
      expect(s.income, 0);
      expect(s.count, 3);
      expect(s.averageDailyExpense, 25000); // 100.000 over 4 elapsed days
    });

    test('expense by category is sorted with shares', () {
      final list = StatisticsCalculator.expenseByCategory(txs, Period.of(PeriodType.month, DateTime(2026, 11)));
      expect(list.first.category.id, food.id);
      expect(list.first.amount, 80000);
      expect(list.first.share, closeTo(0.8, 1e-9));
    });

    test('monthly totals', () {
      final m = StatisticsCalculator.monthlyTotals(txs, DateTime(2026, 11), 3);
      expect(m.map((e) => e.month), [DateTime(2026, 9), DateTime(2026, 10), DateTime(2026, 11)]);
      expect(m[1].income, 6000000);
      expect(m[1].expense, 100000);
      expect(m[2].expense, 100000);
    });

    test('daily expenses fill empty days with zero', () {
      final d = StatisticsCalculator.dailyExpenses(txs, DateTime(2026, 11, 1), DateTime(2026, 11, 4));
      expect(d.map((e) => e.amount), [30000, 0, 70000]);
    });
  });

  group('DashboardSummary', () {
    test('balance = all income - all expense; month figures are current month', () {
      final txs = [
        tx(6000000, DateTime(2026, 10, 25), category: salary),
        tx(100000, DateTime(2026, 10, 10), category: fuel),
        tx(30000, DateTime(2026, 11, 1)),
        tx(15000, DateTime(2026, 11, 4, 8), category: coffee),
      ];
      final s = DashboardSummary.compute(
          transactions: txs, budgetStatuses: const [], now: DateTime(2026, 11, 4, 12));
      expect(s.balance, 6000000 - 100000 - 30000 - 15000);
      expect(s.monthExpense, 45000);
      expect(s.monthIncome, 0);
      expect(s.todayExpense, 15000);
      expect(s.recent.first.amount, 15000);
      expect(s.lastMonths.length, 6);
    });
  });

  group('InsightsGenerator', () {
    test('reports top category, category increase and budget usage', () {
      final now = DateTime(2026, 11, 10, 20);
      final txs = [
        // October 1–10: coffee 100.000, food 300.000
        tx(100000, DateTime(2026, 10, 5), category: coffee),
        tx(300000, DateTime(2026, 10, 6), category: food),
        // Later in October (outside the comparable window)
        tx(900000, DateTime(2026, 10, 25), category: coffee),
        // November 1–10: coffee 120.000 (+20%), food 310.000 (+3%)
        tx(120000, DateTime(2026, 11, 3), category: coffee),
        tx(310000, DateTime(2026, 11, 4), category: food),
      ];
      final budget = BudgetStatus(
        budget: const Budget(id: 1, categoryId: null, amount: 700000, month: 11, year: 2026),
        category: null,
        spent: 520000,
      );
      final messages = InsightsGenerator.generate(
        transactions: txs,
        month: DateTime(2026, 11),
        money: money,
        overallBudget: budget,
        now: now,
      ).map((i) => i.message).toList();

      expect(messages.first, startsWith('Pengeluaran terbesar bulan ini berasal dari kategori Makan'));
      expect(messages, contains('Pengeluaran Kopi meningkat 20% dibandingkan periode yang sama bulan lalu.'));
      expect(messages, contains('Kamu sudah menggunakan 74% dari anggaran bulanan.'));
      expect(messages.any((m) => m.contains('diperkirakan')), isTrue);
    });

    test('empty month gives a friendly message', () {
      final list = InsightsGenerator.generate(
          transactions: const [], month: DateTime(2026, 11), money: money, now: DateTime(2026, 11, 4));
      expect(list.single.message, contains('Belum ada transaksi'));
    });
  });

  group('CsvBuilder', () {
    test('escapes commas, quotes and formula prefixes', () {
      expect(CsvBuilder.escape('a,b'), '"a,b"');
      expect(CsvBuilder.escape('say "hi"'), '"say ""hi"""');
      expect(CsvBuilder.escape('=SUM(A1)'), "'=SUM(A1)");
      expect(CsvBuilder.escape('15000'), '15000');
    });
    test('writes header and one row per transaction', () {
      final csv = CsvBuilder.build([tx(15000, DateTime(2026, 11, 4, 8, 5), note: 'Kopi, susu')]);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[0], startsWith('ID,Tanggal,Waktu,Jenis,Kategori,Jumlah'));
      expect(lines[1], contains('2026-11-04,08:05,Pengeluaran,Makan,15000,"Kopi, susu"'));
    });
  });
}
