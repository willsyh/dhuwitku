import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/l10n.dart';
import '../../budgets/domain/budget.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../categories/domain/category.dart';
import '../../statistics/domain/statistics_calculator.dart';
import '../../transactions/domain/finance_transaction.dart';
import 'assistant_intent.dart';
import 'saving_tips.dart';

/// A snapshot of the user's data the assistant answers from.
class AssistantData {
  const AssistantData({
    required this.transactions,
    required this.categories,
    required this.budgets,
    required this.now,
  });

  final List<FinanceTransaction> transactions;
  final List<Category> categories;
  final List<Budget> budgets;
  final DateTime now;
}

/// Builds Indonesian replies for questions, tips, help and unknown input.
/// Pure and deterministic: every number comes from the user's own data.
abstract final class AssistantEngine {
  /// What the assistant can do, with example commands (active language).
  static String get helpText => l10n.asstHelp;

  static String answer(AssistantIntent intent, AssistantData data, MoneyFormatter money) {
    return switch (intent) {
      QuerySpendingIntent i => _spending(i, data, money),
      QueryBalanceIntent() => _balance(data, money),
      QueryBudgetIntent i => _budget(i, data, money),
      QueryTopCategoryIntent i => _top(i, data, money),
      AskTipsIntent() => _tips(data, money),
      HelpIntent() => '${l10n.asstHi} $helpText',
      UnknownIntent() => '${l10n.asstUnknown}\n\n$helpText',
      // Commands are executed by the controller, not answered here.
      AddTransactionIntent() || EditLastIntent() || DeleteLastIntent() => '',
    };
  }

  static Period _period(QueryRange r) => Period(PeriodType.day, r.start, r.end);

  static String _spending(QuerySpendingIntent i, AssistantData d, MoneyFormatter money) {
    final inRange = d.transactions.where((t) => i.range.contains(t.date) && t.type == i.type);
    final scoped = i.category == null
        ? inRange.toList()
        : inRange.where((t) => t.category.id == i.category!.id).toList();
    final total = scoped.fold<int>(0, (s, t) => s + t.amount);
    final l = l10n;
    final what = i.category?.label ?? i.type.label;
    final range = i.range.label;

    if (scoped.isEmpty) {
      return i.category != null
          ? l.asstNoCategoryTx(what, range)
          : i.type == TransactionType.income
              ? l.asstNoIncome(range)
              : l.asstNoExpense(range);
    }

    final buffer = StringBuffer(l.asstTotal(what, range, money.format(total), scoped.length));
    if (i.category != null) {
      buffer.write(' ${l.asstAvgPerTx(money.format((total / scoped.length).round()))}');
    } else if (i.type == TransactionType.expense) {
      final byCat = StatisticsCalculator.expenseByCategory(d.transactions, _period(i.range));
      if (byCat.isNotEmpty) {
        final top = byCat.first;
        buffer.write(
            '\n${l.asstTop(top.category.label, money.format(top.amount), (top.share * 100).round())}');
      }
      final days = _period(i.range).elapsedDays(d.now);
      if (days > 1) buffer.write('\n${l.asstAvgPerDay(money.format((total / days).round()))}');
    }
    return buffer.toString();
  }

  static String _balance(AssistantData d, MoneyFormatter money) {
    var income = 0, expense = 0;
    for (final t in d.transactions) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final month = StatisticsCalculator.summarize(
        d.transactions, Period.of(PeriodType.month, d.now), now: d.now);
    return l10n.asstBalance(money.format(income - expense), money.format(income),
        money.format(expense), money.format(month.income), money.format(month.expense));
  }

  static String _budget(QueryBudgetIntent i, AssistantData d, MoneyFormatter money) {
    final statuses = BudgetCalculator.statuses(
      budgets: d.budgets,
      categories: d.categories,
      transactions: d.transactions,
      year: d.now.year,
      month: d.now.month,
    );
    String line(BudgetStatus s) {
      final state = switch (s.level) {
        BudgetLevel.safe => l10n.asstStateSafe,
        BudgetLevel.caution => l10n.asstStateCaution,
        BudgetLevel.danger => l10n.asstStateDanger,
        BudgetLevel.exceeded => l10n.asstStateExceeded,
      };
      final left = s.remaining >= 0
          ? l10n.asstLeft(money.format(s.remaining))
          : l10n.asstOver(money.format(-s.remaining));
      return l10n.asstBudgetLine(s.label, left, money.format(s.limit), s.percent, state);
    }

    if (i.category != null) {
      final s = statuses.where((s) => s.category?.id == i.category!.id).firstOrNull;
      return s == null
          ? l10n.asstNoBudgetFor(i.category!.label)
          : line(s);
    }
    if (statuses.isEmpty) {
      return l10n.asstNoBudget;
    }
    final shown = [
      ...statuses.where((s) => s.isOverall),
      ...statuses.where((s) => !s.isOverall).take(4),
    ];
    return shown.map(line).join('\n');
  }

  static String _top(QueryTopCategoryIntent i, AssistantData d, MoneyFormatter money) {
    final byCat = StatisticsCalculator.expenseByCategory(d.transactions, _period(i.range));
    if (byCat.isEmpty) return l10n.asstNoExpense(i.range.label);
    final lines = [
      for (final (n, c) in byCat.take(3).indexed)
        '${n + 1}. ${c.category.label} ${money.format(c.amount)} (${(c.share * 100).round()}%)',
    ];
    return '${l10n.asstTopList(i.range.label)}\n${lines.join('\n')}';
  }

  static String _tips(AssistantData d, MoneyFormatter money) {
    final tips = SavingTips.generate(d, money);
    if (tips.isEmpty) {
      return l10n.asstNoTips;
    }
    return '${l10n.asstTipsHeader}\n${tips.map((t) => '• $t').join('\n')}';
  }
}
