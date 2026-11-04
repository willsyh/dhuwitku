import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../categories/presentation/category_providers.dart';
import '../../transactions/presentation/transaction_providers.dart';
import '../data/backup_service.dart';
import '../data/settings_repository.dart';
import '../data/demo_data.dart';
import '../domain/csv_builder.dart';
import '../domain/currency.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() task) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await task();
    } catch (e) {
      showAppSnack(errorMessage(e), kind: SnackKind.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String get _stamp => DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

  // ---- Theme & currency ----------------------------------------------------

  Future<void> _chooseTheme() async {
    final current = ref.read(themeModeProvider);
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Tema'),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(context, v),
            child: const Column(
              children: [
                RadioListTile(value: ThemeMode.system, title: Text('Ikuti sistem')),
                RadioListTile(value: ThemeMode.light, title: Text('Terang')),
                RadioListTile(value: ThemeMode.dark, title: Text('Gelap')),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked != null) await ref.read(themeModeProvider.notifier).set(picked);
  }

  Future<void> _chooseCurrency(CurrencyOption current) async {
    final picked = await showDialog<CurrencyOption>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Mata uang'),
        children: [
          RadioGroup<String>(
            groupValue: current.code,
            onChanged: (code) => Navigator.pop(context, currencyFor(code)),
            child: Column(
              children: [
                for (final c in currencyOptions)
                  RadioListTile(value: c.code, title: Text('${c.name} (${c.symbol})')),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: Text(
              'Hanya simbol yang berubah. Jumlah tidak dikonversi dan dicatat tanpa desimal.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    await _run(() => ref
        .read(settingsRepositoryProvider)
        .set(SettingsRepository.currencyKey, picked.code));
  }

  // ---- Data ---------------------------------------------------------------

  Future<void> _exportCsv() => _run(() async {
        final txs = await ref.read(transactionRepositoryProvider).getAll();
        if (txs.isEmpty) {
          showAppSnack('Belum ada transaksi untuk diekspor.', kind: SnackKind.info);
          return;
        }
        // BOM so Excel opens the file as UTF-8.
        final bytes = utf8.encode('﻿${CsvBuilder.build(txs)}');
        final uri = await FilePicker.saveFile(
          dialogTitle: 'Simpan CSV',
          fileName: 'dhuwitku_transaksi_$_stamp.csv',
          bytes: bytes,
          mimeType: 'text/csv',
        );
        if (uri != null) showAppSnack('${txs.length} transaksi diekspor ke CSV.');
      });

  Future<void> _backup() => _run(() async {
        final bytes = await const BackupService().createBackup(ref.read(databaseProvider));
        final uri = await FilePicker.saveFile(
          dialogTitle: 'Simpan cadangan',
          fileName: 'dhuwitku_cadangan_$_stamp.sqlite',
          bytes: bytes,
          mimeType: 'application/octet-stream',
        );
        if (uri != null) showAppSnack('Cadangan berhasil disimpan.');
      });

  Future<void> _restore() async {
    final ok = await _confirm(
      title: 'Pulihkan dari cadangan?',
      message: 'Semua data saat ini akan diganti dengan isi file cadangan. '
          'Sebaiknya buat cadangan data saat ini terlebih dahulu.',
      action: 'Pilih File',
    );
    if (!ok) return;
    await _run(() async {
      final file = await FilePicker.pickFile(dialogTitle: 'Pilih file cadangan');
      if (file == null) return;
      final bytes = await file.readAsBytes();
      try {
        await const BackupService().restore(bytes, ref.read(databaseProvider));
      } finally {
        // Reopen the database (restored or untouched); every screen reloads.
        ref.invalidate(databaseProvider);
      }
      showAppSnack('Data berhasil dipulihkan.');
    });
  }

  Future<void> _loadDemo() async {
    final ok = await _confirm(
      title: 'Muat data demo?',
      message: 'Menambahkan contoh transaksi 90 hari terakhir untuk mencoba aplikasi. '
          'Data demo ditandai dan bisa dihapus kapan saja tanpa mengganggu data aslimu.',
      action: 'Muat Demo',
      destructive: false,
    );
    if (!ok) return;
    await _run(() async {
      final categories = await ref.read(categoryRepositoryProvider).getAll();
      final drafts = DemoData.build(categories);
      await ref.read(transactionRepositoryProvider).addAll(drafts, isDemo: true);
      showAppSnack('${drafts.length} transaksi demo ditambahkan.');
    });
  }

  Future<void> _removeDemo() => _run(() async {
        final n = await ref.read(transactionRepositoryProvider).deleteDemoData();
        showAppSnack('$n transaksi demo dihapus.');
      });

  Future<void> _clearAll() async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hapus semua data?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Semua transaksi, anggaran, kategori buatanmu, dan pengaturan data akan '
                  'dihapus permanen. Kategori bawaan akan dibuat ulang.\n\nKetik HAPUS untuk melanjutkan.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'HAPUS'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size(64, 40),
              ),
              onPressed: controller.text.trim().toUpperCase() == 'HAPUS'
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('Hapus Semua'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (ok != true) return;
    await _run(() async {
      await ref.read(databaseProvider).resetAllData();
      showAppSnack('Semua data telah dihapus.');
    });
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    bool destructive = true,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: destructive ? Theme.of(context).colorScheme.error : null,
              minimumSize: const Size(64, 40),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok == true;
  }

  // ---- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final currency = ref.watch(currencyProvider).value ?? currencyOptions.first;
    final hasDemo = ref.watch(hasDemoDataProvider);

    final themeLabel = switch (themeMode) {
      ThemeMode.system => 'Ikuti sistem',
      ThemeMode.light => 'Terang',
      ThemeMode.dark => 'Gelap',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        bottom: _busy
            ? const PreferredSize(preferredSize: Size.fromHeight(2), child: LinearProgressIndicator())
            : null,
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          children: [
            _Group(title: 'Tampilan', children: [
              _Item(Icons.palette_outlined, 'Tema', subtitle: themeLabel, onTap: _chooseTheme),
              _Item(Icons.payments_outlined, 'Mata uang',
                  subtitle: '${currency.code} (${currency.symbol})', onTap: () => _chooseCurrency(currency)),
            ]),
            _Group(title: 'Kelola', children: [
              _Item(Icons.category_outlined, 'Kategori',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.categories)),
              _Item(Icons.flag_outlined, 'Anggaran',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.budgets)),
            ]),
            _Group(title: 'Data', children: [
              _Item(Icons.table_view_outlined, 'Ekspor transaksi (CSV)', onTap: _exportCsv),
              _Item(Icons.backup_outlined, 'Cadangkan database', onTap: _backup),
              _Item(Icons.settings_backup_restore_rounded, 'Pulihkan dari cadangan', onTap: _restore),
            ]),
            _Group(title: 'Mode Demo', children: [
              if (hasDemo)
                _Item(Icons.science_outlined, 'Hapus data demo',
                    subtitle: 'Hanya transaksi berlabel demo yang dihapus', onTap: _removeDemo)
              else
                _Item(Icons.science_outlined, 'Muat data demo',
                    subtitle: 'Contoh transaksi untuk mencoba fitur', onTap: _loadDemo),
            ]),
            _Group(title: 'Zona Bahaya', children: [
              _Item(Icons.delete_forever_outlined, 'Hapus semua data',
                  destructive: true, onTap: _clearAll),
            ]),
            _Group(title: 'Tentang', children: [
              const _Item(Icons.info_outline_rounded, 'Versi aplikasi', subtitle: AppInfo.version),
              const _Item(Icons.cloud_off_outlined, 'Penyimpanan',
                  subtitle: 'Semua data tersimpan di perangkat ini (offline)'),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: Text(title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.icon, this.title, {this.subtitle, this.onTap, this.destructive = false});
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Theme.of(context).colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
