import 'package:flutter/material.dart' show DateTimeRange;

import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
import 'finance_transaction.dart';

enum SortOrder { newestFirst, oldestFirst }

class TransactionFilter {
  const TransactionFilter({
    this.query = '',
    this.type,
    this.categoryId,
    this.dateRange,
    this.sort = SortOrder.newestFirst,
  });

  final String query;
  final TransactionType? type;
  final int? categoryId;

  /// Inclusive of both start and end days.
  final DateTimeRange? dateRange;
  final SortOrder sort;

  int get activeCount =>
      (type != null ? 1 : 0) + (categoryId != null ? 1 : 0) + (dateRange != null ? 1 : 0);

  bool get isEmpty => query.trim().isEmpty && activeCount == 0;

  TransactionFilter copyWith({
    String? query,
    TransactionType? Function()? type,
    int? Function()? categoryId,
    DateTimeRange? Function()? dateRange,
    SortOrder? sort,
  }) =>
      TransactionFilter(
        query: query ?? this.query,
        type: type != null ? type() : this.type,
        categoryId: categoryId != null ? categoryId() : this.categoryId,
        dateRange: dateRange != null ? dateRange() : this.dateRange,
        sort: sort ?? this.sort,
      );

  /// Applies the filter to [all] (assumed newest-first) and sorts.
  List<FinanceTransaction> apply(List<FinanceTransaction> all) {
    final q = query.trim().toLowerCase();
    final start = dateRange == null ? null : dateOnly(dateRange!.start);
    final endExclusive =
        dateRange == null ? null : dateOnly(dateRange!.end).add(const Duration(days: 1));

    final result = all.where((t) {
      if (type != null && t.type != type) return false;
      if (categoryId != null && t.category.id != categoryId) return false;
      if (start != null && t.date.isBefore(start)) return false;
      if (endExclusive != null && !t.date.isBefore(endExclusive)) return false;
      if (q.isNotEmpty) {
        final hay = '${t.description ?? ''} ${t.category.name} ${t.paymentMethod ?? ''}'
            .toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();

    result.sort((a, b) {
      final c = a.date.compareTo(b.date);
      final byDate = c != 0 ? c : a.id.compareTo(b.id);
      return sort == SortOrder.newestFirst ? -byDate : byDate;
    });
    return result;
  }
}

class DayGroup {
  DayGroup(this.day, this.transactions);
  final DateTime day;
  final List<FinanceTransaction> transactions;

  int get expense =>
      transactions.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);
  int get income =>
      transactions.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
}

/// Groups an already-sorted list by calendar day, keeping order.
List<DayGroup> groupByDay(List<FinanceTransaction> sorted) {
  final groups = <DayGroup>[];
  for (final t in sorted) {
    final day = dateOnly(t.date);
    if (groups.isEmpty || groups.last.day != day) {
      groups.add(DayGroup(day, [t]));
    } else {
      groups.last.transactions.add(t);
    }
  }
  return groups;
}
