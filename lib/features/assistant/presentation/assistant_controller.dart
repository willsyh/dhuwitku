import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/messenger.dart';
import '../../budgets/data/budget_alert_service.dart';
import '../../budgets/presentation/budget_providers.dart';
import '../../categories/domain/category.dart';
import '../../categories/presentation/category_providers.dart';
import '../../settings/presentation/settings_providers.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../domain/assistant_engine.dart';
import '../domain/assistant_intent.dart';
import '../domain/intent_parser.dart';
import 'chat_message.dart';
import 'cloud_mascot.dart';

/// Chat state for the offline assistant. History lives in memory for the
/// current app session only.
class AssistantController extends Notifier<List<ChatMessage>> {
  var _nextId = 0;

  /// Last transaction added/edited in this chat; "the one from before".
  int? _lastTouchedId;

  @override
  List<ChatMessage> build() => [
        _bot(
          'Hai! Aku Asisten Dhuwitku. Ketik transaksi atau tanya soal keuanganmu.\n\n'
          '${AssistantEngine.helpText}',
          mood: MascotMood.happy,
        ),
      ];

  ChatMessage _bot(String text, {ChatCard? card, MascotMood mood = MascotMood.idle}) =>
      ChatMessage(id: _nextId++, sender: ChatSender.bot, text: text, card: card, mood: mood);

  /// While a reply is being prepared, bot messages collect here so they all
  /// appear together after the typing indicator.
  List<ChatMessage>? _pending;

  void _push(ChatMessage m) {
    final pending = _pending;
    if (pending != null && m.sender == ChatSender.bot) {
      pending.add(m);
    } else {
      state = [...state, m];
    }
  }

  /// How long the "typing" dots show: a short, natural pause.
  static Duration typingDelayFor(String input) =>
      Duration(milliseconds: 550 + (input.length * 12).clamp(0, 650));

  void _replace(int id, ChatMessage Function(ChatMessage) update) =>
      state = [for (final m in state) m.id == id ? update(m) : m];

  void clear() {
    _lastTouchedId = null;
    state = build();
  }

  MoneyFormatter get _money => ref.read(moneyFormatterProvider);

  Future<AssistantData> _data() async => AssistantData(
        transactions: await ref.read(transactionRepositoryProvider).getAll(),
        categories: await ref.read(categoryRepositoryProvider).getAll(),
        budgets: await ref.read(budgetRepositoryProvider).getAll(),
        now: DateTime.now(),
      );

  Future<void> send(String input) async {
    final text = input.trim();
    if (text.isEmpty) return;
    _push(ChatMessage(id: _nextId++, sender: ChatSender.user, text: text));
    final typing = ChatMessage(id: _nextId++, sender: ChatSender.bot, text: '', typing: true);
    state = [...state, typing];
    final shownAt = DateTime.now();
    _pending = [];
    try {
      final data = await _data();
      final intent = IntentParser(categories: data.categories, now: data.now).parse(text);
      switch (intent) {
        case AddTransactionIntent i:
          await _add(i, data);
        case EditLastIntent i:
          await _edit(i, data);
        case DeleteLastIntent():
          _askDelete(data);
        default:
          _push(_bot(
            AssistantEngine.answer(intent, data, _money),
            mood: switch (intent) {
              UnknownIntent() => MascotMood.surprised,
              HelpIntent() => MascotMood.happy,
              _ => MascotMood.idle,
            },
          ));
      }
    } catch (e) {
      _push(_bot('Maaf, terjadi kesalahan: ${errorMessage(e)}', mood: MascotMood.alert));
    } finally {
      final remaining = typingDelayFor(text) - DateTime.now().difference(shownAt);
      if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      final replies = _pending ?? const <ChatMessage>[];
      _pending = null;
      state = [...state.where((m) => m.id != typing.id), ...replies];
    }
  }

  // ---- Add -------------------------------------------------------------------

  Future<void> _add(AddTransactionIntent i, AssistantData data) async {
    if (i.category == null) {
      final options = data.categories.where((c) => c.type == i.type).toList();
      _push(_bot(
        '${i.type.label} ${_money.format(i.amount)} masuk kategori apa?',
        card: CategoryPickCard(pending: i, options: options),
        mood: MascotMood.surprised,
      ));
      return;
    }
    await _commitAdd(i);
  }

  Future<void> pickCategory(int messageId, Category category) async {
    final msg = state.where((m) => m.id == messageId).firstOrNull;
    final card = msg?.card;
    if (card is! CategoryPickCard || card.picked != null) return;
    _replace(messageId, (m) => m.withCard(card.withPicked(category)));
    try {
      await _commitAdd(card.pending.withCategory(category));
    } catch (e) {
      _push(_bot('Maaf, gagal menyimpan: ${errorMessage(e)}', mood: MascotMood.alert));
    }
  }

