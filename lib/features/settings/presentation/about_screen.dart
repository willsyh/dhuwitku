import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';

/// "Tentang Dhuwitku": what the app is, what it does, and how data is handled.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    (Icons.bolt_rounded, 'Catat dalam hitungan detik',
        'Masukkan jumlah, pilih kategori, simpan. Cocok untuk pengeluaran kecil harian seperti makan, kopi, bensin, dan parkir.'),
    (Icons.dashboard_rounded, 'Ringkasan sekilas',
        'Saldo, pemasukan, dan pengeluaran bulan ini langsung terlihat di Beranda.'),
    (Icons.flag_rounded, 'Anggaran & peringatan',
        'Atur anggaran bulanan dan batas per kategori. Peringatan muncul saat terpakai 75%, 90%, dan lebih dari 100%.'),
    (Icons.insights_rounded, 'Statistik & insight',
        'Grafik harian hingga tahunan, rincian per kategori, dan insight yang dihitung dari datamu sendiri.'),
    (Icons.backup_rounded, 'Ekspor & cadangan',
        'Ekspor transaksi ke CSV, cadangkan, dan pulihkan database kapan saja.'),
  ];

  static const _privacy = [
    (Icons.cloud_off_rounded, 'Bekerja tanpa internet'),
    (Icons.no_accounts_rounded, 'Tanpa akun dan tanpa login'),
    (Icons.phone_android_rounded, 'Data hanya tersimpan di perangkat ini'),
    (Icons.block_rounded, 'Tanpa iklan dan tanpa pelacakan'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Header: logo, name, version, tagline
          Center(
            child: Column(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        size: 44, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppInfo.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('Versi ${AppInfo.version}', style: muted),
                const SizedBox(height: 10),
                Text(
                  AppInfo.tagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Text(
              '${AppInfo.name} adalah aplikasi pencatat keuangan pribadi yang dirancang untuk '
              'mencatat transaksi harian dengan cepat, terutama pengeluaran kecil yang sering '
              'terlupa. Nama "Dhuwitku" berasal dari bahasa Jawa yang berarti "uangku".\n\n'
              'Tujuannya sederhana: catat uangmu dalam hitungan detik, dan pahami kondisi '
              'keuanganmu hanya dengan sekali lihat.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Fitur Utama'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                for (final (i, f) in _features.indexed) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryAvatar(icon: f.$1, color: scheme.primary, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(f.$2,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(f.$3, style: muted),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Privasi'),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final p in _privacy)
                  ListTile(
                    dense: true,
                    leading: Icon(p.$1, color: scheme.primary),
                    title: Text(p.$2, style: theme.textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Karena data hanya ada di perangkat ini, gunakan Pengaturan → Cadangkan database '
              'secara berkala agar datamu aman jika HP hilang atau diganti.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text('Dibuat dengan Flutter · Mata uang: Rupiah (IDR)',
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
