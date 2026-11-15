import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Optional holiday looks. Each one swaps the app's primary color and adds a
/// greeting and icon artwork on the dashboard. Chosen manually in Settings.
/// Stored by [name], so don't rename values once released.
enum FestiveTheme {
  none('Tidak ada', AppColors.primary, '', '', Icons.palette_outlined, Icons.palette_outlined),
  idulFitri(
    'Idul Fitri',
    Color(0xFF059669),
    'Selamat Idul Fitri',
    'Mohon maaf lahir dan batin',
    Icons.mosque_rounded,
    Icons.nightlight_round,
  ),
  idulAdha(
    'Idul Adha',
    Color(0xFF0F766E),
    'Selamat Idul Adha',
    'Semoga berkah dan penuh makna',
    Icons.mosque_rounded,
    Icons.volunteer_activism_rounded,
  ),
  imlek(
    'Imlek',
    Color(0xFFC81E1E),
    'Gong Xi Fa Cai',
    'Selamat Tahun Baru Imlek',
    Icons.temple_buddhist_rounded,
    Icons.auto_awesome_rounded,
  ),
  paskah(
    'Paskah',
    Color(0xFF8B5CF6),
    'Selamat Paskah',
    'Damai dan sukacita untukmu',
    Icons.cruelty_free_rounded,
    Icons.egg_rounded,
  ),
  natal(
    'Natal',
    Color(0xFF15803D),
    'Selamat Natal',
    'Damai dan sukacita untukmu',
    Icons.park_rounded,
    Icons.card_giftcard_rounded,
  ),
  tahunBaru(
    'Tahun Baru',
    Color(0xFF4F46E5),
    'Selamat Tahun Baru',
    'Awal baru, catatan keuangan baru',
    Icons.celebration_rounded,
    Icons.auto_awesome_rounded,
  ),
  valentine(
    'Valentine',
    Color(0xFFE11D48),
    'Selamat Hari Valentine',
    'Hari penuh kasih sayang',
    Icons.favorite_rounded,
    Icons.local_florist_rounded,
  ),
  ramadan(
    'Ramadan',
    Color(0xFF0E7490),
    'Marhaban ya Ramadan',
    'Selamat menunaikan ibadah puasa',
    Icons.nightlight_round,
    Icons.star_rounded,
  ),
  nyepi(
    'Nyepi',
    Color(0xFF475569),
    'Selamat Hari Raya Nyepi',
    'Damai dalam keheningan',
    Icons.temple_hindu_rounded,
    Icons.self_improvement_rounded,
  ),
  waisak(
    'Waisak',
    Color(0xFFB45309),
    'Selamat Hari Raya Waisak',
    'Semoga semua makhluk berbahagia',
    Icons.temple_buddhist_rounded,
    Icons.spa_rounded,
  ),
  kartini(
    'Hari Kartini',
    Color(0xFF9D174D),
    'Selamat Hari Kartini',
    'Habis gelap terbitlah terang',
    Icons.face_3_rounded,
    Icons.menu_book_rounded,
  ),
  kemerdekaan(
    'Kemerdekaan RI',
    Color(0xFFDC2626),
    'Dirgahayu Indonesia',
    'Merdeka! 17 Agustus',
    Icons.flag_rounded,
    Icons.military_tech_rounded,
  ),
  halloween(
    'Halloween',
    Color(0xFFC2410C),
    'Happy Halloween',
    'Awas, pengeluaran seram!',
    Icons.nights_stay_rounded,
    Icons.pest_control_rounded,
  ),
  hariIbu(
    'Hari Ibu',
    Color(0xFFC026D3),
    'Selamat Hari Ibu',
    'Terima kasih, Ibu',
    Icons.local_florist_rounded,
    Icons.favorite_rounded,
  );

  const FestiveTheme(
    this.label,
    this.primary,
    this.greeting,
    this.subtitle,
    this.icon,
    this.accentIcon,
  );

  final String label;
  final Color primary;
  final String greeting;
  final String subtitle;

  /// Main artwork: badge next to the greeting and large watermark on the card.
  final IconData icon;

  /// Smaller companion watermark.
  final IconData accentIcon;

  bool get isActive => this != FestiveTheme.none;

  static FestiveTheme fromName(String? name) =>
      FestiveTheme.values.firstWhere((t) => t.name == name, orElse: () => FestiveTheme.none);
}
