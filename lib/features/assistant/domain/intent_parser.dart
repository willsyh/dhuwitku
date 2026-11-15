import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_keywords.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/text_match.dart';
import '../../categories/domain/category.dart';
import 'assistant_intent.dart';

/// Turns one Indonesian chat message into an [AssistantIntent].
/// Deterministic and offline; [now] is injectable for tests.
class IntentParser {
  IntentParser({required List<Category> categories, DateTime? now})
      : _categories = [...categories]..sort((a, b) => b.name.length.compareTo(a.name.length)),
        now = now ?? DateTime.now();

  final List<Category> _categories;
  final DateTime now;

  DateTime get _today => DateTime(now.year, now.month, now.day);

  AssistantIntent parse(String input) {
    final text = _normalize(input);
    if (text.isEmpty || _help.hasMatch(text)) return const HelpIntent();

    final isQuestion = text.contains('?') || _questionWords.hasMatch(text);

    if (_deleteVerb.hasMatch(text) &&
        (_lastRef.hasMatch(text) || RegExp(r'^(undo|batal(kan|in)?|hapus)$').hasMatch(text))) {
      return const DeleteLastIntent();
    }

    // "ganti oli 150rb" is a new expense; edits need a reference or target.
    if (_editVerb.hasMatch(text) && (_lastRef.hasMatch(text) || _editQualifier.hasMatch(text))) {
      return _buildEdit(text);
    }

    if (_topWords.hasMatch(text)) return QueryTopCategoryIntent(range: _extractRange(text));
    if (_tipsWords.hasMatch(text)) return const AskTipsIntent();
    if (_budgetWords.hasMatch(text)) return QueryBudgetIntent(category: _matchCategory(text));
    if (_balanceWords.hasMatch(text)) return const QueryBalanceIntent();

    // A command: has an amount and doesn't read as a question.
    final (date, rest) = _extractDate(text);
    final amounts = _amounts(rest);
    if (amounts.isNotEmpty && !isQuestion) {
      final amount = _pickAmount(amounts);
      if (amount != null) return _buildAdd(rest, amount, date ?? now);
    }

    // A question about totals.
    final category = _matchCategory(text);
    final mentionsRange = _rangeWords.hasMatch(text);
    // Needs a finance signal: "gimana cuacanya?" is not a spending question.
    if (mentionsRange || category != null || _spendingWords.hasMatch(text) ||
        _totalWords.hasMatch(text)) {
      final income = category?.type == TransactionType.income || _incomeQuestion.hasMatch(text);
      return QuerySpendingIntent(
        range: _extractRange(text),
        type: income ? TransactionType.income : TransactionType.expense,
        category: category,
      );
    }
    return const UnknownIntent();
  }

  // ---- Vocabulary ------------------------------------------------------------

