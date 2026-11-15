import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
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
  static const helpText = 'Aku bisa bantu:\n'
      '• Catat: "kopi 25rb", "gaji 6,5jt kemarin", "parkir 5000 tunai"\n'
      '• Tanya: "pengeluaran bulan ini?", "kopi minggu ini", "saldo?"\n'
      '• Anggaran: "sisa anggaran?", "anggaran makan"\n'
      '• Analisis: "kategori terbesar", "tips hemat"\n'
      '• Ubah: "ubah yang tadi jadi 30rb", "hapus transaksi terakhir"';

  static String answer(AssistantIntent intent, AssistantData data, MoneyFormatter money) {
    return switch (intent) {
      QuerySpendingIntent i => _spending(i, data, money),
      QueryBalanceIntent() => _balance(data, money),
      QueryBudgetIntent i => _budget(i, data, money),
      QueryTopCategoryIntent i => _top(i, data, money),
      AskTipsIntent() => _tips(data, money),
      HelpIntent() => 'Hai! $helpText',
      UnknownIntent() => 'Maaf, aku belum paham. Aku khusus mengurus catatan keuanganmu.\n\n$helpText',
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
    final what = i.category?.name ?? (i.type == TransactionType.income ? 'Pemasukan' : 'Pengeluaran');
    final range = i.range.label;

    if (scoped.isEmpty) {
      return i.category == null
          ? 'Belum ada ${what.toLowerCase()} $range.'
          : 'Belum ada transaksi $what $range.';
    }

    final buffer = StringBuffer('$what $range ${money.format(total)} (${scoped.length} transaksi).');
    if (i.category != null) {
      buffer.write(' Rata-rata ${money.format((total / scoped.length).round())} per transaksi.');
    } else if (i.type == TransactionType.expense) {
      final byCat = StatisticsCalculator.expenseByCategory(d.transactions, _period(i.range));
      if (byCat.isNotEmpty) {
        final top = byCat.first;
        buffer.write(
            '\nTerbesar: ${top.category.name} ${money.format(top.amount)} (${(top.share * 100).round()}%).');
      }
      final days = _period(i.range).elapsedDays(d.now);
      if (days > 1) buffer.write('\nRata-rata ${money.format((total / days).round())} per hari.');
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
    return 'Saldo kamu ${money.format(income - expense)}.\n'
        'Total pemasukan ${money.format(income)}, pengeluaran ${money.format(expense)}.\n'
        'Bulan ini: masuk ${money.format(month.income)}, keluar ${money.format(month.expense)}.';
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
        BudgetLevel.safe => 'aman',
        BudgetLevel.caution => 'waspada',
        BudgetLevel.danger => 'hampir habis',
        BudgetLevel.exceeded => 'terlampaui',
      };
      final left = s.remaining >= 0
          ? 'sisa ${money.format(s.remaining)}'
          : 'lebih ${money.format(-s.remaining)}';
      return '${s.label}: $left dari ${money.format(s.limit)} (${s.percent}%, $state).';
    }

    if (i.category != null) {
      final s = statuses.where((s) => s.category?.id == i.category!.id).firstOrNull;
      return s == null
          ? 'Belum ada batas anggaran untuk ${i.category!.name}. Atur di menu Anggaran.'
          : line(s);
    }
    if (statuses.isEmpty) {
      return 'Kamu belum mengatur anggaran. Buka Pengaturan → Anggaran untuk mengatur anggaran bulanan.';
    }
    final shown = [
      ...statuses.where((s) => s.isOverall),
      ...statuses.where((s) => !s.isOverall).take(4),
    ];
    return shown.map(line).join('\n');
  }

  static String _top(QueryTopCategoryIntent i, AssistantData d, MoneyFormatter money) {
    final byCat = StatisticsCalculator.expenseByCategory(d.transactions, _period(i.range));
    if (byCat.isEmpty) return 'Belum ada pengeluaran ${i.range.label}.';
    final lines = [
      for (final (n, c) in byCat.take(3).indexed)
        '${n + 1}. ${c.category.name} ${money.format(c.amount)} (${(c.share * 100).round()}%)',
    ];
    return 'Pengeluaran terbesar ${i.range.label}:\n${lines.join('\n')}';
  }

  static String _tips(AssistantData d, MoneyFormatter money) {
    final tips = SavingTips.generate(d, money);
    if (tips.isEmpty) {
      return 'Belum cukup data untuk memberi saran. Catat pengeluaranmu beberapa hari dulu, ya.';
    }
    return 'Saran dari pola pengeluaranmu:\n${tips.map((t) => '• $t').join('\n')}';
  }
}
