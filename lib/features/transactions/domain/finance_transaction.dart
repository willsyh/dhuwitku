import '../../../core/constants/app_constants.dart';
import '../../../core/constants/transaction_type.dart';
import '../../categories/domain/category.dart';

class FinanceTransaction {
  const FinanceTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.isDemo = false,
  });

  final int id;
  final TransactionType type;

  /// Whole Rupiah, always positive. Direction comes from [type].
  final int amount;
  final Category category;
  final DateTime date;
  final String? description;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDemo;

  bool get isExpense => type == TransactionType.expense;
  bool get isIncome => type == TransactionType.income;

  /// Positive for income, negative for expense.
  int get signedAmount => isIncome ? amount : -amount;

  /// Description if given, otherwise the category name.
  String get title {
    final d = description?.trim();
    return (d == null || d.isEmpty) ? category.name : d;
  }
}

/// Input for creating or updating a transaction.
class TransactionDraft {
  const TransactionDraft({
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.description,
    this.paymentMethod,
  });

  final TransactionType type;
  final int amount;
  final int? categoryId;
  final DateTime date;
  final String? description;
  final String? paymentMethod;

  /// Returns a user-facing error message, or null when the draft is valid.
  String? validate() {
    if (amount <= 0) return 'Masukkan jumlah lebih dari 0';
    if (amount > AppLimits.maxAmount) return 'Jumlah terlalu besar';
    if (categoryId == null) return 'Pilih kategori terlebih dahulu';
    if ((description?.length ?? 0) > AppLimits.maxDescriptionLength) {
      return 'Catatan maksimal ${AppLimits.maxDescriptionLength} karakter';
    }
    final latest = DateTime.now().add(const Duration(days: 366));
    if (date.isAfter(latest) || date.year < 2000) return 'Tanggal tidak valid';
    return null;
  }

  String? get normalizedDescription {
    final d = description?.trim();
    return (d == null || d.isEmpty) ? null : d;
  }
}

class TransactionException implements Exception {
  const TransactionException(this.message);
  final String message;
  @override
  String toString() => message;
}
