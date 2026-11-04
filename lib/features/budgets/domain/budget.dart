class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  final int id;

  /// Null for the overall monthly budget.
  final int? categoryId;
  final int amount;
  final int month;
  final int year;

  bool get isOverall => categoryId == null;

  /// Sortable month key, e.g. 2026 * 12 + 10.
  int get monthKey => year * 12 + (month - 1);
}

int monthKeyOf(int year, int month) => year * 12 + (month - 1);

class BudgetException implements Exception {
  const BudgetException(this.message);
  final String message;
  @override
  String toString() => message;
}
