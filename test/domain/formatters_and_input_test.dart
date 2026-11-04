import 'package:dhuwitku/core/constants/app_constants.dart';
import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/core/utils/formatters.dart';
import 'package:dhuwitku/core/widgets/amount_input_formatter.dart';
import 'package:dhuwitku/features/transactions/domain/amount_input.dart';
import 'package:dhuwitku/features/transactions/domain/finance_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting(appLocale));

  group('MoneyFormatter', () {
    final money = MoneyFormatter();
    test('formats Rupiah with dot grouping', () {
      expect(money.format(15000), 'Rp 15.000');
      expect(money.format(0), 'Rp 0');
      expect(money.format(1250000), 'Rp 1.250.000');
      expect(money.format(-50000), '-Rp 50.000');
    });
    test('signed amounts', () {
      expect(money.signed(25000, positive: true), '+Rp 25.000');
      expect(money.signed(25000, positive: false), '-Rp 25.000');
    });
    test('compact numbers', () {
      expect(compactNumber(950), '950');
      expect(compactNumber(15000), '15rb');
      expect(compactNumber(1500000), '1,5jt');
      expect(compactNumber(2000000000), '2M');
    });
  });

  test('date format is DD MMM YYYY in Indonesian', () {
    expect(DateFormats.date.format(DateTime(2026, 8, 4)), '04 Agu 2026');
    expect(relativeDayLabel(DateTime(2026, 11, 4, 9), now: DateTime(2026, 11, 4, 20)), 'Hari ini');
    expect(relativeDayLabel(DateTime(2026, 11, 3, 23), now: DateTime(2026, 11, 4, 1)), 'Kemarin');
  });

  group('AmountInput (keypad)', () {
    test('typing 1, 5, 000 gives 15.000', () {
      final a = const AmountInput().appendDigit(1).appendDigit(5).appendThousand();
      expect(a.value, 15000);
    });
    test('leading zero is ignored and 000 on empty does nothing', () {
      expect(const AmountInput().appendDigit(0).appendDigit(7).value, 7);
      expect(const AmountInput().appendThousand().value, 0);
    });
    test('backspace and clear', () {
      expect(const AmountInput(25000).backspace().value, 2500);
      expect(const AmountInput(5).backspace().value, 0);
      expect(const AmountInput(99000).clear().value, 0);
    });
    test('caps at the maximum number of digits', () {
      var a = const AmountInput();
      for (var i = 0; i < 20; i++) {
        a = a.appendDigit(9);
      }
      expect(a.value, AppLimits.maxAmount);
      expect(a.appendThousand().value, AppLimits.maxAmount);
    });
  });

  group('GroupedDigitsFormatter', () {
    final f = GroupedDigitsFormatter();
    TextEditingValue type(String text) =>
        f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text));
    test('groups digits while typing', () {
      expect(type('1500000').text, '1.500.000');
      expect(type('00120').text, '120');
      expect(type('abc').text, '');
      expect(parseGroupedDigits('1.500.000'), 1500000);
    });
  });

  group('TransactionDraft.validate', () {
    TransactionDraft draft({int amount = 15000, int? categoryId = 1, String? note}) => TransactionDraft(
          type: TransactionType.expense,
          amount: amount,
          categoryId: categoryId,
          date: DateTime.now(),
          description: note,
        );
    test('accepts a minimal valid draft', () => expect(draft().validate(), isNull));
    test('rejects zero amount', () => expect(draft(amount: 0).validate(), isNotNull));
    test('rejects missing category', () => expect(draft(categoryId: null).validate(), isNotNull));
    test('rejects overly long notes', () => expect(draft(note: 'x' * 201).validate(), isNotNull));
    test('blank note becomes null', () => expect(draft(note: '   ').normalizedDescription, isNull));
  });
}
