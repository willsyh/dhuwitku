import 'package:intl/intl.dart';

import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';
import '../../transactions/domain/finance_transaction.dart';

/// Builds a CSV of transactions. Dates are ISO (yyyy-MM-dd) and amounts are
/// plain integers so spreadsheets parse them reliably.
abstract final class CsvBuilder {
  /// Column headers in the active language.
  static List<String> get header {
    final l = l10n;
    return [
      'ID',
      l.date,
      l.csvTime,
      l.type,
      l.category,
      l.amount,
      l.note,
      l.paymentMethod,
      l.csvCreated,
      l.updatedAt,
    ];
  }

  static final _date = DateFormat('yyyy-MM-dd');
  static final _time = DateFormat('HH:mm');
  static final _stamp = DateFormat('yyyy-MM-dd HH:mm:ss');

  static String build(List<FinanceTransaction> transactions) {
    final buffer = StringBuffer()..writeln(header.map(escape).join(','));
    for (final t in transactions) {
      buffer.writeln([
        '${t.id}',
        _date.format(t.date),
        _time.format(t.date),
        t.type.label,
        t.category.label,
        '${t.amount}',
        t.description ?? '',
        t.paymentMethod == null ? '' : paymentLabel(t.paymentMethod!),
        _stamp.format(t.createdAt),
        _stamp.format(t.updatedAt),
      ].map(escape).join(','));
    }
    return buffer.toString();
  }

  /// Quotes when needed and neutralises spreadsheet formula injection.
  static String escape(String value) {
    var v = value;
    if (v.isNotEmpty && '=+-@\t\r'.contains(v[0]) && int.tryParse(v) == null) {
      v = "'$v";
    }
    final needsQuotes = v.contains(',') || v.contains('"') || v.contains('\n') || v.contains('\r');
    return needsQuotes ? '"${v.replaceAll('"', '""')}"' : v;
  }
}
