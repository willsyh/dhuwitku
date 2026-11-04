import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/features/budgets/domain/budget.dart';
import 'package:dhuwitku/features/budgets/domain/budget_calculator.dart';
import 'package:dhuwitku/features/transactions/domain/transaction_filter.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('TransactionFilter', () {
    final all = [
      tx(30000, DateTime(2026, 11, 4, 19), note: 'Nasi goreng'),
      tx(22000, DateTime(2026, 11, 4, 8), category: coffee, note: 'Kopi susu'),
      tx(6500000, DateTime(2026, 10, 25, 9), category: salary),
      tx(50000, DateTime(2026, 10, 20, 7), category: fuel, method: 'Tunai'),
    ];

    test('search matches description, category and payment method (case-insensitive)', () {
      expect(const TransactionFilter(query: 'NASI').apply(all).length, 1);
      expect(const TransactionFilter(query: 'kopi').apply(all).length, 1);
      expect(const TransactionFilter(query: 'tunai').apply(all).single.amount, 50000);
    });

    test('filters by type and category', () {
      expect(const TransactionFilter(type: TransactionType.income).apply(all).single.amount, 6500000);
      expect(TransactionFilter(categoryId: coffee.id).apply(all).single.amount, 22000);
    });

    test('date range is inclusive of the end day', () {
      final f = TransactionFilter(
          dateRange: DateTimeRange(start: DateTime(2026, 10, 20), end: DateTime(2026, 10, 25)));
      expect(f.apply(all).map((t) => t.amount), [6500000, 50000]);
    });

    test('sorts newest or oldest first', () {
      expect(const TransactionFilter().apply(all).first.amount, 30000);
      expect(const TransactionFilter(sort: SortOrder.oldestFirst).apply(all).first.amount, 50000);
    });

    test('groups by day with daily totals', () {
      final groups = groupByDay(const TransactionFilter().apply(all));
      expect(groups.length, 3);
      expect(groups.first.expense, 52000);
      expect(groups[1].income, 6500000);
    });

    test('copyWith can clear nullable fields', () {
      final f = const TransactionFilter(type: TransactionType.expense).copyWith(type: () => null);
      expect(f.type, isNull);
    });
  });

  group('BudgetCalculator', () {
    Budget b(int? cat, int amount, int year, int month, [int id = 0]) =>
        Budget(id: id, categoryId: cat, amount: amount, month: month, year: year);

    test('a budget carries forward until replaced', () {
      final all = [b(null, 3000000, 2026, 8), b(null, 4000000, 2026, 10)];
      expect(BudgetCalculator.effectiveBudgets(all, 2026, 7), isEmpty);
      expect(BudgetCalculator.effectiveBudgets(all, 2026, 9)[null]!.amount, 3000000);
      expect(BudgetCalculator.effectiveBudgets(all, 2026, 11)[null]!.amount, 4000000);
      expect(BudgetCalculator.effectiveBudgets(all, 2027, 2)[null]!.amount, 4000000);
    });

    test('amount 0 switches a budget off from that month', () {
      final all = [b(1, 500000, 2026, 1), b(1, 0, 2026, 6)];
      expect(BudgetCalculator.effectiveBudgets(all, 2026, 5).containsKey(1), isTrue);
      expect(BudgetCalculator.effectiveBudgets(all, 2026, 6).containsKey(1), isFalse);
    });

    test('warning levels at 75%, 90% and over 100%', () {
      expect(BudgetStatus.levelFor(0.74), BudgetLevel.safe);
      expect(BudgetStatus.levelFor(0.75), BudgetLevel.caution);
      expect(BudgetStatus.levelFor(0.90), BudgetLevel.danger);
      expect(BudgetStatus.levelFor(1.00), BudgetLevel.danger);
      expect(BudgetStatus.levelFor(1.01), BudgetLevel.exceeded);
    });

    test('statuses compute spent and remaining from expenses of that month only', () {
      final txs = [
        tx(200000, DateTime(2026, 11, 2)),
        tx(100000, DateTime(2026, 11, 3), category: coffee),
        tx(999999, DateTime(2026, 10, 30)), // previous month: ignored
        tx(5000000, DateTime(2026, 11, 1), category: salary), // income: ignored
      ];
      final statuses = BudgetCalculator.statuses(
        budgets: [b(null, 400000, 2026, 11), b(food.id, 250000, 2026, 11)],
        categories: [food, coffee, salary],
        transactions: txs,
        year: 2026,
        month: 11,
      );
      final overall = statuses.first;
      expect(overall.isOverall, isTrue);
      expect(overall.spent, 300000);
      expect(overall.remaining, 100000);
      expect(overall.percent, 75);
      expect(overall.level, BudgetLevel.caution);
      final foodStatus = statuses[1];
      expect(foodStatus.spent, 200000);
      expect(foodStatus.percent, 80);
    });
  });
}
