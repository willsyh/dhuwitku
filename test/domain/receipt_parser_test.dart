import 'package:dhuwitku/features/receipt_scan/domain/receipt_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 15, 20);

  ReceiptData parse(String text) => ReceiptParser.parse(text.trim().split('\n'), now: now);

  group('amounts', () {
    test('reads Indonesian number formats', () {
      expect(ReceiptParser.amountsIn('TOTAL 45.000'), [45000]);
      expect(ReceiptParser.amountsIn('Total Rp 1.250.000'), [1250000]);
      expect(ReceiptParser.amountsIn('TOTAL : 45,000'), [45000]);
      expect(ReceiptParser.amountsIn('Total 45.000,00'), [45000]);
      expect(ReceiptParser.amountsIn('Rp45000'), [45000]);
    });
    test('ignores dates, times, phone numbers and small counts', () {
      expect(ReceiptParser.amountsIn('04/11/2026 14:05'), isEmpty);
      expect(ReceiptParser.amountsIn('Telp 081234567890'), isEmpty);
      expect(ReceiptParser.amountsIn('Total item 3'), isEmpty);
    });
  });

  test('minimarket receipt: TOTAL not TUNAI/KEMBALI, date, category, cash', () {
    final r = parse('''
INDOMARET
JL. SUDIRMAN NO. 10 JAKARTA
NPWP 01.234.567.8-012.000
14.11.26-19:42 2.0.29 1234/KASIR/01
AQUA 600ML      2  3,500    7,000
KOPI KAPAL API  1  15,500  15,500
ROTI TAWAR      1  16,000  16,000
HARGA JUAL :           38,500
TOTAL :                38,500
TUNAI :                50,000
KEMBALI :              11,500
''');
    expect(r.total, 38500);
    expect(r.totalFromKeyword, isTrue);
    expect(r.merchant, 'Indomaret');
    expect(r.categoryName, 'Belanja Harian'); // store name beats the "KOPI" item line
    expect(r.paymentMethod, 'Tunai');
    expect(r.date, DateTime(2026, 11, 14, 19, 42));
  });

  test('restaurant: GRAND TOTAL wins over SUBTOTAL and tax lines, named month', () {
    final r = parse('''
Rumah Makan Sederhana
Jl. Merdeka 5
12 Nov 2026 13:20
Nasi Rendang 2   50.000
Es Teh 2         10.000
Subtotal         60.000
PPN 10%           6.000
Service 5%        3.000
GRAND TOTAL      69.000
QRIS             69.000
''');
    expect(r.total, 69000);
    expect(r.categoryName, 'Makan');
    expect(r.paymentMethod, 'QRIS');
    expect(r.date, DateTime(2026, 11, 12, 13, 20));
    expect(r.merchant, 'Rumah Makan Sederhana');
  });

  test('gas station receipt', () {
    final r = parse('''
SPBU 34.12345
PERTAMINA
Tgl: 10/11/2026 07:45
Produk: PERTALITE
Volume: 5.00 L
Harga/L: Rp 10.000
Total Bayar: Rp 50.000
Debit BCA
''');
    expect(r.total, 50000);
    expect(r.categoryName, 'Bensin');
    expect(r.paymentMethod, 'Debit');
    expect(r.date, DateTime(2026, 11, 10, 7, 45));
  });

  test('label and amount on the next line', () {
    final r = parse('''
Kopi Kenangan
TOTAL
Rp 28.000
''');
    expect(r.total, 28000);
    expect(r.categoryName, 'Kopi');
  });

  test('no total label: falls back to the largest amount, flagged as a guess', () {
    final r = parse('''
Warung Bu Sri
Nasi campur   20.000
Teh manis      5.000
       25.000
Tunai 50.000
''');
    expect(r.total, 25000);
    expect(r.totalFromKeyword, isFalse);
  });

  test('future and impossible dates are ignored', () {
    expect(parse('Toko A\n31/02/2026\nTotal 10.000').date, isNull);
    expect(parse('Toko A\n01/01/2027\nTotal 10.000').date, isNull);
  });

  test('unreadable text gives empty data', () {
    expect(ReceiptParser.parse(const [], now: now).isEmpty, isTrue);
    expect(parse('~~ ## ..').total, isNull);
  });

  test('groupRows joins label and amount columns on the same row', () {
    const lines = [
      OcrLine('TOTAL', 10, 100, 80, 120),
      OcrLine('45.000', 300, 102, 380, 121),
      OcrLine('INDOMARET', 50, 10, 200, 30),
      OcrLine('TUNAI', 10, 130, 80, 150),
      OcrLine('50.000', 300, 131, 380, 150),
    ];
    expect(ReceiptParser.groupRows(lines), ['INDOMARET', 'TOTAL   45.000', 'TUNAI   50.000']);
  });
}
