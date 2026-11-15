import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/core/utils/formatters.dart';
import 'package:dhuwitku/features/assistant/domain/assistant_engine.dart';
import 'package:dhuwitku/features/assistant/domain/assistant_intent.dart';
import 'package:dhuwitku/features/budgets/domain/budget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  final money = MoneyFormatter();
  final now = DateTime(2026, 11, 18, 20); // Wednesday
  final month = QueryRange(DateTime(2026, 11), DateTime(2026, 12), 'bulan ini');
  final week = QueryRange(DateTime(2026, 11, 16), DateTime(2026, 11, 23), 'minggu ini');

  // November: coffee 8x Rp 25.000, food 3x Rp 100.000, salary Rp 6.000.000.
  final txs = [
    for (var d = 1; d <= 8; d++) tx(25000, DateTime(2026, 11, d + 9), category: coffee),
    for (var d = 1; d <= 3; d++) tx(100000, DateTime(2026, 11, d), category: food),
    tx(6000000, DateTime(2026, 11, 1), category: salary),
    tx(40000, DateTime(2026, 10, 20), category: fuel), // last month
  ];
  AssistantData data({List<Budget> budgets = const []}) => AssistantData(
        transactions: txs,
        categories: const [food, coffee, fuel, salary],
        budgets: budgets,
        now: now,
      );
  String ask(AssistantIntent i, {List<Budget> budgets = const []}) =>
      AssistantEngine.answer(i, data(budgets: budgets), money);

  test('monthly spending with top category and daily average', () {
    final r = ask(QuerySpendingIntent(range: month, type: TransactionType.expense));
    expect(r, contains('Pengeluaran bulan ini Rp 500.000 (11 transaksi).'));
    expect(r, contains('Terbesar: Makan Rp 300.000 (60%).'));
    expect(r, contains('Rata-rata Rp 27.778 per hari.')); // 500.000 / 18 days
  });

  test('category in a week', () {
    final r = ask(QuerySpendingIntent(range: week, type: TransactionType.expense, category: coffee));
    // Coffee on 16, 17 Nov (d=7,8 -> days 16, 17)
    expect(r, startsWith('Kopi minggu ini Rp 50.000 (2 transaksi).'));
  });

  test('income and empty results', () {
    expect(ask(QuerySpendingIntent(range: month, type: TransactionType.income)),
        startsWith('Pemasukan bulan ini Rp 6.000.000 (1 transaksi).'));
    expect(ask(QuerySpendingIntent(range: week, type: TransactionType.expense, category: fuel)),
        'Belum ada transaksi Bensin minggu ini.');
  });

  test('balance', () {
    final r = ask(const QueryBalanceIntent());
    expect(r, startsWith('Saldo kamu Rp 5.460.000.'));
    expect(r, contains('Bulan ini: masuk Rp 6.000.000, keluar Rp 500.000.'));
  });

  test('budget answers', () {
    expect(ask(const QueryBudgetIntent()), contains('belum mengatur anggaran'));
    final budgets = [
      const Budget(id: 1, categoryId: null, amount: 600000, month: 11, year: 2026),
      Budget(id: 2, categoryId: coffee.id, amount: 200000, month: 11, year: 2026),
    ];
    final all = ask(const QueryBudgetIntent(), budgets: budgets);
    expect(all, contains('Anggaran Bulanan: sisa Rp 100.000 dari Rp 600.000 (83%, waspada).'));
    expect(all, contains('Kopi: sisa Rp 0 dari Rp 200.000 (100%, hampir habis).'));
    expect(ask(QueryBudgetIntent(category: food), budgets: budgets),
        contains('Belum ada batas anggaran untuk Makan'));
  });

  test('top categories', () {
    final r = ask(QueryTopCategoryIntent(range: month));
    expect(r, contains('1. Makan Rp 300.000 (60%)'));
    expect(r, contains('2. Kopi Rp 200.000 (40%)'));
  });

  test('tips come from own data', () {
    final r = ask(const AskTipsIntent());
    // Coffee 8x avg 25.000 -> cut 2x/week ~ 25.000 * 2 * 30/7 = 214.286
    expect(r, contains('Kopi 8× bulan ini'));
    expect(r, contains('hemat Rp 214.286/bulan'));
    expect(r, contains('Makan menyerap 60%'));
    expect(r, contains('belum punya anggaran bulanan'));
  });

  test('tips with no data', () {
    final empty = AssistantData(transactions: const [], categories: const [], budgets: const [], now: now);
    expect(AssistantEngine.answer(const AskTipsIntent(), empty, money), contains('Belum cukup data'));
  });

  test('help and unknown', () {
    expect(ask(const HelpIntent()), contains('kopi 25rb'));
    expect(ask(const UnknownIntent()), startsWith('Maaf, aku belum paham'));
  });
}
