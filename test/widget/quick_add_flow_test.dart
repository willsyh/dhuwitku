import 'package:dhuwitku/app/app.dart';
import 'package:dhuwitku/core/database/app_database.dart';
import 'package:dhuwitku/core/database/database_provider.dart';
import 'package:dhuwitku/core/utils/formatters.dart';
import 'package:dhuwitku/features/settings/presentation/settings_providers.dart';
import 'package:dhuwitku/features/transactions/data/transaction_repository.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  setUpAll(() async {
    Intl.defaultLocale = appLocale;
    await initializeDateFormatting(appLocale);
  });

  Future<AppDatabase> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
      child: const DhuwitkuApp(),
    ));
    await tester.pumpAndSettle();
    return db;
  }

  Future<void> disposeApp(WidgetTester tester, AppDatabase db) async {
    // Unmount so stream subscriptions are cancelled; the database itself is
    // closed in addTearDown, outside the fake-async test body.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('empty dashboard shows zero figures, not fake data', (tester) async {
    final db = await pumpApp(tester);
    expect(find.text('Total Saldo'), findsOneWidget);
    expect(find.text('Rp 0'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Belum ada transaksi'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Belum ada transaksi'), findsOneWidget);
    await disposeApp(tester, db);
  });

  testWidgets('quick add: amount → category → save updates database and dashboard', (tester) async {
    final db = await pumpApp(tester);

    await tester.tap(find.byTooltip('Catat transaksi'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Simpan'), findsOneWidget);

    // Saving without amount shows a validation error.
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan jumlah lebih dari 0'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.tap(find.text('5'));
    await tester.tap(find.text('000'));
    await tester.pump();
    expect(find.text('Rp 25.000'), findsOneWidget);

    // Category is required.
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih kategori terlebih dahulu'), findsOneWidget);

    await tester.tap(find.text('Kopi'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Simpan'));
    await tester.pumpAndSettle();

    final saved = (await tester.runAsync(() => TransactionRepository(db).getAll()))!;
    expect(saved.single.amount, 25000);
    expect(saved.single.category.name, 'Kopi');

    // Dashboard reflects it: balance, recent list and success message.
    expect(find.text('Rp -25.000'), findsNothing);
    expect(find.text('-Rp 25.000'), findsWidgets);
    expect(find.text('Kopi'), findsWidgets);
    expect(find.textContaining('tersimpan'), findsOneWidget);

    await disposeApp(tester, db);
  });

  testWidgets('navigates between the four main tabs', (tester) async {
    final db = await pumpApp(tester);
    for (final label in ['Transaksi', 'Statistik', 'Pengaturan', 'Beranda']) {
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }
    expect(find.text('Total Saldo'), findsOneWidget);
    await disposeApp(tester, db);
  });
}
