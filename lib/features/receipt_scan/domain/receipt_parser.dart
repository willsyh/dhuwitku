import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_keywords.dart';
import '../../../core/utils/text_match.dart';

/// One line of text found by OCR, with its position on the image.
class OcrLine {
  const OcrLine(this.text, this.left, this.top, this.right, this.bottom);
  final String text;
  final double left;
  final double top;
  final double right;
  final double bottom;

  double get centerY => (top + bottom) / 2;
  double get height => bottom - top;
}

/// What could be read from a receipt. Any field may be null.
class ReceiptData {
  const ReceiptData({
    this.total,
    this.date,
    this.merchant,
    this.categoryName,
    this.paymentMethod,
    this.totalFromKeyword = false,
  });

  /// Whole Rupiah.
  final int? total;
  final DateTime? date;
  final String? merchant;

  /// Name of a default expense category (e.g. 'Bensin'), if one fits.
  final String? categoryName;

  /// One of `paymentMethods`, if mentioned on the receipt.
  final String? paymentMethod;

  /// True when the total came from a "TOTAL"-like label; false when it was
  /// guessed as the largest amount (less reliable).
  final bool totalFromKeyword;

  bool get isEmpty =>
      total == null && date == null && merchant == null && categoryName == null;
}

/// Deterministic, offline parsing of Indonesian shop receipts.
abstract final class ReceiptParser {
  /// Groups OCR lines into visual rows (top to bottom, left to right).
  /// Receipts put labels and amounts in separate columns, and OCR returns them
  /// as separate lines; joining them per row puts "TOTAL" next to its amount.
  static List<String> groupRows(List<OcrLine> lines) {
    final sorted = [...lines.where((l) => l.text.trim().isNotEmpty)]
      ..sort((a, b) => a.centerY.compareTo(b.centerY));
    final rows = <List<OcrLine>>[];
    for (final line in sorted) {
      final row = rows.isEmpty ? null : rows.last;
      if (row != null) {
        final ref = row.first;
        final tolerance = 0.5 * (ref.height < line.height ? ref.height : line.height);
        if ((line.centerY - ref.centerY).abs() <= tolerance) {
          row.add(line);
          continue;
        }
      }
      rows.add([line]);
    }
    return [
      for (final row in rows)
        (row..sort((a, b) => a.left.compareTo(b.left))).map((l) => l.text.trim()).join('   '),
    ];
  }

  static ReceiptData parse(List<String> rows, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final clean = rows.map((r) => r.trim()).where((r) => r.isNotEmpty).toList();
    if (clean.isEmpty) return const ReceiptData();

    final (total, fromKeyword) = _findTotal(clean);
    final merchant = _findMerchant(clean);
    return ReceiptData(
      total: total,
      totalFromKeyword: fromKeyword,
      date: _findDate(clean, today),
      merchant: merchant,
      categoryName: _guessCategory(clean),
      paymentMethod: guessPaymentMethod(clean.join('\n').toLowerCase()),
    );
  }

  // ---- Amounts ---------------------------------------------------------------

  // Numbers like 45.000 / 45,000 / 1.234.567 / 45.000,00 / Rp45000 / 45000.
  // Not part of a date (04/11/2026), time (14:05) or longer number (phone).
  static final _amountPattern = RegExp(
    r'(?<![\d.,/:\-])(?:rp\.?\s*)?(\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{2})?|\d{4,9}(?:[.,]\d{2})?)(?![.,]?\d|[/:])',
    caseSensitive: false,
  );

  /// Parses the amounts in a row, in left-to-right order.
  static List<int> amountsIn(String row) {
    final result = <int>[];
    for (final m in _amountPattern.allMatches(row)) {
      final value = _parseAmount(m.group(1)!);
      if (value != null && value >= 100 && value <= AppLimits.maxAmount) result.add(value);
    }
    return result;
  }

