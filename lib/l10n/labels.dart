import '../core/constants/transaction_type.dart';
import 'l10n.dart';

/// Default categories are stored with their Indonesian names. When a
/// category still has its default name, show it in the active language;
/// renamed or custom categories keep exactly what the user wrote.
String localizedDefaultCategory(String storedName, TransactionType type) {
  final l = l10n;
  return switch (storedName) {
        'Makan' => l.catFood,
        'Kopi' => l.catCoffee,
        'Bensin' => l.catFuel,
        'Parkir' => l.catParking,
        'Transportasi' => l.catTransport,
        'Belanja Harian' => l.catGroceries,
        'Belanja' => l.catShopping,
        'Hiburan' => l.catEntertainment,
        'Tagihan' => l.catBills,
        'Kesehatan' => l.catHealth,
        'Lainnya' => l.catOther,
        'Gaji' => l.catSalary,
        'Uang Saku' => l.catAllowance,
        'Freelance' => l.catFreelance,
        'Bisnis' => l.catBusiness,
        'Investasi' => l.catInvestment,
        _ => null,
      } ??
      storedName;
}

/// Payment methods are stored with their Indonesian names ('Tunai', ...).
String paymentLabel(String stored) => switch (stored) {
      'Tunai' => l10n.payCash,
      'Kartu Kredit' => l10n.payCreditCard,
      'Transfer' => l10n.payTransfer,
      'Debit' => l10n.payDebit,
      'E-Wallet' => l10n.payEwallet,
      'QRIS' => 'QRIS',
      _ => stored,
    };
