import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'assistant_controller.dart';
import 'chat_message.dart';
import 'cloud_mascot.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  /// Quick suggestions: (label in the app language, command sent to the parser).
  static List<(String, String)> suggestions(AppLocalizations l) => [
        (l.sugSpendingThisMonth, 'pengeluaran bulan ini'),
        (l.sugBudgetLeft, 'sisa anggaran'),
        (l.sugTips, 'tips hemat'),
        (l.sugTopCategory, 'kategori terbesar'),
        (l.sugBalance, 'saldo'),
        (l.sugDeleteLast, 'hapus transaksi terakhir'),
      ];

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text, {String? parseAs}) async {
    if (text.trim().isEmpty || _sending) return;
    _input.clear();
    setState(() => _sending = true);
    await ref.read(assistantProvider.notifier).send(text, parseAs: parseAs);
    if (mounted) setState(() => _sending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final messages = ref.watch(assistantProvider);
    // The header mascot shows the mood of the latest reply.
    final headerMood = messages
        .lastWhere((m) => m.sender == ChatSender.bot && !m.typing, orElse: () => messages.first)
        .mood;
    ref.listen(assistantProvider, (_, _) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CloudMascot(size: 40, mood: headerMood),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.asstTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    l.asstSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.asstRestart,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(assistantProvider.notifier).clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final next = i + 1 < messages.length ? messages[i + 1] : null;
                return _Bubble(
                  message: m,
                  // Mascot sits next to the last bubble of each bot group;
                  // only the newest one moves.
                  showAvatar: m.sender == ChatSender.bot && next?.sender != ChatSender.bot,
                  animateAvatar: next == null,
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final (label, command) in AssistantScreen.suggestions(l))
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(label: Text(label), onPressed: () => _send(label, parseAs: command)),
                  ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 3,
                      onSubmitted: _send,
                      decoration: InputDecoration(hintText: l.asstInputHint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l.asstSend,
                    onPressed: _sending ? null : () => _send(_input.text),
                    style: IconButton.styleFrom(fixedSize: const Size(48, 48)),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends ConsumerWidget {
  const _Bubble({required this.message, this.showAvatar = false, this.animateAvatar = false});
  final ChatMessage message;
  final bool showAvatar;
  final bool animateAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isUser = message.sender == ChatSender.user;
    final maxWidth = MediaQuery.sizeOf(context).width * (isUser ? 0.8 : 0.72);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
        border: isUser ? null : Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (message.typing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: TypingDots(),
            ),
          if (message.text.isNotEmpty)
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUser ? Colors.white : theme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          if (message.card != null) ...[
            const SizedBox(height: 10),
            _CardView(messageId: message.id, card: message.card!),
          ],
        ],
      ),
    );

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 36,
            child: showAvatar
                ? CloudMascot(size: 34, animate: animateAvatar, mood: message.mood)
                : null,
          ),
          const SizedBox(width: 6),
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _CardView extends ConsumerWidget {
  const _CardView({required this.messageId, required this.card});
  final int messageId;
  final ChatCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(assistantProvider.notifier);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    switch (card) {
      case TransactionResultCard c:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TxRow(tx: c.after, before: c.before, struck: c.undone),
            const SizedBox(height: 8),
            if (c.undone)
              Text(context.l10n.asstUndone, style: muted)
            else
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                onPressed: () => controller.undo(messageId),
                icon: const Icon(Icons.undo_rounded, size: 18),
                label: Text(context.l10n.undo),
              ),
          ],
        );
      case DeleteConfirmCard c:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TxRow(tx: c.target, struck: c.state == ConfirmState.done),
            const SizedBox(height: 8),
            switch (c.state) {
              ConfirmState.pending => Row(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () => controller.confirmDelete(messageId),
                      child: Text(context.l10n.delete),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => controller.cancelDelete(messageId),
                      child: Text(context.l10n.cancel),
                    ),
                  ],
                ),
              ConfirmState.done => Text(context.l10n.asstDeleted, style: muted),
              ConfirmState.cancelled => Text(context.l10n.asstNotDeletedShort, style: muted),
            },
          ],
        );
      case CategoryPickCard c:
        return Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final cat in c.options)
              ChoiceChip(
                avatar: Icon(cat.icon, size: 16, color: cat.color),
                label: Text(cat.label),
                selected: c.picked?.id == cat.id,
                onSelected: c.picked != null ? null : (_) => controller.pickCategory(messageId, cat),
              ),
          ],
        );
    }
  }
}

class _TxRow extends ConsumerWidget {
  const _TxRow({required this.tx, this.before, this.struck = false});
  final FinanceTransaction tx;
  final FinanceTransaction? before;
  final bool struck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final money = ref.watch(moneyFormatterProvider);
    final color = tx.isIncome ? AppColors.income : AppColors.expense;
    final amountText = money.signed(tx.amount, positive: tx.isIncome);
    final changedAmount = before != null && before!.amount != tx.amount;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CategoryAvatar(icon: tx.category.icon, color: tx.category.color, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  describeTransaction(tx),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: struck ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (changedAmount)
                  Text(
                    context.l10n.previousAmount(money.format(before!.amount)),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            amountText,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontFeatures: tabularFigures,
              decoration: struck ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
