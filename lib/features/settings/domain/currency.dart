import '../../../l10n/l10n.dart';

class CurrencyOption {
  const CurrencyOption(this.code, this.symbol);
  final String code;
  final String symbol;

  /// Currency name in the active language.
  String get name => switch (code) {
        'USD' => l10n.currencyUsd,
        'SGD' => l10n.currencySgd,
        'MYR' => l10n.currencyMyr,
        'EUR' => l10n.currencyEur,
        _ => l10n.currencyIdr,
      };
}

/// Display currencies. Amounts are stored as whole units, so only the symbol
/// changes; no conversion is applied.
const currencyOptions = <CurrencyOption>[
  CurrencyOption('IDR', 'Rp'),
  CurrencyOption('USD', r'$'),
  CurrencyOption('SGD', r'S$'),
  CurrencyOption('MYR', 'RM'),
  CurrencyOption('EUR', '€'),
];

CurrencyOption currencyFor(String? code) =>
    currencyOptions.firstWhere((c) => c.code == code, orElse: () => currencyOptions.first);
