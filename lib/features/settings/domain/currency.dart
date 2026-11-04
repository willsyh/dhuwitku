class CurrencyOption {
  const CurrencyOption(this.code, this.symbol, this.name);
  final String code;
  final String symbol;
  final String name;
}

/// Display currencies. Amounts are stored as whole units, so only the symbol
/// changes; no conversion is applied.
const currencyOptions = <CurrencyOption>[
  CurrencyOption('IDR', 'Rp', 'Rupiah Indonesia'),
  CurrencyOption('USD', r'$', 'Dolar AS'),
  CurrencyOption('SGD', r'S$', 'Dolar Singapura'),
  CurrencyOption('MYR', 'RM', 'Ringgit Malaysia'),
  CurrencyOption('EUR', '€', 'Euro'),
];

CurrencyOption currencyFor(String? code) =>
    currencyOptions.firstWhere((c) => c.code == code, orElse: () => currencyOptions.first);
