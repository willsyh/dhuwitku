import 'package:dhuwitku/core/constants/transaction_type.dart';
import 'package:dhuwitku/features/categories/domain/category.dart';
import 'package:dhuwitku/features/transactions/domain/finance_transaction.dart';

const food = Category(id: 1, name: 'Makan', iconKey: 'restaurant', colorValue: 0xFFF97316, type: TransactionType.expense);
const coffee = Category(id: 2, name: 'Kopi', iconKey: 'coffee', colorValue: 0xFF92400E, type: TransactionType.expense);
const fuel = Category(id: 3, name: 'Bensin', iconKey: 'fuel', colorValue: 0xFFEF4444, type: TransactionType.expense);
const salary = Category(id: 10, name: 'Gaji', iconKey: 'salary', colorValue: 0xFF22C55E, type: TransactionType.income);

var _nextId = 1;

FinanceTransaction tx(
  int amount,
  DateTime date, {
  Category category = food,
  String? note,
  String? method,
  int? id,
}) {
  return FinanceTransaction(
    id: id ?? _nextId++,
    type: category.type,
    amount: amount,
    category: category,
    date: date,
    description: note,
    paymentMethod: method,
    createdAt: date,
    updatedAt: date,
  );
}
