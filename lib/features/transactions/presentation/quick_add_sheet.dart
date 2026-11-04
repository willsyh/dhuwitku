import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../budgets/data/budget_alert_service.dart';
import '../../budgets/presentation/budget_providers.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_form_sheet.dart';
import '../../categories/presentation/category_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/amount_input.dart';
import '../domain/finance_transaction.dart';
import 'transaction_providers.dart';

/// Opens the quick transaction sheet. Pass [initial] to edit an existing one.
Future<void> showQuickAddSheet(
  BuildContext context, {
  TransactionType type = TransactionType.expense,
  FinanceTransaction? initial,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => QuickAddSheet(initialType: initial?.type ?? type, initial: initial),
  );
}

class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, required this.initialType, this.initial});
  final TransactionType initialType;
  final FinanceTransaction? initial;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late TransactionType _type = widget.initialType;
  late AmountInput _amount = AmountInput(widget.initial?.amount ?? 0);
  late int? _categoryId = widget.initial?.category.id;
  late DateTime _date = widget.initial?.date ?? DateTime.now();
  late String? _paymentMethod = widget.initial?.paymentMethod;
  late final _note = TextEditingController(text: widget.initial?.description ?? '');
  late bool _showNote = (widget.initial?.description ?? '').isNotEmpty;
  final _noteFocus = FocusNode();
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.initial != null;
  Color get _typeColor => _type == TransactionType.expense ? AppColors.expense : AppColors.income;

  @override
  void initState() {
    super.initState();
    _noteFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _note.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _setAmount(AmountInput next) {
    if (next.value == _amount.value) return;
    HapticFeedback.selectionClick();
    setState(() {
      _amount = next;
      _error = null;
    });
  }

  void _setType(TransactionType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _categoryId = null;
      _error = null;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      // Matches TransactionDraft.validate (at most a year ahead).
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Tanggal transaksi',
    );
    if (picked == null) return;
    // Keep the time of day so same-day entries stay in recording order.
    final time = isSameDay(picked, now) ? now : _date;
    setState(() => _date = DateTime(
        picked.year, picked.month, picked.day, time.hour, time.minute, time.second));
  }

  Future<void> _createCategory() async {
    final id = await showCategoryFormSheet(context, type: _type);
    if (id != null && mounted) setState(() => _categoryId = id);
  }

  Future<void> _save() async {
    if (_saving) return;
    final draft = TransactionDraft(
      type: _type,
      amount: _amount.value,
      categoryId: _categoryId,
      date: _date,
      description: _note.text,
      paymentMethod: _paymentMethod,
    );
    final validation = draft.validate();
    if (validation != null) {
      HapticFeedback.heavyImpact();
      setState(() => _error = validation);
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(transactionRepositoryProvider);
    final money = ref.read(moneyFormatterProvider);
    final categories = ref.read(categoriesProvider).value ?? const <Category>[];
    final categoryName =
        categories.where((c) => c.id == _categoryId).firstOrNull?.name ?? 'kategori';
    try {
      if (_isEditing) {
        await repo.update(widget.initial!.id, draft);
      } else {
        await repo.add(draft);
      }
      final warnings = await BudgetAlertService(ref.read(budgetRepositoryProvider), repo)
          .warningsAfterSave(
        type: _type,
        categoryId: _categoryId!,
        categoryName: categoryName,
        date: _date,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      final verb = _isEditing ? 'diperbarui' : 'tersimpan';
      final base = '${_type.label} ${money.format(draft.amount)} $verb.';
      if (warnings.isEmpty) {
        showAppSnack(base);
      } else {
        showAppSnack('$base ${warnings.join(' ')}', kind: SnackKind.warning);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final money = ref.watch(moneyFormatterProvider);
    final categories = ref.watch(categoriesByTypeProvider(_type));
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final compact = MediaQuery.sizeOf(context).height < 720;
    final keypadVisible = !_noteFocus.hasFocus;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEditing)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Ubah Transaksi', style: theme.textTheme.titleMedium),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _TypeToggle(value: _type, onChanged: _setType),
          ),
          // Amount
          Padding(
            padding: EdgeInsets.fromLTRB(20, compact ? 8 : 16, 20, 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: theme.textTheme.displaySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _amount.value == 0 ? theme.colorScheme.onSurfaceVariant : _typeColor,
                  fontFeatures: tabularFigures,
                ),
                child: Text(money.format(_amount.value), semanticsLabel: 'Jumlah'),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: _error == null
                ? const SizedBox(height: 4)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(_error!,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.expense)),
                  ),
          ),
          // Quick amounts
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final a in quickAmounts)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      label: Text(groupDigits(a)),
                      onPressed: () => _setAmount(AmountInput(a)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryGrid(
                    categories: categories,
                    selectedId: _categoryId,
                    accent: _typeColor,
                    onSelected: (id) => setState(() {
                      _categoryId = id;
                      _error = null;
                    }),
                    onCreate: _createCategory,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(relativeDayLabel(_date)),
                        onPressed: _pickDate,
                      ),
                      _PaymentChip(
                        value: _paymentMethod,
                        onChanged: (v) => setState(() => _paymentMethod = v),
                      ),
                      FilterChip(
                        avatar: const Icon(Icons.notes_rounded, size: 16),
                        label: const Text('Catatan'),
                        selected: _showNote,
                        showCheckmark: false,
                        onSelected: (v) {
                          setState(() => _showNote = v);
                          if (v) {
                            WidgetsBinding.instance
                                .addPostFrameCallback((_) => _noteFocus.requestFocus());
                          } else {
                            _noteFocus.unfocus();
                          }
                        },
                      ),
                    ],
                  ),
                  if (_showNote) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _note,
                      focusNode: _noteFocus,
                      maxLength: AppLimits.maxDescriptionLength,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _noteFocus.unfocus(),
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Nasi goreng, kopi susu…',
                        counterText: '',
                        prefixIcon: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (keypadVisible)
            _Keypad(
              keyHeight: compact ? 46 : 54,
              onDigit: (d) => _setAmount(_amount.appendDigit(d)),
              onThousand: () => _setAmount(_amount.appendThousand()),
              onBackspace: () => _setAmount(_amount.backspace()),
              onClear: () => _setAmount(_amount.clear()),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: _typeColor),
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_isEditing ? 'Simpan Perubahan' : 'Simpan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.value, required this.onChanged});
  final TransactionType value;
  final ValueChanged<TransactionType> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget option(TransactionType t, Color color) {
      final selected = t == value;
      return Expanded(
        child: Semantics(
          selected: selected,
          button: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                t.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Jenis transaksi',
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            option(TransactionType.expense, AppColors.expense),
            option(TransactionType.income, AppColors.income),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.accent,
    required this.onSelected,
    required this.onCreate,
  });

  final List<Category> categories;
  final int? selectedId;
  final Color accent;
  final ValueChanged<int> onSelected;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = categories.length + 1;
    return SizedBox(
      height: 172,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 78,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: count,
        itemBuilder: (context, i) {
          if (i == categories.length) {
            return _tile(
              context,
              icon: Icons.add_rounded,
              color: scheme.onSurfaceVariant,
              label: 'Baru',
              selected: false,
              onTap: onCreate,
            );
          }
          final c = categories[i];
          return _tile(
            context,
            icon: c.icon,
            color: c.color,
            label: c.name,
            selected: c.id == selectedId,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(c.id);
            },
          );
        },
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: selected ? color.withValues(alpha: 0.12) : null,
            border: Border.all(
              color: selected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryAvatar(icon: icon, color: color, size: 40),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Metode pembayaran',
      onSelected: (v) => onChanged(v.isEmpty ? null : v),
      itemBuilder: (_) => [
        for (final m in paymentMethods)
          CheckedPopupMenuItem(value: m, checked: m == value, child: Text(m)),
        if (value != null) const PopupMenuItem(value: '', child: Text('Hapus metode')),
      ],
      child: Chip(
        avatar: const Icon(Icons.account_balance_wallet_outlined, size: 16),
        label: Text(value ?? 'Metode'),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.keyHeight,
    required this.onDigit,
    required this.onThousand,
    required this.onBackspace,
    required this.onClear,
  });

  final double keyHeight;
  final ValueChanged<int> onDigit;
  final VoidCallback onThousand;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget key(Widget child, VoidCallback onTap, {VoidCallback? onLongPress, String? label}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Material(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Semantics(
                label: label,
                button: true,
                child: SizedBox(height: keyHeight, child: Center(child: child)),
              ),
            ),
          ),
        ),
      );
    }

    const digitStyle = TextStyle(fontSize: 22, fontWeight: FontWeight.w600);
    Widget digit(int d) => key(Text('$d', style: digitStyle), () => onDigit(d));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        children: [
          Row(children: [digit(1), digit(2), digit(3)]),
          Row(children: [digit(4), digit(5), digit(6)]),
          Row(children: [digit(7), digit(8), digit(9)]),
          Row(children: [
            key(const Text('000', style: digitStyle), onThousand, label: 'Tiga nol'),
            digit(0),
            key(
              const Icon(Icons.backspace_outlined),
              onBackspace,
              onLongPress: onClear,
              label: 'Hapus angka. Tahan untuk menghapus semua',
            ),
          ]),
        ],
      ),
    );
  }
}
