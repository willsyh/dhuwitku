import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/messenger.dart';
import '../../../l10n/l10n.dart';
import '../../categories/presentation/category_providers.dart';
import '../../transactions/presentation/quick_add_sheet.dart';
import '../data/receipt_scanner.dart';
import '../domain/receipt_parser.dart';

/// Scan a receipt: pick a photo, read it on-device, then open the quick-add
/// sheet pre-filled with the total, date, store and a category guess.
/// Nothing is saved until the user confirms with Simpan.
Future<void> startReceiptScan(BuildContext context, WidgetRef ref) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => const _SourceSheet(),
  );
  if (source == null || !context.mounted) return;

  final XFile? photo;
  try {
    photo = await ImagePicker().pickImage(source: source, maxWidth: 2200, imageQuality: 92);
  } catch (_) {
    showAppSnack(
      source == ImageSource.camera ? l10n.errCamera : l10n.errGallery,
      kind: SnackKind.error,
    );
    return;
  }
  if (photo == null || !context.mounted) return;

  // Blocking progress while ML Kit reads the image (usually ~1 second).
  final navigator = Navigator.of(context, rootNavigator: true);
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(canPop: false, child: _ReadingDialog()),
  );

  List<String> rows;
  try {
    rows = await ref.read(receiptScannerProvider).readRows(photo.path);
  } catch (_) {
    navigator.pop();
    showAppSnack(l10n.errReadReceipt, kind: SnackKind.error);
    return;
  }
  navigator.pop();
  if (!context.mounted) return;

  final data = ReceiptParser.parse(rows);
  if (data.isEmpty) {
    showAppSnack(
      l10n.receiptNoText,
      kind: SnackKind.warning,
    );
    return;
  }

  final categories = ref.read(categoriesByTypeProvider(TransactionType.expense));
  final categoryId = categories.where((c) => c.name == data.categoryName).firstOrNull?.id;

  final notice = data.total == null
      ? l10n.receiptNoTotal
      : data.totalFromKeyword
          ? l10n.receiptCheck
          : l10n.receiptGuessedTotal;

  await showQuickAddSheet(
    context,
    type: TransactionType.expense,
    prefill: TransactionPrefill(
      amount: data.total,
      categoryId: categoryId,
      date: data.date,
      description: data.merchant,
      paymentMethod: data.paymentMethod,
      notice: notice,
    ),
  );
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(context.l10n.scanReceiptTitle, style: theme.textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                context.l10n.receiptTips,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(context.l10n.takePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.pickFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 14, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.l10n.receiptPrivacy,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingDialog extends StatelessWidget {
  const _ReadingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
          const SizedBox(width: 16),
          Expanded(child: Text(context.l10n.readingReceipt)),
        ],
      ),
    );
  }
}
