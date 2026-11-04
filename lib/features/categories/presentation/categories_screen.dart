import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
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
    final async = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Pengeluaran'), Tab(text: 'Pemasukan')],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryFormSheet(context, type: _type),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Kategori'),
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
    if (categories.isEmpty) {
      return const EmptyState(icon: Icons.category_outlined, title: 'Belum ada kategori');
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
            title: Text(c.name),
            subtitle: c.isDefault ? const Text('Bawaan') : null,
            trailing: IconButton(
              tooltip: 'Hapus kategori',
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
      showAppSnack('Minimal harus ada satu kategori untuk jenis ini.', kind: SnackKind.warning);
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
          title: Text('Hapus "${category.name}"?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(used == 0
                  ? 'Kategori ini belum digunakan transaksi apa pun. Anggaran untuk kategori ini juga akan dihapus.'
                  : '$used transaksi menggunakan kategori ini. Pindahkan transaksi tersebut ke:'),
              if (used > 0) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: reassignTo,
                  isExpanded: true,
                  items: [
                    for (final c in others)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => reassignTo = v ?? reassignTo),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size(64, 40),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await repo.delete(category.id, reassignTo: used > 0 ? reassignTo : null);
      showAppSnack('Kategori "${category.name}" dihapus.');
    } catch (e) {
      showAppSnack(errorMessage(e), kind: SnackKind.error);
    }
  }
}