  static final _help = RegExp(
    r"^(halo+|hai+|hi+|hello|hallo|hey|hei|p|ping|assalamu'?alaikum|selamat (pagi|siang|sore|malam)|"
    r'bantuan|help|tolong|menu|mulai|start|bisa apa( saja| aja)?|kamu bisa apa|cara pakai|caranya|\?)[\s!.?]*$',
  );
  static final _questionWords = RegExp(
    r'\b(berapa|brp|apa|apakah|gimana|bagaimana|kapan|total|rangkum|ringkas|ringkasan|laporan|rekap|cek|lihat|tampilkan)\b',
  );
  static final _totalWords =
      RegExp(r'\b(berapa|brp|total|rangkum|ringkas|ringkasan|laporan|rekap)\b');
  static final _deleteVerb = RegExp(r'\b(hapus|batalkan|batalin|batal|undo|delete|buang)\b');
  static final _lastRef = RegExp(r'\b(terakhir|tadi|barusan|transaksi|itu|yang tadi)\b');
  static final _editVerb =
      RegExp(r'\b(ubah|ganti|edit|koreksi|ralat|revisi|salah|harusnya|seharusnya|benerin)\b');
  static final _editQualifier = RegExp(
    r'\b(jadi|menjadi|kategori(nya)?|nominal(nya)?|jumlah(nya)?|tanggal(nya)?|harusnya|seharusnya|salah)\b',
  );
  static final _tipsWords =
      RegExp(r'\b(tips|tip|saran|hemat|boros|nabung|menabung|ngirit|irit|saving|kurangi)\b');
  static final _budgetWords = RegExp(r'\b(anggaran|budget|bujet|limit|batas)\b');
  static final _balanceWords =
      RegExp(r'\b(saldo|balance|sisa uang|uangku|uang aku|uang saya|total uang|duitku)\b');
  static final _topWords = RegExp(
    r'(terbesar|terbanyak|paling (banyak|besar|boros|sering)|kategori apa|buat apa (aja|saja)|untuk apa (aja|saja)|ke ?mana (aja|saja))',
  );
  static final _spendingWords =
      RegExp(r'\b(pengeluaran|pemasukan|pendapatan|penghasilan|keluar|masuk|spending|income)\b');
  static final _incomeQuestion =
      RegExp(r'\b(pemasukan|pendapatan|penghasilan|masuk|income|gaji|gajian)\b');
  static final _rangeWords = RegExp(
    r'\b(hari ini|kemarin|minggu (ini|lalu|kemarin)|bulan (ini|lalu|kemarin)|tahun (ini|lalu|kemarin)|\d{1,3} hari terakhir|'
    r'januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|desember)\b',
  );

  static const _fillers = [
    'beli', 'membeli', 'bayar', 'membayar', 'buat', 'untuk', 'utk', 'pakai', 'pake', 'pakek', 'via',
    'lewat', 'catat', 'catet', 'tambah', 'tambahkan', 'input', 'masukin', 'masukkan', 'pengeluaran',
    'sebesar', 'seharga', 'harga', 'rp', 'di', 'ke', 'tolong', 'dong', 'ya', 'yg', 'yang', 'aku', 'saya',
    'habis', 'abis', 'sama', 'nya',
  ];

  static const _paymentWords = [
    'qris', 'gopay', 'ovo', 'dana', 'shopeepay', 'linkaja', 'e-wallet', 'ewallet', 'kartu kredit',
    'credit card', 'kredit', 'debit', 'bca', 'mandiri', 'bri', 'bni', 'transfer', 'tunai', 'cash',
  ];

  static const _monthNames = {
    'januari': 1, 'jan': 1, 'februari': 2, 'feb': 2, 'maret': 3, 'mar': 3, 'april': 4, 'apr': 4,
    'mei': 5, 'juni': 6, 'jun': 6, 'juli': 7, 'jul': 7, 'agustus': 8, 'agu': 8, 'agt': 8,
    'september': 9, 'sep': 9, 'sept': 9, 'oktober': 10, 'okt': 10, 'november': 11, 'nov': 11,
    'nopember': 11, 'desember': 12, 'des': 12,
  };

