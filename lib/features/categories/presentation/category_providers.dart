import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/transaction_type.dart';
import '../../../core/database/database_provider.dart';
import '../data/category_repository.dart';
import '../domain/category.dart';

final categoryRepositoryProvider =
    Provider((ref) => CategoryRepository(ref.watch(databaseProvider)));

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
);

final categoriesByTypeProvider = Provider.family<List<Category>, TransactionType>((ref, type) {
  final all = ref.watch(categoriesProvider).value ?? const [];
  return all.where((c) => c.type == type).toList();
});
