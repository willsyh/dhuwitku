import 'dart:convert';
import 'dart:io';

import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/core/database/default_categories.dart';
import 'package:dhuwitku/core/utils/formatters.dart';
import 'package:dhuwitku/features/assistant/domain/assistant_intent.dart';
import 'package:dhuwitku/features/assistant/domain/intent_parser.dart';
import 'package:dhuwitku/features/categories/domain/category.dart';
import 'package:dhuwitku/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting());
  tearDown(() => applyLanguage(AppLanguage.id));

  group('translation files', () {
    Map<String, dynamic> arb(String code) =>
        jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;
    final template = arb('id').keys.where((k) => !k.startsWith('@')).toSet();

    for (final lang in AppLanguage.values) {
      test('${lang.code} has exactly the same keys as Indonesian', () {
        final keys = arb(lang.code).keys.where((k) => !k.startsWith('@')).toSet();
        expect(keys.difference(template), isEmpty, reason: 'extra keys');
        expect(template.difference(keys), isEmpty, reason: 'missing keys');
      });
    }
  });

  test('default categories and payment methods follow the language', () {
    const food = Category(id: 1, name: 'Makan', iconKey: 'restaurant', colorValue: 0, type: TransactionType.expense, isDefault: true);
    const custom = Category(id: 2, name: 'Makan', iconKey: 'restaurant', colorValue: 0, type: TransactionType.expense);
    expect(food.label, 'Makan');
    applyLanguage(AppLanguage.en);
    expect(food.label, 'Food');
    expect(custom.label, 'Makan'); // user-made categories keep their name
    applyLanguage(AppLanguage.ja);
    expect(food.label, '食費');
    applyLanguage(AppLanguage.ko);
    expect(TransactionType.income.label, '수입');
  });

  test('short numbers per language', () {
    expect(compactNumber(15000, language: AppLanguage.id), '15rb');
    expect(compactNumber(1500000, language: AppLanguage.id), '1,5jt');
    expect(compactNumber(15000, language: AppLanguage.en), '15k');
    expect(compactNumber(1500000, language: AppLanguage.en), '1.5M');
    expect(compactNumber(15000, language: AppLanguage.zh), '1.5万');
    expect(compactNumber(200000000, language: AppLanguage.ja), '2億');
    expect(compactNumber(1500000, language: AppLanguage.ko), '150만');
  });

  test('dates follow the language, Rupiah stays the same', () {
    final d = DateTime(2026, 11, 15);
    expect(DateFormats.date.format(d), '15 Nov 2026');
    applyLanguage(AppLanguage.en);
    expect(DateFormats.date.format(d), 'Nov 15, 2026');
    expect(relativeDayLabel(d, now: d), 'Today');
    applyLanguage(AppLanguage.zh);
    expect(DateFormats.date.format(d), '2026年11月15日');
    expect(MoneyFormatter().format(15000), 'Rp 15.000');
  });

  group('assistant understands basic English', () {
    final now = DateTime(2026, 11, 18, 19, 30); // Wednesday
    final categories = [
      for (final (i, c) in defaultCategories.indexed)
        Category(id: i + 1, name: c.name, iconKey: c.icon, colorValue: c.color, type: c.type, isDefault: true),
    ];
    AssistantIntent p(String s) => IntentParser(categories: categories, now: now).parse(s);

    test('recording', () {
      final coffee = p('coffee 25k') as AddTransactionIntent;
      expect(coffee.amount, 25000);
      expect(coffee.category?.name, 'Kopi');

      final salary = p('salary 6.5 million yesterday transfer') as AddTransactionIntent;
      expect(salary.amount, 6500000);
      expect(salary.type, TransactionType.income);
      expect(salary.category?.name, 'Gaji');
      expect(salary.date, DateTime(2026, 11, 17, 12));
      expect(salary.paymentMethod, 'Transfer');

      expect((p('lunch 40 thousand 2 days ago') as AddTransactionIntent).date, DateTime(2026, 11, 16, 12));
      expect((p('fuel 50k monday') as AddTransactionIntent).category?.name, 'Bensin');
    });

    test('"m" is million in English, miliar in Indonesian', () {
      expect((p('bonus 1.5m') as AddTransactionIntent).amount, 1500000000);
      applyLanguage(AppLanguage.en);
      expect((p('bonus 1.5m') as AddTransactionIntent).amount, 1500000);
    });

    test('translated category names are understood', () {
      applyLanguage(AppLanguage.en);
      expect((p('groceries 120k') as AddTransactionIntent).category?.name, 'Belanja Harian');
      expect((p('entertainment 75k') as AddTransactionIntent).category?.name, 'Hiburan');
    });

    test('questions and range labels in the active language', () {
      applyLanguage(AppLanguage.en);
      final q = p('how much did I spend this month?') as QuerySpendingIntent;
      expect(q.range.label, 'this month');
      final w = p('coffee this week') as QuerySpendingIntent;
      expect(w.category?.name, 'Kopi');
      expect(w.range.start, DateTime(2026, 11, 16));
      expect((p('income last month') as QuerySpendingIntent).type, TransactionType.income);
      expect((p('spending in october') as QuerySpendingIntent).range.start, DateTime(2026, 10));
      expect(p('balance?'), isA<QueryBalanceIntent>());
      expect(p('budget left?'), isA<QueryBudgetIntent>());
      expect(p('biggest category'), isA<QueryTopCategoryIntent>());
      expect(p('saving tips'), isA<AskTipsIntent>());
    });

    test('edit and delete', () {
      expect(p('delete last transaction'), isA<DeleteLastIntent>());
      final e = p('change the last one to 30k') as EditLastIntent;
      expect(e.amount, 30000);
      expect(e.date, isNull);
      expect((p('change category to food') as EditLastIntent).category?.name, 'Makan');
      expect((p('change date to yesterday') as EditLastIntent).date, DateTime(2026, 11, 17, 12));
    });
  });
}
