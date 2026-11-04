import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/transaction_repository.dart';
import '../domain/finance_transaction.dart';
import '../domain/transaction_filter.dart';

final transactionRepositoryProvider =
    Provider((ref) => TransactionRepository(ref.watch(databaseProvider)));

/// Every transaction, newest first. All screens derive their numbers from this
/// stream, so they update as soon as the database changes.
final transactionsProvider = StreamProvider<List<FinanceTransaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchAll(),
);

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() => const TransactionFilter();

  void update(TransactionFilter Function(TransactionFilter f) change) => state = change(state);
  void reset() => state = TransactionFilter(sort: state.sort);
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(TransactionFilterNotifier.new);

final filteredTransactionsProvider = Provider<AsyncValue<List<FinanceTransaction>>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  return ref.watch(transactionsProvider).whenData(filter.apply);
});

final hasDemoDataProvider = Provider<bool>((ref) {
  final all = ref.watch(transactionsProvider).value ?? const [];
  return all.any((t) => t.isDemo);
});
