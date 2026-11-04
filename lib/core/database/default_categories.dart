import '../constants/transaction_type.dart';

class DefaultCategory {
  const DefaultCategory(this.name, this.icon, this.color, this.type);
  final String name;
  final String icon;
  final int color;
  final TransactionType type;
}

const defaultCategories = <DefaultCategory>[
  DefaultCategory('Makan', 'restaurant', 0xFFF97316, TransactionType.expense),
  DefaultCategory('Kopi', 'coffee', 0xFF92400E, TransactionType.expense),
  DefaultCategory('Bensin', 'fuel', 0xFFEF4444, TransactionType.expense),
  DefaultCategory('Parkir', 'parking', 0xFF3B82F6, TransactionType.expense),
  DefaultCategory('Transportasi', 'transport', 0xFF06B6D4, TransactionType.expense),
  DefaultCategory('Belanja Harian', 'groceries', 0xFF22C55E, TransactionType.expense),
  DefaultCategory('Belanja', 'shopping', 0xFFEC4899, TransactionType.expense),
  DefaultCategory('Hiburan', 'entertainment', 0xFF8B5CF6, TransactionType.expense),
  DefaultCategory('Tagihan', 'bills', 0xFFF59E0B, TransactionType.expense),
  DefaultCategory('Kesehatan', 'health', 0xFF14B8A6, TransactionType.expense),
  DefaultCategory('Lainnya', 'other', 0xFF64748B, TransactionType.expense),
  DefaultCategory('Gaji', 'salary', 0xFF22C55E, TransactionType.income),
  DefaultCategory('Uang Saku', 'allowance', 0xFF06B6D4, TransactionType.income),
  DefaultCategory('Freelance', 'freelance', 0xFF8B5CF6, TransactionType.income),
  DefaultCategory('Bisnis', 'business', 0xFFF97316, TransactionType.income),
  DefaultCategory('Investasi', 'investment', 0xFF3B82F6, TransactionType.income),
  DefaultCategory('Lainnya', 'other', 0xFF64748B, TransactionType.income),
];
