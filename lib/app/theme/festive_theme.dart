import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import 'app_colors.dart';

/// Optional holiday looks. Each one swaps the app's primary color and adds a
/// greeting and icon artwork on the dashboard. Chosen manually in Settings.
/// Stored by [name], so don't rename values once released.
enum FestiveTheme {
  none(AppColors.primary, Icons.palette_outlined, Icons.palette_outlined),
  idulFitri(Color(0xFF059669), Icons.mosque_rounded, Icons.nightlight_round),
  idulAdha(Color(0xFF0F766E), Icons.mosque_rounded, Icons.volunteer_activism_rounded),
  imlek(Color(0xFFC81E1E), Icons.temple_buddhist_rounded, Icons.auto_awesome_rounded),
  paskah(Color(0xFF8B5CF6), Icons.cruelty_free_rounded, Icons.egg_rounded),
  natal(Color(0xFF15803D), Icons.park_rounded, Icons.card_giftcard_rounded),
  tahunBaru(Color(0xFF4F46E5), Icons.celebration_rounded, Icons.auto_awesome_rounded),
  valentine(Color(0xFFE11D48), Icons.favorite_rounded, Icons.local_florist_rounded),
  ramadan(Color(0xFF0E7490), Icons.nightlight_round, Icons.star_rounded),
  nyepi(Color(0xFF475569), Icons.temple_hindu_rounded, Icons.self_improvement_rounded),
  waisak(Color(0xFFB45309), Icons.temple_buddhist_rounded, Icons.spa_rounded),
  kartini(Color(0xFF9D174D), Icons.face_3_rounded, Icons.menu_book_rounded),
  kemerdekaan(Color(0xFFDC2626), Icons.flag_rounded, Icons.military_tech_rounded),
  halloween(Color(0xFFC2410C), Icons.nights_stay_rounded, Icons.pest_control_rounded),
  hariIbu(Color(0xFFC026D3), Icons.local_florist_rounded, Icons.favorite_rounded);

  const FestiveTheme(this.primary, this.icon, this.accentIcon);

  final Color primary;

  /// Main artwork: badge next to the greeting.
  final IconData icon;

  /// Smaller companion icon.
  final IconData accentIcon;

  /// Name in the active language.
  String get label {
    final l = l10n;
    return switch (this) {
        none => l.festiveNone,
        idulFitri => l.festiveIdulFitri,
        idulAdha => l.festiveIdulAdha,
        imlek => l.festiveImlek,
        paskah => l.festivePaskah,
        natal => l.festiveNatal,
        tahunBaru => l.festiveTahunBaru,
        valentine => l.festiveValentine,
        ramadan => l.festiveRamadan,
        nyepi => l.festiveNyepi,
        waisak => l.festiveWaisak,
        kartini => l.festiveKartini,
        kemerdekaan => l.festiveKemerdekaan,
        halloween => l.festiveHalloween,
        hariIbu => l.festiveHariIbu,
      };
  }

  String get greeting {
    final l = l10n;
    return switch (this) {
        none => '',
        idulFitri => l.festiveIdulFitriGreeting,
        idulAdha => l.festiveIdulAdhaGreeting,
        imlek => l.festiveImlekGreeting,
        paskah => l.festivePaskahGreeting,
        natal => l.festiveNatalGreeting,
        tahunBaru => l.festiveTahunBaruGreeting,
        valentine => l.festiveValentineGreeting,
        ramadan => l.festiveRamadanGreeting,
        nyepi => l.festiveNyepiGreeting,
        waisak => l.festiveWaisakGreeting,
        kartini => l.festiveKartiniGreeting,
        kemerdekaan => l.festiveKemerdekaanGreeting,
        halloween => l.festiveHalloweenGreeting,
        hariIbu => l.festiveHariIbuGreeting,
      };
  }

  String get subtitle {
    final l = l10n;
    return switch (this) {
        none => '',
        idulFitri => l.festiveIdulFitriSubtitle,
        idulAdha => l.festiveIdulAdhaSubtitle,
        imlek => l.festiveImlekSubtitle,
        paskah => l.festivePaskahSubtitle,
        natal => l.festiveNatalSubtitle,
        tahunBaru => l.festiveTahunBaruSubtitle,
        valentine => l.festiveValentineSubtitle,
        ramadan => l.festiveRamadanSubtitle,
        nyepi => l.festiveNyepiSubtitle,
        waisak => l.festiveWaisakSubtitle,
        kartini => l.festiveKartiniSubtitle,
        kemerdekaan => l.festiveKemerdekaanSubtitle,
        halloween => l.festiveHalloweenSubtitle,
        hariIbu => l.festiveHariIbuSubtitle,
      };
  }

  bool get isActive => this != FestiveTheme.none;

  /// Illustrated background for the balance card (`assets/banners/<name>.webp`).
  String? get bannerAsset => isActive ? 'assets/banners/$name.webp' : null;

  /// Which part of the wide banner to keep when cropped to the card. Banners
  /// with lettering are shifted so the text stays away from the figures.
  Alignment get bannerAlignment => switch (this) {
        hariIbu || nyepi || waisak => Alignment.centerLeft,
        tahunBaru => Alignment.centerRight,
        _ => Alignment.center,
      };

  /// Extra darkening for busy banners so white figures stay readable.
  double get bannerDim => switch (this) {
        hariIbu || nyepi || waisak => 0.22,
        tahunBaru => 0.12,
        _ => 0,
      };

  static FestiveTheme fromName(String? name) =>
      FestiveTheme.values.firstWhere((t) => t.name == name, orElse: () => FestiveTheme.none);
}
