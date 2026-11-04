import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../settings/presentation/settings_providers.dart';
import '../domain/finance_transaction.dart';
import 'transaction_detail_sheet.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.transaction, this.showDate = true});
  final FinanceTransaction transaction;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = transaction;
    final theme = Theme.of(context);
    final money = ref.watch(moneyFormatterProvider);
    final subtitleParts = [
      if (t.title != t.category.name) t.category.name,
      showDate ? relativeDayLabel(t.date) : DateFormats.time.format(t.date),
      ?t.paymentMethod,
    ];

    return InkWell(
      onTap: () => showTransactionDetail(context, t),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CategoryAvatar(icon: t.category.icon, color: t.category.color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleParts.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money.signed(t.amount, positive: t.isIncome),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: t.isIncome ? AppColors.income : AppColors.expense,
                    fontFeatures: tabularFigures,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.type.label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
