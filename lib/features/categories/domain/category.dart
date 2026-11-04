import 'package:flutter/widgets.dart';

import '../../../core/constants/category_style.dart';
import '../../../core/constants/transaction_type.dart';

class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  final int id;
  final String name;
  final String iconKey;
  final int colorValue;
  final TransactionType type;
  final bool isDefault;

  Color get color => Color(colorValue);
  IconData get icon => iconForKey(iconKey);

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.iconKey == iconKey &&
      other.colorValue == colorValue &&
      other.type == type &&
      other.isDefault == isDefault;

  @override
  int get hashCode => Object.hash(id, name, iconKey, colorValue, type, isDefault);
}

/// Thrown for user-correctable problems (duplicate name, etc.).
class CategoryException implements Exception {
  const CategoryException(this.message);
  final String message;
  @override
  String toString() => message;
}
