import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/finance_transaction.dart';
import 'quick_add_sheet.dart';
import 'transaction_providers.dart';

Future<void> showTransactionDetail(BuildContext context, FinanceTransaction t) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _TransactionDetail(transaction: t),
  );
}

/// Asks for confirmation, then deletes. Returns true when deleted.
Future<bool> confirmDeleteTransaction(
  BuildContext context,
  WidgetRef ref,
  FinanceTransaction t,
) async {
  final money = ref.read(moneyFormatterProvider);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.deleteTransactionQ),
      content: Text(
        '${t.title} · ${money.format(t.amount)}\n${DateFormats.date.format(t.date)}\n\n'
        '${context.l10n.deleteCannotUndo}',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(context.l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.expense,
            minimumSize: const Size(64, 40),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.delete),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await ref.read(transactionRepositoryProvider).delete(t.id);
    showAppSnack(l10n.transactionDeleted);
    return true;
  } catch (e) {
    showAppSnack(errorMessage(e), kind: SnackKind.error);
    return false;
  }
}

class _TransactionDetail extends ConsumerWidget {
  const _TransactionDetail({required this.transaction});
  final FinanceTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = transaction;
    final theme = Theme.of(context);
    final money = ref.watch(moneyFormatterProvider);
    final color = t.isIncome ? AppColors.income : AppColors.expense;
    final l = context.l10n;

    Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 12),
              SizedBox(
                width: 110,
                child: Text(label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ),
              Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
            ],
          ),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CategoryAvatar(icon: t.category.icon, color: t.category.color, size: 60),
          const SizedBox(height: 12),
          Text(t.title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            money.signed(t.amount, positive: t.isIncome),
            style: theme.textTheme.headlineMedium
                ?.copyWith(color: color, fontFeatures: tabularFigures),
          ),
          if (t.isDemo)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Chip(label: Text(l.demoData)),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          row(Icons.swap_vert_rounded, l.type, t.type.label),
          row(Icons.category_outlined, l.category, t.category.label),
          row(Icons.calendar_today_outlined, l.date, DateFormats.dateTime.format(t.date)),
          row(Icons.account_balance_wallet_outlined, l.method,
              t.paymentMethod == null ? '-' : paymentLabel(t.paymentMethod!)),
          row(Icons.notes_rounded, l.note, t.description ?? '-'),
          row(Icons.history_rounded, l.recordedAt, DateFormats.dateTime.format(t.createdAt)),
          if (t.updatedAt.difference(t.createdAt).inSeconds.abs() > 1)
            row(Icons.edit_calendar_outlined, l.updatedAt, DateFormats.dateTime.format(t.updatedAt)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.expense),
                  onPressed: () async {
                    final deleted = await confirmDeleteTransaction(context, ref, t);
                    if (deleted && context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l.delete),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(64, 48)),
                  onPressed: () {
                    // Use the navigator's context: this sheet's context is
                    // gone once it's popped.
                    final nav = Navigator.of(context);
                    nav.pop();
                    showQuickAddSheet(nav.context, initial: t);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(l.edit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
