abstract final class AppInfo {
  static const name = 'Dhuwitku';
  static const version = '1.0.0';
  static const tagline = 'Catat uangmu dalam hitungan detik.';
}

abstract final class AppLimits {
  /// Largest amount accepted for a single transaction or budget (Rp 999 miliar).
  static const maxAmount = 999999999999;
  static const maxAmountDigits = 12;
  static const maxDescriptionLength = 200;
  static const maxCategoryNameLength = 40;
}

/// Optional payment methods offered in the quick-add sheet.
const paymentMethods = <String>[
  'Tunai',
  'QRIS',
  'E-Wallet',
  'Debit',
  'Kartu Kredit',
  'Transfer',
];

/// Amount shortcuts shown above the keypad.
const quickAmounts = <int>[15000, 25000, 50000, 100000];
