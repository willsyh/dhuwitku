import 'package:flutter/material.dart';

/// Brand palette. Income/expense/warning colors are the same in both themes
/// so a number always means the same thing at a glance.
abstract final class AppColors {
  static const primary = Color(0xFF3B82F6);
  static const secondary = Color(0xFF64748B);

  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightText = Color(0xFF0F172A);

  static const darkBackground = Color(0xFF0B0F19);
  static const darkSurface = Color(0xFF151B2B);
  static const darkBorder = Color(0xFF232B3E);
  static const darkText = Color(0xFFF1F5F9);

  static const income = Color(0xFF22C55E);
  static const expense = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
}
