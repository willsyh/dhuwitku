import '../../l10n/l10n.dart';

/// Whether money came in or went out. Stored as its [name] in the database.
enum TransactionType {
  expense,
  income;

  String get label => switch (this) {
        TransactionType.expense => l10n.typeExpense,
        TransactionType.income => l10n.typeIncome,
      };

  static TransactionType fromName(String value) =>
      TransactionType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => throw ArgumentError.value(value, 'value', 'Unknown transaction type'),
      );
}