  static const _dayNames = {
    'senin': DateTime.monday, 'selasa': DateTime.tuesday, 'rabu': DateTime.wednesday,
    'kamis': DateTime.thursday, 'jumat': DateTime.friday, 'sabtu': DateTime.saturday,
  };

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll("jum'at", 'jumat')
      .replaceAll(RegExp(r'[,;!]+(?=\s|$)'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // ---- Amounts ---------------------------------------------------------------

  static final _amountRe = RegExp(
    r'(?<![\w.,/])(?:rp\.?\s*)?(\d+(?:[.,]\d+)*)\s*(ribu|rebu|rbu|rb|k|juta|jeti|jt|miliar|milyar|m)?(?![\w/])',
  );

  /// Amounts in [text] (dates should already be removed).
  static List<({int value, int start, int end, bool suffixed})> _amounts(String text) {
    final result = <({int value, int start, int end, bool suffixed})>[];
    for (final m in _amountRe.allMatches(text)) {
      final suffix = m.group(2);
      final value = _parseAmount(m.group(1)!, suffix);
      if (value == null || value > AppLimits.maxAmount) continue;
      if (suffix == null && value < 100) continue; // "2 kopi", "tgl 5"
      if (value <= 0) continue;
      result.add((value: value, start: m.start, end: m.end, suffixed: suffix != null));
    }
    return result;
  }

  static int? _parseAmount(String number, String? suffix) {
    final multiplier = switch (suffix) {
      'ribu' || 'rebu' || 'rbu' || 'rb' || 'k' => 1000,
      'juta' || 'jeti' || 'jt' => 1000000,
      'miliar' || 'milyar' || 'm' => 1000000000,
      _ => 1,
    };
    if (multiplier > 1) {
      // "6,5jt" / "6.5 juta" -> decimal; "1.500rb" -> thousands.
      if (RegExp(r'^\d+[.,]\d{1,2}$').hasMatch(number)) {
        final v = double.tryParse(number.replaceAll(',', '.'));
        return v == null ? null : (v * multiplier).round();
      }
      final digits = int.tryParse(number.replaceAll(RegExp(r'[.,]'), ''));
      return digits == null ? null : digits * multiplier;
    }
    // Plain number: separators are thousands; a 2-digit tail is decimals.
    final s = RegExp(r'[.,]\d{2}$').hasMatch(number) && RegExp(r'[.,]').allMatches(number).length > 1
        ? number.substring(0, number.length - 3)
        : number;
    if (RegExp(r'[.,]\d{1,2}$').hasMatch(s)) return null; // "2.5" without unit: ambiguous
    return int.tryParse(s.replaceAll(RegExp(r'[.,]'), ''));
  }

  static int? _pickAmount(List<({int value, int start, int end, bool suffixed})> amounts) {
    final suffixed = amounts.where((a) => a.suffixed).toList();
    if (suffixed.isNotEmpty) return suffixed.last.value;
    return amounts.map((a) => a.value).reduce((a, b) => a > b ? a : b);
  }

  static int? _amountAfterJadi(String text, List<({int value, int start, int end, bool suffixed})> amounts) {
    final m = RegExp(r'\b(jadi|menjadi|ke|harusnya|seharusnya)\b').allMatches(text).lastOrNull;
    if (m == null) return null;
    return amounts.where((a) => a.start >= m.end).firstOrNull?.value;
  }

  // ---- Dates -----------------------------------------------------------------

  /// Finds a date phrase for a transaction and returns it plus the text with
  /// the phrase removed.
  (DateTime?, String) _extractDate(String text) {
    DateTime? day;
    var rest = text;

    void take(Match m, DateTime d) {
      day ??= d;
      rest = rest.replaceFirst(m.group(0)!, ' ');
    }

    final rules = <(RegExp, DateTime? Function(Match))>[
      (RegExp(r'\b(kemarin|kmrn|kemaren) ?lusa\b|\blusa kemarin\b'), (_) => _daysAgo(2)),
      (RegExp(r'\b(\d{1,2}) hari (yang |yg )?lalu\b'), (m) => _daysAgo(int.parse(m.group(1)!))),
      (RegExp(r'\b(kemarin|kmrn|kemaren)( (pagi|siang|sore|malam))?\b'), (_) => _daysAgo(1)),
      (RegExp(r'\b(hari ini|tadi( (pagi|siang|sore|malam))?|barusan|sekarang)\b'), (_) => _today),
      (
        RegExp(r'\b(tgl|tanggal) (\d{1,2})(?: ([a-z]+))?(?: (\d{4}))?\b'),
        (m) => _dayOfMonth(int.parse(m.group(2)!), _monthNames[m.group(3) ?? ''],
            int.tryParse(m.group(4) ?? '')),
      ),
      (
        RegExp(r'\b(\d{1,2})[/-](\d{1,2})(?:[/-](\d{2,4}))?\b'),
        (m) => _dayOfMonth(int.parse(m.group(1)!), int.parse(m.group(2)!),
            m.group(3) == null ? null : _fullYear(int.parse(m.group(3)!))),
      ),
      (RegExp(r'\b(hari )?(senin|selasa|rabu|kamis|jumat|sabtu)( (lalu|kemarin))?\b'),
          (m) => _lastWeekday(_dayNames[m.group(2)!]!)),
      (RegExp(r'\bhari minggu( (lalu|kemarin))?\b'), (_) => _lastWeekday(DateTime.sunday)),
    ];

    for (final (re, toDate) in rules) {
      final m = re.firstMatch(rest);
      if (m == null) continue;
      final d = toDate(m);
      if (d != null) take(m, d);
    }
    if (day == null) return (null, rest);
    final d = day!;
    // Today keeps the current time (ordering); past days get midday.
    final when = isSameDay(d, now) ? now : DateTime(d.year, d.month, d.day, 12);
    return (when, rest);
  }

  DateTime _daysAgo(int n) => DateTime(_today.year, _today.month, _today.day - n);

  DateTime _lastWeekday(int weekday) {
    final diff = (_today.weekday - weekday) % 7;
    return _daysAgo(diff);
  }

  static int _fullYear(int y) => y < 100 ? 2000 + y : y;

  /// Day [day] of [month]/[year]; without a month, this month or (if that
  /// would be in the future) last month.
  DateTime? _dayOfMonth(int day, int? month, int? year) {
    if (day < 1 || day > 31) return null;
    var y = year ?? _today.year;
    var mo = month ?? _today.month;
    if (mo < 1 || mo > 12) return null;
    var d = DateTime(y, mo, day);
    if (d.month != mo) return null;
    if (d.isAfter(_today)) {
      if (month == null) {
        d = DateTime(y, mo - 1, day);
      } else if (year == null) {
        y -= 1;
        d = DateTime(y, mo, day);
      } else {
        return null;
      }
    }
    return d;
  }

  // ---- Ranges ----------------------------------------------------------------

  QueryRange _extractRange(String text) {
    final t = _today;
    final lastDays = RegExp(r'\b(\d{1,3}) hari terakhir\b').firstMatch(text);
    if (lastDays != null) {
      final n = int.parse(lastDays.group(1)!).clamp(1, 366);
      return QueryRange(DateTime(t.year, t.month, t.day - (n - 1)),
          DateTime(t.year, t.month, t.day + 1), '$n hari terakhir');
    }
    if (RegExp(r'\bhari ini\b').hasMatch(text)) {
      return QueryRange(t, DateTime(t.year, t.month, t.day + 1), 'hari ini');
    }
    if (RegExp(r'\b(kemarin|kmrn|kemaren)\b').hasMatch(text) &&
        !RegExp(r'\b(minggu|bulan|tahun) (kemarin|kmrn|kemaren)\b').hasMatch(text)) {
      return QueryRange(DateTime(t.year, t.month, t.day - 1), t, 'kemarin');
    }
    final monday = DateTime(t.year, t.month, t.day - (t.weekday - DateTime.monday));
    if (RegExp(r'\bminggu (lalu|kemarin)\b').hasMatch(text)) {
      return QueryRange(DateTime(monday.year, monday.month, monday.day - 7), monday, 'minggu lalu');
    }
    if (RegExp(r'\bminggu ini\b').hasMatch(text)) {
      return QueryRange(monday, DateTime(monday.year, monday.month, monday.day + 7), 'minggu ini');
    }
    if (RegExp(r'\bbulan (lalu|kemarin)\b').hasMatch(text)) {
      return QueryRange(DateTime(t.year, t.month - 1), DateTime(t.year, t.month), 'bulan lalu');
    }
    if (RegExp(r'\btahun (lalu|kemarin)\b').hasMatch(text)) {
      return QueryRange(DateTime(t.year - 1), DateTime(t.year), 'tahun lalu');
    }
    if (RegExp(r'\btahun ini\b').hasMatch(text)) {
      return QueryRange(DateTime(t.year), DateTime(t.year + 1), 'tahun ini');
    }
    final named = RegExp(
      r'\b(?:bulan )?(januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|nopember|desember)(?: (\d{4}))?\b',
    ).firstMatch(text);
    if (named != null) {
      final month = _monthNames[named.group(1)!]!;
      var year = int.tryParse(named.group(2) ?? '') ?? t.year;
      if (named.group(2) == null && DateTime(year, month).isAfter(t)) year -= 1;
      final start = DateTime(year, month);
      return QueryRange(start, DateTime(year, month + 1), DateFormats.monthYear.format(start));
    }
    return QueryRange(DateTime(t.year, t.month), DateTime(t.year, t.month + 1), 'bulan ini');
  }

  // ---- Categories ------------------------------------------------------------

  /// The user's category mentioned in [text]: own category names first (so
  /// custom ones work), then everyday keywords.
  Category? _matchCategory(String text, {TransactionType? prefer}) {
    final wantsIncome = prefer == TransactionType.income ||
        (prefer == null && incomeWords.any((w) => containsWord(text, w)));

    final byName = _categories.where((c) => containsWord(text, c.name.toLowerCase())).toList();
    if (byName.isNotEmpty) {
      final type = wantsIncome ? TransactionType.income : TransactionType.expense;
      return byName.where((c) => c.type == type).firstOrNull ?? byName.first;
    }

    Category? lookup(List<CategoryRule> rules, TransactionType type) {
      for (final (name, words) in rules) {
        if (words.any((w) => containsWord(text, w))) {
          final c = _categories.where((c) => c.type == type && c.name == name).firstOrNull;
          if (c != null) return c;
        }
      }
      return null;
    }

    final income = lookup(chatIncomeRules, TransactionType.income);
    if (wantsIncome && income != null) return income;
    return lookup(chatExpenseRules, TransactionType.expense) ??
        lookup(storeCategoryRules, TransactionType.expense) ??
        income;
  }

  // ---- Edit ------------------------------------------------------------------

  EditLastIntent _buildEdit(String text) {
    // "tadi" / "terakhir" point at the transaction, not at a new date.
    final cleaned = text.replaceAll(RegExp(r'\b(yang |yg )?(tadi|barusan|terakhir)\b'), ' ');
    final (date, rest) = _extractDate(cleaned);
    final amounts = _amounts(rest);
    final amount =
        _amountAfterJadi(rest, amounts) ?? (amounts.isEmpty ? null : amounts.last.value);

    // Only change the category when it's clearly the target:
    // "kategorinya jadi makan" or "... jadi makan".
    Category? category;
    final jadi = RegExp(r'\b(jadi|menjadi|harusnya|seharusnya)\b').allMatches(rest).lastOrNull;
    if (jadi != null) category = _matchCategory(rest.substring(jadi.end));
    if (category == null && RegExp(r'\bkategori(nya)?\b').hasMatch(rest)) {
      category = _matchCategory(rest.replaceAll(RegExp(r'\bkategori(nya)?\b'), ' '));
    }
    return EditLastIntent(amount: amount, category: category, date: date);
  }

  // ---- Add -------------------------------------------------------------------

  AddTransactionIntent _buildAdd(String rest, int amount, DateTime date) {
    final category = _matchCategory(rest);
    final income = category?.type == TransactionType.income ||
        (category == null && incomeWords.any((w) => containsWord(rest, w)));
    final payment = guessPaymentMethod(rest);

    var desc = rest.replaceAll(_amountRe, ' ');
    for (final w in [..._paymentWords, ...incomeWords, ..._fillers]) {
      desc = desc.replaceAll(RegExp('(^|\\s)${RegExp.escape(w)}(?=\\s|\$)'), ' ');
    }
    desc = desc.replaceAll(RegExp(r'[^\w\s&\-]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    String? description;
    if (desc.isNotEmpty && desc != category?.name.toLowerCase()) {
      final capped = desc.length > AppLimits.maxDescriptionLength
          ? desc.substring(0, AppLimits.maxDescriptionLength)
          : desc;
      description = capped[0].toUpperCase() + capped.substring(1);
    }

    return AddTransactionIntent(
      type: income ? TransactionType.income : TransactionType.expense,
      amount: amount,
      date: date,
      category: category,
      description: description,
      paymentMethod: payment,
    );
  }
}
