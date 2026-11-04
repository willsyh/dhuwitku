import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/amount_input_formatter.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import 'budget_progress.dart';
import 'budget_providers.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedBudgetMonthProvider);
    final async = ref.watch(budgetStatusesProvider((month.year, month.month)));
    final money = ref.watch(moneyFormatterProvider);
    final expenseCategories = ref.watch(categoriesByTypeProvider(TransactionType.expense));
    final now = DateTime.now();
    final isFutureLimit = month.year > now.year + 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Anggaran')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(error: e),
        data: (statuses) {
          final overall = statuses.where((s) => s.isOverall).firstOrNull;
          final perCategory = statuses.where((s) => !s.isOverall).toList();
          final unbudgeted = expenseCategories
              .where((c) => !perCategory.any((s) => s.category?.id == c.id))
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              PeriodSwitcher(
                label: DateFormats.monthYear.format(month),
                onPrevious: () => ref.read(selectedBudgetMonthProvider.notifier).shift(-1),
                onNext: isFutureLimit
                    ? null
                    : () => ref.read(selectedBudgetMonthProvider.notifier).shift(1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                child: Text(
                  'Anggaran berlaku mulai bulan yang dipilih dan terus berlanjut ke bulan berikutnya sampai diubah.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SectionHeader(title: 'Anggaran Bulanan'),
              if (overall != null)
                BudgetStatusCard(
                  status: overall,
                  money: money,
                  onTap: () => _edit(context, ref, month, null, 'Anggaran Bulanan', overall.limit),
                  onDelete: () => _remove(context, ref, month, null, 'Anggaran Bulanan'),
                )
              else
                AppCard(
                  onTap: () => _edit(context, ref, month, null, 'Anggaran Bulanan', null),
                  child: const Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded),
                      SizedBox(width: 12),
                      Expanded(child: Text('Atur anggaran total untuk bulan ini')),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              SectionHeader(
                title: 'Batas per Kategori',
                actionLabel: unbudgeted.isEmpty ? null : 'Tambah',
                onAction: () => _addCategoryBudget(context, ref, month, unbudgeted),
              ),
              if (perCategory.isEmpty)
                AppCard(
                  child: EmptyState(
                    icon: Icons.donut_small_outlined,
                    title: 'Belum ada batas kategori',
                    message: 'Contoh: batasi Kopi Rp 300.000 per bulan.',
                    action: unbudgeted.isEmpty
                        ? null
                        : OutlinedButton.icon(
                            onPressed: () => _addCategoryBudget(context, ref, month, unbudgeted),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Tambah batas'),
                          ),
                  ),
                )
              else
                for (final s in perCategory)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: BudgetStatusCard(
                      status: s,
                      money: money,
                      onTap: () => _edit(context, ref, month, s.category!.id, s.label, s.limit),
                      onDelete: () => _remove(context, ref, month, s.category!.id, s.label),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addCategoryBudget(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    List<Category> options,
  ) async {
    final picked = await showModalBottomSheet<Category>(
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
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Pilih kategori', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            for (final c in options)
              ListTile(
                leading: CategoryAvatar(icon: c.icon, color: c.color, size: 36),
                title: Text(c.name),
                onTap: () => Navigator.pop(context, c),
              ),
          ],
        ),
      ),
    );
    if (picked != null && context.mounted) {
      await _edit(context, ref, month, picked.id, picked.name, null);
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    int? categoryId,
    String label,
    int? current,
  ) async {
    final amount = await showDialog<int>(
      context: context,
      builder: (_) => _BudgetAmountDialog(label: label, initial: current, month: month),
    );
    if (amount == null) return;
    try {
      await ref.read(budgetRepositoryProvider).setBudget(
            categoryId: categoryId,
            year: month.year,
            month: month.month,
            amount: amount,
          );
      showAppSnack('Anggaran $label disimpan.');
    } catch (e) {
      showAppSnack(errorMessage(e), kind: SnackKind.error);
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    DateTime month,
    int? categoryId,
    String label,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus anggaran?'),
        content: Text(
          '$label tidak lagi berlaku mulai ${DateFormats.monthYear.format(month)}. '
          'Anggaran bulan-bulan sebelumnya tetap tersimpan.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(budgetRepositoryProvider)
          .removeBudget(categoryId: categoryId, year: month.year, month: month.month);
      showAppSnack('Anggaran $label dihapus.');
    } catch (e) {
      showAppSnack(errorMessage(e), kind: SnackKind.error);
    }
  }
}

class _BudgetAmountDialog extends StatefulWidget {
  const _BudgetAmountDialog({required this.label, required this.initial, required this.month});
  final String label;
  final int? initial;
  final DateTime month;

  @override
  State<_BudgetAmountDialog> createState() => _BudgetAmountDialogState();
}

class _BudgetAmountDialogState extends State<_BudgetAmountDialog> {
  late final _controller =
      TextEditingController(text: widget.initial == null ? '' : groupDigits(widget.initial!));
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = parseGroupedDigits(_controller.text);
    if (value <= 0) {
      setState(() => _error = 'Masukkan jumlah lebih dari 0');
      return;
    }
    if (value > AppLimits.maxAmount) {
      setState(() => _error = 'Jumlah terlalu besar');
      return;
    }
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mulai ${DateFormats.monthYear.format(widget.month)}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [GroupedDigitsFormatter()],
            decoration: InputDecoration(prefixText: 'Rp ', hintText: '0', errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in const [500000, 1000000, 2000000, 5000000])
                ActionChip(
                  label: Text(compactNumber(v)),
                  onPressed: () => _controller.text = groupDigits(v),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 40)),
          onPressed: _submit,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
