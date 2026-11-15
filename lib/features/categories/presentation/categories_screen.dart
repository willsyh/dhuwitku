import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../domain/category.dart';
import 'category_form_sheet.dart';
import 'category_providers.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this);

  TransactionType get _type =>
      _tabs.index == 0 ? TransactionType.expense : TransactionType.income;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final async = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.manageCategories),
        bottom: TabBar(
          controller: _tabs,
          tabs: [Tab(text: l.typeExpense), Tab(text: l.typeIncome)],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryFormSheet(context, type: _type),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.category),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e),
        data: (all) => TabBarView(
          controller: _tabs,
          children: [
            for (final type in TransactionType.values)
              _CategoryList(categories: all.where((c) => c.type == type).toList()),
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.categories});
  final List<Category> categories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    if (categories.isEmpty) {
      return EmptyState(icon: Icons.category_outlined, title: l.noCategories);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final c = categories[i];
        return AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          onTap: () => showCategoryFormSheet(context, type: c.type, initial: c),
          child: ListTile(
            leading: CategoryAvatar(icon: c.icon, color: c.color),
            title: Text(c.label),
            subtitle: c.isDefault ? Text(l.defaultCategory) : null,
            trailing: IconButton(
              tooltip: l.deleteCategory,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context, ref, c),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Category category) async {
    final repo = ref.read(categoryRepositoryProvider);
    if (categories.length <= 1) {
      showAppSnack(l10n.errLastCategory, kind: SnackKind.warning);
      return;
    }
    final int used;
    try {
      used = await repo.transactionCount(category.id);
    } catch (e) {
      showAppSnack(errorMessage(e), kind: SnackKind.error);
      return;
    }
    if (!context.mounted) return;

    final others = categories.where((c) => c.id != category.id).toList();
    final fallback = others.firstWhere(
      (c) => c.name.toLowerCase() == 'lainnya',
      orElse: () => others.first,
    );
    var reassignTo = fallback.id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.deleteCategoryQ(category.label)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(used == 0
                  ? context.l10n.deleteCategoryUnused
                  : context.l10n.deleteCategoryUsed(used)),
              if (used > 0) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: reassignTo,
                  isExpanded: true,
                  items: [
                    for (final c in others)
                      DropdownMenuItem(value: c.id, child: Text(c.label)),
                  ],
                  onChanged: (v) => setState(() => reassignTo = v ?? reassignTo),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size(64, 40),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.delete),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await repo.delete(category.id, reassignTo: used > 0 ? reassignTo : null);
      showAppSnack(l10n.categoryDeleted(category.label));
    } catch (e) {
      showAppSnack(errorMessage(e), kind: SnackKind.error);
    }
  }
}
