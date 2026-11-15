import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/core/database/default_categories.dart';
import 'package:dhuwitku/core/utils/formatters.dart';
import 'package:dhuwitku/features/assistant/domain/assistant_intent.dart';
import 'package:dhuwitku/features/assistant/domain/intent_parser.dart';
import 'package:dhuwitku/features/categories/domain/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  // Wednesday 18 Nov 2026, 19:30
  final now = DateTime(2026, 11, 18, 19, 30);
  final categories = [
    for (final (i, c) in defaultCategories.indexed)
      Category(id: i + 1, name: c.name, iconKey: c.icon, colorValue: c.color, type: c.type, isDefault: true),
    const Category(id: 99, name: 'Skincare', iconKey: 'other', colorValue: 0, type: TransactionType.expense),
  ];
  final parser = IntentParser(categories: categories, now: now);
  AssistantIntent p(String s) => parser.parse(s);
  AddTransactionIntent add(String s) => p(s) as AddTransactionIntent;

  group('add transaction', () {
    test('amount formats', () {
      expect(add('kopi 25rb').amount, 25000);
      expect(add('kopi 25 ribu').amount, 25000);
      expect(add('kopi 25k').amount, 25000);
      expect(add('makan 25.000').amount, 25000);
      expect(add('makan 25000').amount, 25000);
      expect(add('makan Rp25.000').amount, 25000);
      expect(add('gaji 6,5jt').amount, 6500000);
      expect(add('gaji 6.5 juta').amount, 6500000);
      expect(add('bonus 1,25 jt').amount, 1250000);
      expect(add('belanja 1.500rb').amount, 1500000);
    });

    test('category, type and description', () {
      final kopi = add('kopi 25rb');
      expect(kopi.category?.name, 'Kopi');
      expect(kopi.type, TransactionType.expense);
      expect(kopi.description, isNull); // just the category name

      final nasi = add('nasi padang 25rb');
      expect(nasi.category?.name, 'Makan');
      expect(nasi.description, 'Nasi padang');

      expect(add('ngopi 20rb').category?.name, 'Kopi');
      expect(add('ojol 15rb').category?.name, 'Transportasi');
      expect(add('isi bensin 50rb').category?.name, 'Bensin');
      expect(add('beli skincare 120rb').category?.name, 'Skincare'); // custom category
    });

    test('income', () {
      final gaji = add('gaji 6,5jt');
      expect(gaji.type, TransactionType.income);
      expect(gaji.category?.name, 'Gaji');
      expect(add('dapat fee proyek 2jt').category?.name, 'Freelance');
      expect(add('terima 500rb').type, TransactionType.income);
      // "Lainnya" exists for both types; income words pick the income one.
      expect(add('pemasukan lainnya 100rb').category?.type, TransactionType.income);
    });

    test('missing category stays null so the bot can ask', () {
      final r = add('250rb');
      expect(r.amount, 250000);
      expect(r.category, isNull);
    });

    test('quantities are not amounts', () {
      final r = add('beli 2 kopi 30rb');
      expect(r.amount, 30000);
      expect(r.category?.name, 'Kopi');
    });

    test('payment method', () {
      expect(add('parkir 5000 tunai').paymentMethod, 'Tunai');
      expect(add('kopi 25rb pakai gopay').paymentMethod, 'E-Wallet');
      expect(add('makan 40rb qris').paymentMethod, 'QRIS');
      expect(add('gaji 6,5jt kemarin transfer').paymentMethod, 'Transfer');
    });

    test('dates', () {
      expect(add('kopi 25rb').date, now);
      expect(add('kopi 25rb tadi pagi').date, now);
      expect(add('makan 30rb kemarin').date, DateTime(2026, 11, 17, 12));
      expect(add('makan 30rb 2 hari lalu').date, DateTime(2026, 11, 16, 12));
      expect(add('bensin 50rb senin').date, DateTime(2026, 11, 16, 12));
      expect(add('tagihan listrik 350rb tgl 5').date, DateTime(2026, 11, 5, 12));
      // Day 25 of this month is still ahead -> last month.
      expect(add('gaji 6jt tgl 25').date, DateTime(2026, 10, 25, 12));
      expect(add('makan 30rb 10/11').date, DateTime(2026, 11, 10, 12));
      // Date numbers are never taken as the amount.
      expect(add('makan 30rb 10/11').amount, 30000);
      expect(add('makan 30rb 2 hari lalu').amount, 30000);
    });

    test('"ganti oli" is a new expense, not an edit', () {
      final r = add('ganti oli 150rb');
      expect(r.amount, 150000);
      expect(r.description, 'Ganti oli');
    });
  });

  group('questions', () {
    test('spending totals with ranges', () {
      final q = p('pengeluaran bulan ini berapa?') as QuerySpendingIntent;
      expect(q.type, TransactionType.expense);
      expect(q.range.label, 'bulan ini');
      expect(q.range.start, DateTime(2026, 11));

      final w = p('kopi minggu ini') as QuerySpendingIntent;
      expect(w.category?.name, 'Kopi');
      expect(w.range.start, DateTime(2026, 11, 16)); // Monday
      expect(w.range.end, DateTime(2026, 11, 23));

      expect((p('berapa pengeluaran kemarin') as QuerySpendingIntent).range.start,
          DateTime(2026, 11, 17));
      expect((p('pengeluaran bulan lalu') as QuerySpendingIntent).range.start, DateTime(2026, 10));
      expect((p('pengeluaran minggu lalu') as QuerySpendingIntent).range.start, DateTime(2026, 11, 9));
      expect((p('total 7 hari terakhir') as QuerySpendingIntent).range.start, DateTime(2026, 11, 12));
      expect((p('makan bulan oktober') as QuerySpendingIntent).range.label, 'Oktober 2026');
      // December hasn't happened yet this year -> last December.
      expect((p('pengeluaran desember') as QuerySpendingIntent).range.start, DateTime(2025, 12));
    });

    test('income questions', () {
      final q = p('pemasukan bulan ini?') as QuerySpendingIntent;
      expect(q.type, TransactionType.income);
      expect((p('gaji bulan lalu berapa') as QuerySpendingIntent).type, TransactionType.income);
    });

    test('a question with an amount-like number is still a question', () {
      expect(p('berapa kali beli kopi bulan ini?'), isA<QuerySpendingIntent>());
    });

    test('balance, budget, top category, tips', () {
      expect(p('saldo?'), isA<QueryBalanceIntent>());
      expect(p('sisa uang aku berapa'), isA<QueryBalanceIntent>());
      expect(p('sisa anggaran?'), isA<QueryBudgetIntent>());
      expect((p('anggaran kopi') as QueryBudgetIntent).category?.name, 'Kopi');
      expect(p('kategori terbesar bulan ini'), isA<QueryTopCategoryIntent>());
      expect(p('paling boros buat apa'), isA<QueryTopCategoryIntent>());
      expect(p('tips hemat dong'), isA<AskTipsIntent>());
      expect(p('aku boros ga?'), isA<AskTipsIntent>());
    });
  });

  group('edit & delete', () {
    test('delete last', () {
      expect(p('hapus transaksi terakhir'), isA<DeleteLastIntent>());
      expect(p('batalkan yang tadi'), isA<DeleteLastIntent>());
      expect(p('undo'), isA<DeleteLastIntent>());
    });

    test('edit amount without touching the date', () {
      final e = p('ubah yang tadi jadi 30rb') as EditLastIntent;
      expect(e.amount, 30000);
      expect(e.date, isNull);
      expect(e.category, isNull);
    });

    test('edit takes the amount after "jadi"', () {
      final e = p('ralat dari 25rb jadi 28rb') as EditLastIntent;
      expect(e.amount, 28000);
    });

    test('edit category and date', () {
      expect((p('ganti kategorinya jadi makan') as EditLastIntent).category?.name, 'Makan');
      expect((p('ubah tanggalnya jadi kemarin') as EditLastIntent).date, DateTime(2026, 11, 17, 12));
      expect((p('salah, harusnya 15rb') as EditLastIntent).amount, 15000);
    });

    test('edit with nothing to change', () {
      expect((p('salah') as EditLastIntent).hasChanges, isFalse);
    });
  });

  test('help and unknown', () {
    expect(p('halo'), isA<HelpIntent>());
    expect(p('bisa apa aja'), isA<HelpIntent>());
    expect(p(''), isA<HelpIntent>());
    expect(p('cuaca besok gimana'), isA<UnknownIntent>());
    expect(p('kamu siapa'), isA<UnknownIntent>());
  });
}
