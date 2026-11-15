/// True when [word] appears in [text] as a whole word (or phrase).
/// Both are expected in lowercase.
bool containsWord(String text, String word) =>
    RegExp('(^|[^a-z0-9])${RegExp.escape(word)}([^a-z0-9]|\$)').hasMatch(text);

/// Guesses one of `paymentMethods` from lowercase text, or null.
String? guessPaymentMethod(String lower) {
  if (containsWord(lower, 'qris')) return 'QRIS';
  if (RegExp(r'gopay|\bovo\b|\bdana\b|shopeepay|linkaja|e-wallet|ewallet').hasMatch(lower)) {
    return 'E-Wallet';
  }
  if (RegExp(r'kartu kredit|credit card|\bkredit\b|\bvisa\b|mastercard').hasMatch(lower)) {
    return 'Kartu Kredit';
  }
  if (RegExp(r'\bdebit\b|\bedc\b|\bbca\b|mandiri|\bbri\b|\bbni\b').hasMatch(lower)) return 'Debit';
  if (RegExp(r'transfer|virtual account').hasMatch(lower)) return 'Transfer';
  if (RegExp(r'\btunai\b|\bcash\b').hasMatch(lower)) return 'Tunai';
  return null;
}
