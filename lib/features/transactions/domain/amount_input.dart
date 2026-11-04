import '../../../core/constants/app_constants.dart';

/// Keypad entry state for the amount field. Immutable; whole units only.
class AmountInput {
  const AmountInput([this.value = 0]);
  final int value;

  int get _digits => value == 0 ? 0 : value.toString().length;

  AmountInput appendDigit(int digit) {
    assert(digit >= 0 && digit <= 9);
    if (value == 0) return AmountInput(digit);
    if (_digits >= AppLimits.maxAmountDigits) return this;
    return AmountInput(value * 10 + digit);
  }

  /// "000" key: multiplies by 1000 when it still fits; ignored when empty.
  AmountInput appendThousand() {
    if (value == 0) return this;
    if (_digits + 3 > AppLimits.maxAmountDigits) return this;
    return AmountInput(value * 1000);
  }

  AmountInput backspace() => AmountInput(value ~/ 10);

  AmountInput clear() => const AmountInput();
}
