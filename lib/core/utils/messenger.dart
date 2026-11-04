import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

final rootMessengerKey = GlobalKey<ScaffoldMessengerState>();

enum SnackKind { success, warning, error, info }

void showAppSnack(String message, {SnackKind kind = SnackKind.success}) {
  final messenger = rootMessengerKey.currentState;
  if (messenger == null) return;
  final (icon, color) = switch (kind) {
    SnackKind.success => (Icons.check_circle_rounded, AppColors.income),
    SnackKind.warning => (Icons.warning_amber_rounded, AppColors.warning),
    SnackKind.error => (Icons.error_rounded, AppColors.expense),
    SnackKind.info => (Icons.info_rounded, AppColors.primary),
  };
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: Duration(seconds: kind == SnackKind.warning ? 5 : 3),
      content: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    ));
}

/// Turns any thrown object into a short user-facing message.
String errorMessage(Object error) {
  final text = error.toString();
  if (text.contains('SqliteException') || text.contains('DriftRemoteException')) {
    return 'Gagal menyimpan ke database. Coba lagi.';
  }
  return text.replaceFirst('Exception: ', '');
}
