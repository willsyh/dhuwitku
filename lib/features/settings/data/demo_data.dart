import 'dart:math';

import '../../../core/constants/transaction_type.dart';
import '../../categories/domain/category.dart';
import '../../transactions/domain/finance_transaction.dart';

/// Sample transactions for the optional, clearly labeled demo mode. Every row
/// is inserted with `is_demo = 1` and can be removed in one action.
abstract final class DemoData {
  static List<TransactionDraft> build(List<Category> categories, {DateTime? now, int seed = 7}) {
    final today = now ?? DateTime.now();
    final rnd = Random(seed);

    Category? find(String name, TransactionType type) =>
        categories.where((c) => c.type == type && c.name == name).firstOrNull ??
        categories.where((c) => c.type == type).firstOrNull;

    final drafts = <TransactionDraft>[];
    void add(String cat, TransactionType type, int amount, DateTime date,
        {String? note, String? method}) {
      final c = find(cat, type);
      if (c == null || date.isAfter(today)) return;
      drafts.add(TransactionDraft(
        type: type,
        amount: amount,
        categoryId: c.id,
        date: date,
        description: note,
        paymentMethod: method,
      ));
    }

    int pick(List<int> options) => options[rnd.nextInt(options.length)];
    const e = TransactionType.expense;
    const i = TransactionType.income;

    for (var d = 89; d >= 0; d--) {
      final day = DateTime(today.year, today.month, today.day - d);
      DateTime at(int h, int m) => DateTime(day.year, day.month, day.day, h, m);

      add('Makan', e, pick([15000, 18000, 22000, 25000]), at(12, 10),
          note: ['Nasi padang', 'Mie ayam', 'Nasi goreng', 'Soto'][rnd.nextInt(4)], method: 'QRIS');
      if (rnd.nextDouble() < 0.7) {
        add('Kopi', e, pick([18000, 22000, 28000]), at(8, 30), note: 'Kopi susu', method: 'E-Wallet');
      }
      if (rnd.nextDouble() < 0.6) {
        add('Makan', e, pick([20000, 30000, 35000]), at(19, 15), note: 'Makan malam', method: 'Tunai');
      }
      if (rnd.nextDouble() < 0.3) add('Parkir', e, pick([2000, 3000, 5000]), at(9, 0), method: 'Tunai');
      if (day.weekday == DateTime.monday || day.weekday == DateTime.thursday) {
        add('Bensin', e, pick([30000, 50000]), at(7, 45), note: 'Pertalite', method: 'Tunai');
      }
      if (day.weekday == DateTime.saturday) {
        add('Belanja Harian', e, pick([85000, 120000, 150000]), at(16, 0), note: 'Belanja mingguan', method: 'Debit');
        if (rnd.nextBool()) add('Hiburan', e, pick([50000, 75000]), at(20, 0), note: 'Nonton', method: 'E-Wallet');
      }
      if (day.day == 25) add('Gaji', i, 6500000, at(9, 0), note: 'Gaji bulanan', method: 'Transfer');
      if (day.day == 5) add('Tagihan', e, 350000, at(10, 0), note: 'Listrik & internet', method: 'Transfer');
      if (day.day == 15 && rnd.nextBool()) {
        add('Freelance', i, pick([750000, 1200000]), at(14, 0), note: 'Proyek desain', method: 'Transfer');
      }
    }
    return drafts;
  }
}