  /// "45.000" -> 45000, "45.000,00" -> 45000, "45000.00" -> 45000.
  static int? _parseAmount(String raw) {
    // A thousands group always has 3 digits, so a 2-digit tail is decimals.
    final s = RegExp(r'[.,]\d{2}$').hasMatch(raw) ? raw.substring(0, raw.length - 3) : raw;
    return int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  // Ordered best-first: an earlier keyword is a more reliable total.
  static const _totalKeywords = [
    'grand total',
    'total bayar',
    'total pembayaran',
    'total belanja',
    'total harga',
    'jumlah bayar',
    'jumlah tagihan',
    'total tagihan',
    'amount due',
    'total due',
    'total',
    'jumlah',
    'tagihan',
    'subtotal',
    'sub total',
  ];

  // Rows that carry amounts but are not the total.
  static final _notTotal = RegExp(
    r'tunai|cash|kembali|change|diskon|discount|disc\b|potongan|hemat|ppn|pajak|tax|service|item|qty|poin|point|voucher|tendered|dibayar|bayar tunai|debit|kartu|card|saldo',
    caseSensitive: false,
  );

  static (int?, bool) _findTotal(List<String> rows) {
    int? best;
    var bestRank = _totalKeywords.length;
    for (var i = 0; i < rows.length; i++) {
      final lower = rows[i].toLowerCase();
      final rank = _totalKeywords.indexWhere((k) => containsWord(lower, k));
      if (rank < 0) continue;
      // "SUBTOTAL" contains "total"; rank it as subtotal.
      final isSub = lower.contains('subtotal') || lower.contains('sub total');
      final effectiveRank = isSub ? _totalKeywords.indexOf('subtotal') : rank;
      // A keyword row that also says cash/discount/etc. isn't the total
      // ("TOTAL DISKON", "TOTAL ITEM"), unless it's a strong label.
      if (effectiveRank > _totalKeywords.indexOf('amount due') && _notTotal.hasMatch(lower)) continue;

      var amounts = amountsIn(_afterKeyword(rows[i]));
      if (amounts.isEmpty && i + 1 < rows.length && !_notTotal.hasMatch(rows[i + 1])) {
        amounts = amountsIn(rows[i + 1]);
      }
      if (amounts.isEmpty) continue;
      final value = amounts.last; // the amount column is on the right
      if (effectiveRank < bestRank || (effectiveRank == bestRank && value > (best ?? 0))) {
        best = value;
        bestRank = effectiveRank;
      }
    }
    if (best != null) return (best, true);

    // Fallback: the largest amount on rows that aren't cash/change lines.
    int? largest;
    for (final row in rows) {
      if (_notTotal.hasMatch(row) || _looksLikeId(row)) continue;
      for (final a in amountsIn(row)) {
        if (largest == null || a > largest) largest = a;
      }
    }
    return (largest, false);
  }

  /// Text after the first ':' (avoids reading numbers in labels like "TOTAL 3 ITEM").
  static String _afterKeyword(String row) {
    final i = row.indexOf(':');
    return i >= 0 ? row.substring(i + 1) : row;
  }

  static bool _looksLikeId(String row) => RegExp(
        r'npwp|telp|tel\.|phone|hp\b|no\.|nomor|trx|ref|struk|nota|invoice|kasir|(?<![\d.])\d{1,2}:\d{2}(?!\d)',
        caseSensitive: false,
      ).hasMatch(row);

  // ---- Date ------------------------------------------------------------------

  static const _months = {
    'jan': 1, 'januari': 1, 'january': 1,
    'feb': 2, 'februari': 2, 'february': 2, 'peb': 2,
    'mar': 3, 'maret': 3, 'march': 3,
    'apr': 4, 'april': 4,
    'mei': 5, 'may': 5,
    'jun': 6, 'juni': 6, 'june': 6,
    'jul': 7, 'juli': 7, 'july': 7,
    'agu': 8, 'agt': 8, 'ags': 8, 'agus': 8, 'agustus': 8, 'aug': 8, 'august': 8,
    'sep': 9, 'sept': 9, 'september': 9,
    'okt': 10, 'oct': 10, 'oktober': 10, 'october': 10,
    'nov': 11, 'nop': 11, 'november': 11, 'nopember': 11,
    'des': 12, 'dec': 12, 'desember': 12, 'december': 12,
  };

  static DateTime? _findDate(List<String> rows, DateTime now) {
    final numeric = RegExp(r'(?<!\d)(\d{1,4})[/.\-](\d{1,2})[/.\-](\d{2,4})(?!\d)');
    final named = RegExp(r'(?<!\d)(\d{1,2})[\s\-./]*([a-z]{3,9})[\s\-./,]*(\d{2,4})(?!\d)', caseSensitive: false);
    final time = RegExp(r'(?<!\d)([01]?\d|2[0-3])[:.]([0-5]\d)(?::([0-5]\d))?(?!\d)');

    for (final row in rows) {
      DateTime? date;
      final n = numeric.firstMatch(row);
      if (n != null) {
        final a = int.parse(n.group(1)!), b = int.parse(n.group(2)!), c = int.parse(n.group(3)!);
        date = n.group(1)!.length == 4
            ? _validDate(a, b, c, now) // yyyy-mm-dd
            : (_validDate(_year(c), b, a, now) ?? _validDate(_year(c), a, b, now)); // dd/mm/yy, else mm/dd/yy
      }
      if (date == null) {
        for (final m in named.allMatches(row)) {
          final month = _months[m.group(2)!.toLowerCase()];
          if (month == null) continue;
          date = _validDate(_year(int.parse(m.group(3)!)), month, int.parse(m.group(1)!), now);
          if (date != null) break;
        }
      }
      if (date == null) continue;

      // Time on the same row, outside the date itself.
      final rest = n != null ? row.replaceFirst(n.group(0)!, ' ') : row;
      final t = time.firstMatch(rest);
      if (t != null) {
        final withTime = DateTime(date.year, date.month, date.day, int.parse(t.group(1)!),
            int.parse(t.group(2)!), int.tryParse(t.group(3) ?? '') ?? 0);
        if (!withTime.isAfter(now)) return withTime;
      }
      return date;
    }
    return null;
  }

  static int _year(int y) => y < 100 ? 2000 + y : y;

  static DateTime? _validDate(int year, int month, int day, DateTime now) {
    if (year < 2000 || month < 1 || month > 12 || day < 1 || day > 31) return null;
    final d = DateTime(year, month, day);
    if (d.month != month) return null; // e.g. 31 Feb
    if (d.isAfter(DateTime(now.year, now.month, now.day))) return null; // no future receipts
    return d;
  }

  // ---- Merchant --------------------------------------------------------------

  static final _skipForMerchant = RegExp(
    r'^(struk|receipt|nota|invoice|faktur|selamat|welcome|terima kasih|thank)|jl\.?\s|jalan|telp|tel\.|phone|npwp|kasir|cashier|www\.|http|\.com|@',
    caseSensitive: false,
  );

  static String? _findMerchant(List<String> rows) {
    for (final row in rows.take(5)) {
      final text = row.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
      final letters = RegExp(r'[A-Za-z]').allMatches(text).length;
      final digits = RegExp(r'\d').allMatches(text).length;
      if (letters < 3 || digits > letters || _skipForMerchant.hasMatch(text)) continue;
      if (_findDate([text], DateTime(2100)) != null) continue;
      final name = text.length > AppLimits.maxCategoryNameLength
          ? text.substring(0, AppLimits.maxCategoryNameLength).trim()
          : text;
      return _titleCaseIfShouting(name);
    }
    return null;
  }

  static String _titleCaseIfShouting(String s) {
    final letters = s.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.isEmpty || letters != letters.toUpperCase()) return s;
    return s
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  // ---- Category & payment ----------------------------------------------------

  static String? _guessCategory(List<String> rows) {
    // The header (store name) is the strongest signal; item lines like
    // "KOPI KAPAL API" on a minimarket receipt should not win.
    String? match(String text) {
      final lower = text.toLowerCase();
      for (final (name, words) in storeCategoryRules) {
        if (words.any((w) => containsWord(lower, w))) return name;
      }
      return null;
    }

    return match(rows.take(4).join('\n')) ?? match(rows.join('\n'));
  }
}
