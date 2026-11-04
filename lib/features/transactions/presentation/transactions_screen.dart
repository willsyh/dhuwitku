import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/finance_transaction.dart';
import '../domain/transaction_filter.dart';
import 'quick_add_sheet.dart';
import 'transaction_detail_sheet.dart';
import 'transaction_providers.dart';
import 'transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  TransactionFilterNotifier get _filter => ref.read(transactionFilterProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(transactionFilterProvider);
    final async = ref.watch(filteredTransactionsProvider);
    final hasAny = (ref.watch(transactionsProvider).value ?? const []).isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          IconButton(
            tooltip: filter.sort == SortOrder.newestFirst ? 'Terbaru dulu' : 'Terlama dulu',
            icon: Icon(filter.sort == SortOrder.newestFirst
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded),
            onPressed: () => _filter.update((f) => f.copyWith(
                  sort: f.sort == SortOrder.newestFirst ? SortOrder.oldestFirst : SortOrder.newestFirst,
                )),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onChanged: (v) => _filter.update((f) => f.copyWith(query: v)),
              decoration: InputDecoration(
                hintText: 'Cari catatan atau kategori',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          _filter.update((f) => f.copyWith(query: ''));
                        },
                      ),
              ),
            ),
          ),
          _FilterBar(filter: filter),
          Expanded(
            child: async.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(error: e),
              data: (list) {
                if (list.isEmpty) {
                  return hasAny
                      ? EmptyState(
                          icon: Icons.filter_alt_off_rounded,
                          title: 'Tidak ada transaksi yang cocok',
                          message: 'Coba ubah kata kunci atau filter.',
                          action: OutlinedButton(
                            onPressed: () {
                              _search.clear();
                              _filter.update((f) => TransactionFilter(sort: f.sort));
                            },
                            child: const Text('Reset filter'),
                          ),
                        )
                      : EmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum ada transaksi',
                          message: 'Tekan tombol + untuk mencatat transaksi pertamamu.',
                          action: FilledButton.icon(
                            onPressed: () => showQuickAddSheet(context),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Catat Transaksi'),
                          ),
                        );
                }
                return _GroupedList(transactions: list, showSummary: !filter.isEmpty);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({required this.filter});
  final TransactionFilter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(transactionFilterProvider.notifier);
    final categories = ref.watch(categoriesProvider).value ?? const <Category>[];
    final selectedCategory = categories.where((c) => c.id == filter.categoryId).firstOrNull;
    final range = filter.dateRange;

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final t in [null, ...TransactionType.values])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(t?.label ?? 'Semua'),
                selected: filter.type == t,
                onSelected: (_) => notifier.update((f) => f.copyWith(
                      type: () => t,
                      // Keep the category only if it matches the new type.
                      categoryId: () =>
                          t == null || selectedCategory?.type == t ? f.categoryId : null,
                    )),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: Icon(selectedCategory?.icon ?? Icons.category_outlined, size: 16),
              label: Text(selectedCategory?.name ?? 'Kategori'),
              selected: selectedCategory != null,
              showCheckmark: false,
              onSelected: (_) async {
                final picked = await _pickCategory(context, categories, filter);
                if (picked == null) return;
                notifier.update((f) => f.copyWith(categoryId: () => picked == -1 ? null : picked));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              avatar: const Icon(Icons.date_range_rounded, size: 16),
              label: Text(range == null
                  ? 'Tanggal'
                  : '${DateFormats.dayMonth.format(range.start)} – ${DateFormats.dayMonth.format(range.end)}'),
              selected: range != null,
              showCheckmark: false,
              onSelected: (_) async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(now.year + 1, 12, 31),
                  initialDateRange: range,
                  helpText: 'Pilih rentang tanggal',
                  saveText: 'Terapkan',
                );
                if (picked != null) notifier.update((f) => f.copyWith(dateRange: () => picked));
              },
            ),
          ),
          if (filter.activeCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ActionChip(
                avatar: const Icon(Icons.close_rounded, size: 16),
                label: const Text('Reset'),
                onPressed: () => notifier.update((f) => TransactionFilter(query: f.query, sort: f.sort)),
              ),
            ),
        ],
      ),
    );
  }

  /// Returns a category id, -1 for "all", or null when dismissed.
  Future<int?> _pickCategory(
    BuildContext context,
    List<Category> all,
    TransactionFilter filter,
  ) {
    final options = filter.type == null ? all : all.where((c) => c.type == filter.type).toList();
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (context, controller) => ListView(
          controller: controller,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: const Text('Semua kategori'),
              selected: filter.categoryId == null,
              onTap: () => Navigator.pop(context, -1),
            ),
            for (final c in options)
              ListTile(
                leading: CategoryAvatar(icon: c.icon, color: c.color, size: 36),
                title: Text(c.name),
                subtitle: Text(c.type.label),
                selected: c.id == filter.categoryId,
                onTap: () => Navigator.pop(context, c.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.transactions, required this.showSummary});
  final List<FinanceTransaction> transactions;
  final bool showSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = ref.watch(moneyFormatterProvider);
    final theme = Theme.of(context);
    final groups = groupByDay(transactions);
    final items = <Object>[
      for (final g in groups) ...[g, ...g.transactions],
    ];

    final totalIncome = transactions.where((t) => t.isIncome).fold(0, (s, t) => s + t.amount);
    final totalExpense = transactions.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      itemCount: items.length + (showSummary ? 1 : 0),
      itemBuilder: (context, index) {
        if (showSummary && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text('${transactions.length} transaksi')),
                  Text('+${money.format(totalIncome)}',
                      style: const TextStyle(color: AppColors.income, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Text('-${money.format(totalExpense)}',
                      style: const TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }
        final item = items[index - (showSummary ? 1 : 0)];
        if (item is DayGroup) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _dayHeader(item.day),
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
                if (item.income > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text('+${money.format(item.income)}',
                        style: theme.textTheme.labelLarge?.copyWith(color: AppColors.income)),
                  ),
                if (item.expense > 0)
                  Text('-${money.format(item.expense)}',
                      style: theme.textTheme.labelLarge?.copyWith(color: AppColors.expense)),
              ],
            ),
          );
        }
        final t = item as FinanceTransaction;
        return Dismissible(
          key: ValueKey('tx-${t.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: AppColors.expense.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense),
          ),
          // Deletion happens inside; the list then updates from the database
          // stream, so the Dismissible itself never completes its dismissal.
          confirmDismiss: (_) async {
            await confirmDeleteTransaction(context, ref, t);
            return false;
          },
          child: AppCard(
            padding: EdgeInsets.zero,
            child: TransactionTile(transaction: t, showDate: false),
          ),
        ).withBottomGap();
      },
    );
  }

  static String _dayHeader(DateTime day) {
    final rel = relativeDayLabel(day);
    return rel == DateFormats.date.format(day) ? DateFormats.dayDate.format(day) : '$rel · ${DateFormats.date.format(day)}';
  }
}

extension on Widget {
  Widget withBottomGap() => Padding(padding: const EdgeInsets.only(bottom: 6), child: this);
}
