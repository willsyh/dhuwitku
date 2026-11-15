import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../domain/budget_calculator.dart';

Color budgetColor(BudgetLevel level) => switch (level) {
      BudgetLevel.safe => AppColors.income,
      BudgetLevel.caution => AppColors.warning,
      BudgetLevel.danger => const Color(0xFFF97316),
      BudgetLevel.exceeded => AppColors.expense,
    };

String budgetLevelLabel(BudgetLevel level) => switch (level) {
      BudgetLevel.safe => l10n.levelSafe,
      BudgetLevel.caution => l10n.levelCaution,
      BudgetLevel.danger => l10n.levelDanger,
      BudgetLevel.exceeded => l10n.levelExceeded,
    };

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({super.key, required this.status, this.height = 8});
  final BudgetStatus status;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.usedPercentA11y(status.percent),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: status.ratio.clamp(0, 1).toDouble()),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: height,
            color: budgetColor(status.level),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}

class BudgetStatusCard extends StatelessWidget {
  const BudgetStatusCard({
    super.key,
    required this.status,
    required this.money,
    this.onTap,
    this.onDelete,
  });

  final BudgetStatus status;
  final MoneyFormatter money;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = status;
    final color = budgetColor(s.level);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (s.category != null)
                CategoryAvatar(icon: s.category!.icon, color: s.category!.color, size: 40)
              else
                CategoryAvatar(
                    icon: Icons.account_balance_wallet_rounded,
                    color: theme.colorScheme.primary,
                    size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text(context.l10n.budgetAmount(money.format(s.limit)), style: muted),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${s.percent}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: context.l10n.deleteBudget,
                  visualDensity: VisualDensity.compact,
                  onPressed: onDelete,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          BudgetProgressBar(status: s),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(context.l10n.spentAmount(money.format(s.spent)), style: muted)),
              Text(
                s.remaining >= 0
                    ? context.l10n.leftAmount(money.format(s.remaining))
                    : context.l10n.overAmount(money.format(-s.remaining)),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: s.remaining >= 0 ? null : AppColors.expense,
                ),
              ),
            ],
          ),
          if (s.warningMessage != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${budgetLevelLabel(s.level)} · ${s.warningMessage}',
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
