import '../../categories/domain/category.dart';
import '../../transactions/domain/finance_transaction.dart';
import '../domain/assistant_intent.dart';
import 'cloud_mascot.dart';

enum ChatSender { user, bot }

/// Interactive content attached to a bot message.
sealed class ChatCard {
  const ChatCard();
}

/// A transaction the assistant just saved or edited, with an undo button.
class TransactionResultCard extends ChatCard {
  const TransactionResultCard({required this.after, this.before, this.undone = false});

  final FinanceTransaction after;

  /// Values before an edit; null when the transaction was newly added.
  final FinanceTransaction? before;
  final bool undone;

  bool get isEdit => before != null;

  TransactionResultCard markUndone() => TransactionResultCard(after: after, before: before, undone: true);
}

enum ConfirmState { pending, done, cancelled }

/// "Delete this transaction?" — nothing is deleted until confirmed.
class DeleteConfirmCard extends ChatCard {
  const DeleteConfirmCard({required this.target, this.state = ConfirmState.pending});
  final FinanceTransaction target;
  final ConfirmState state;

  DeleteConfirmCard withState(ConfirmState s) => DeleteConfirmCard(target: target, state: s);
}

/// Asks which category a new transaction belongs to.
class CategoryPickCard extends ChatCard {
  const CategoryPickCard({required this.pending, required this.options, this.picked});
  final AddTransactionIntent pending;
  final List<Category> options;
  final Category? picked;

  CategoryPickCard withPicked(Category c) =>
      CategoryPickCard(pending: pending, options: options, picked: c);
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sender,
    required this.text,
    this.card,
    this.typing = false,
    this.mood = MascotMood.idle,
  });

  final int id;
  final ChatSender sender;
  final String text;
  final ChatCard? card;

  /// Placeholder shown while the assistant prepares a reply (3 moving dots).
  final bool typing;

  /// The mascot's expression next to this (bot) message.
  final MascotMood mood;

  ChatMessage withCard(ChatCard card) =>
      ChatMessage(id: id, sender: sender, text: text, card: card, typing: typing, mood: mood);
}
