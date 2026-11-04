import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../utils/formatters.dart';

/// Formats a text field as grouped digits (15.000) while typing.
class GroupedDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.length > AppLimits.maxAmountDigits) return oldValue;
    final text = groupDigits(int.parse(digits));
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

int parseGroupedDigits(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}