  Future<void> _commitAdd(AddTransactionIntent i) async {
    final repo = ref.read(transactionRepositoryProvider);
    final draft = TransactionDraft(
      type: i.type,
      amount: i.amount,
      categoryId: i.category!.id,
      date: i.date,
      description: i.description,
      paymentMethod: i.paymentMethod,
    );
    final error = draft.validate();
    if (error != null) {
      _push(_bot(error, mood: MascotMood.alert));
      return;
    }
    final id = await repo.add(draft);
    _lastTouchedId = id;
    final saved = await repo.getById(id);
    final warnings = await BudgetAlertService(ref.read(budgetRepositoryProvider), repo)
        .warningsAfterSave(type: i.type, categoryId: i.category!.id, categoryName: i.category!.name, date: i.date);
    final text = warnings.isEmpty ? 'Tersimpan ✓' : 'Tersimpan ✓\n⚠ ${warnings.join('\n⚠ ')}';
    _push(_bot(
      text,
      card: saved == null ? null : TransactionResultCard(after: saved),
      // Budget warning -> "!", otherwise a happy wink.
      mood: warnings.isEmpty ? MascotMood.happy : MascotMood.alert,
    ));
  }

  // ---- Edit / delete ----------------------------------------------------------

  /// The transaction "tadi": the last one touched in this chat if it still
  /// exists, otherwise the most recently recorded one.
  FinanceTransaction? _target(AssistantData data) {
    if (data.transactions.isEmpty) return null;
    final touched = data.transactions.where((t) => t.id == _lastTouchedId).firstOrNull;
    if (touched != null) return touched;
    return data.transactions.reduce((a, b) {
      final c = a.createdAt.compareTo(b.createdAt);
      return c > 0 || (c == 0 && a.id > b.id) ? a : b;
    });
  }

  Future<void> _edit(EditLastIntent i, AssistantData data) async {
    final target = _target(data);
    if (target == null) {
      _push(_bot('Belum ada transaksi untuk diubah.', mood: MascotMood.surprised));
      return;
    }
    if (!i.hasChanges) {
      _push(_bot('Mau diubah jadi apa? Contoh: "ubah jadi 30rb", "kategorinya jadi makan", '
          'atau "tanggalnya jadi kemarin".',
          mood: MascotMood.surprised));
      return;
    }
    final category = i.category ?? target.category;
    final draft = TransactionDraft(
      type: category.type,
      amount: i.amount ?? target.amount,
      categoryId: category.id,
      date: i.date ?? target.date,
      description: target.description,
      paymentMethod: target.paymentMethod,
    );
    final error = draft.validate();
    if (error != null) {
      _push(_bot(error, mood: MascotMood.alert));
      return;
    }
    final repo = ref.read(transactionRepositoryProvider);
    await repo.update(target.id, draft);
    _lastTouchedId = target.id;
    final after = await repo.getById(target.id);
    _push(_bot('Diperbarui ✓',
        card: after == null ? null : TransactionResultCard(after: after, before: target),
        mood: MascotMood.happy));
  }

  void _askDelete(AssistantData data) {
    final target = _target(data);
    if (target == null) {
      _push(_bot('Belum ada transaksi untuk dihapus.', mood: MascotMood.surprised));
      return;
    }
    _push(_bot('Hapus transaksi ini?',
        card: DeleteConfirmCard(target: target), mood: MascotMood.alert));
  }

  Future<void> confirmDelete(int messageId) async {
    final card = state.where((m) => m.id == messageId).firstOrNull?.card;
    if (card is! DeleteConfirmCard || card.state != ConfirmState.pending) return;
    try {
      await ref.read(transactionRepositoryProvider).delete(card.target.id);
      if (_lastTouchedId == card.target.id) _lastTouchedId = null;
      _replace(messageId, (m) => m.withCard(card.withState(ConfirmState.done)));
      _push(_bot('Transaksi dihapus.'));
    } catch (e) {
      _push(_bot('Gagal menghapus: ${errorMessage(e)}', mood: MascotMood.alert));
    }
  }

  void cancelDelete(int messageId) {
    final card = state.where((m) => m.id == messageId).firstOrNull?.card;
    if (card is! DeleteConfirmCard || card.state != ConfirmState.pending) return;
    _replace(messageId, (m) => m.withCard(card.withState(ConfirmState.cancelled)));
    _push(_bot('Oke, tidak jadi dihapus.'));
  }

  /// Undo an add (delete it) or an edit (restore the previous values).
  Future<void> undo(int messageId) async {
    final card = state.where((m) => m.id == messageId).firstOrNull?.card;
    if (card is! TransactionResultCard || card.undone) return;
    final repo = ref.read(transactionRepositoryProvider);
    try {
      final before = card.before;
      if (before == null) {
        await repo.delete(card.after.id);
        if (_lastTouchedId == card.after.id) _lastTouchedId = null;
      } else {
        await repo.update(
          before.id,
          TransactionDraft(
            type: before.type,
            amount: before.amount,
            categoryId: before.category.id,
            date: before.date,
            description: before.description,
            paymentMethod: before.paymentMethod,
          ),
        );
      }
      _replace(messageId, (m) => m.withCard(card.markUndone()));
      _push(_bot(
        before == null ? 'Dibatalkan, transaksi dihapus.' : 'Dibatalkan, data dikembalikan.',
        mood: MascotMood.happy,
      ));
    } catch (e) {
      _push(_bot('Gagal membatalkan: ${errorMessage(e)}', mood: MascotMood.alert));
    }
  }
}

final assistantProvider =
    NotifierProvider<AssistantController, List<ChatMessage>>(AssistantController.new);

/// Short label for a transaction in chat cards: "Kopi · hari ini · QRIS".
String describeTransaction(FinanceTransaction t) => [
      t.title == t.category.name ? t.category.name : '${t.category.name} · ${t.title}',
      relativeDayLabel(t.date),
      ?t.paymentMethod,
    ].join(' · ');
