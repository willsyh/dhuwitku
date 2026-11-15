import '../../../core/constants/transaction_type.dart';
import '../../categories/domain/category.dart';

/// A date range for questions, half-open [start, end), with a display label
/// ("bulan ini", "minggu lalu", "Oktober 2026").
class QueryRange {
  const QueryRange(this.start, this.end, this.label);
  final DateTime start;
  final DateTime end;
  final String label;

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  @override
  bool operator ==(Object other) =>
      other is QueryRange && other.start == start && other.end == end && other.label == label;

  @override
  int get hashCode => Object.hash(start, end, label);

  @override
  String toString() => 'QueryRange($label, $start – $end)';
}

/// What the user asked for, parsed from one chat message.
sealed class AssistantIntent {
  const AssistantIntent();
}

/// "kopi 25rb", "gaji 6,5jt kemarin". [category] null means we must ask.
class AddTransactionIntent extends AssistantIntent {
  const AddTransactionIntent({
    required this.type,
    required this.amount,
    required this.date,
    this.category,
    this.description,
    this.paymentMethod,
  });

  final TransactionType type;
  final int amount;
  final DateTime date;
  final Category? category;
  final String? description;
  final String? paymentMethod;

  AddTransactionIntent withCategory(Category c) => AddTransactionIntent(
        type: c.type,
        amount: amount,
        date: date,
        category: c,
        description: description,
        paymentMethod: paymentMethod,
      );
}

/// "pengeluaran bulan ini?", "kopi minggu ini berapa?"
class QuerySpendingIntent extends AssistantIntent {
  const QuerySpendingIntent({required this.range, required this.type, this.category});
  final QueryRange range;
  final TransactionType type;
  final Category? category;
}

/// "saldo?"
class QueryBalanceIntent extends AssistantIntent {
  const QueryBalanceIntent();
}

/// "sisa anggaran?", "anggaran kopi"
class QueryBudgetIntent extends AssistantIntent {
  const QueryBudgetIntent({this.category});
  final Category? category;
}

/// "kategori terbesar bulan ini?"
class QueryTopCategoryIntent extends AssistantIntent {
  const QueryTopCategoryIntent({required this.range});
  final QueryRange range;
}

/// "tips hemat"
class AskTipsIntent extends AssistantIntent {
  const AskTipsIntent();
}

/// "hapus transaksi terakhir"
class DeleteLastIntent extends AssistantIntent {
  const DeleteLastIntent();
}

/// "ubah yang tadi jadi 30rb", "ganti kategorinya jadi makan". All null =
/// nothing understood to change.
class EditLastIntent extends AssistantIntent {
  const EditLastIntent({this.amount, this.category, this.date});
  final int? amount;
  final Category? category;
  final DateTime? date;

  bool get hasChanges => amount != null || category != null || date != null;
}

class HelpIntent extends AssistantIntent {
  const HelpIntent();
}

class UnknownIntent extends AssistantIntent {
  const UnknownIntent();
}
