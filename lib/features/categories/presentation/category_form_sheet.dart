import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/category_style.dart';
import '../../../core/constants/transaction_type.dart';
import '../../../core/utils/messenger.dart';
import '../../../core/widgets/common_widgets.dart';
import '../domain/category.dart';
import 'category_providers.dart';

/// Create (or edit, with [initial]) a category. Returns its id when saved.
Future<int?> showCategoryFormSheet(
  BuildContext context, {
  required TransactionType type,
  Category? initial,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _CategoryForm(type: initial?.type ?? type, initial: initial),
  );
}

class _CategoryForm extends ConsumerStatefulWidget {
  const _CategoryForm({required this.type, this.initial});
  final TransactionType type;
  final Category? initial;

  @override
  ConsumerState<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<_CategoryForm> {
  late final _name = TextEditingController(text: widget.initial?.name ?? '');
  late String _icon = widget.initial?.iconKey ?? 'other';
  late int _color = widget.initial?.colorValue ?? categoryColors.first;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final repo = ref.read(categoryRepositoryProvider);
    try {
      final int id;
      if (widget.initial == null) {
        id = await repo.create(
          name: _name.text,
          iconKey: _icon,
          colorValue: _color,
          type: widget.type,
        );
      } else {
        id = widget.initial!.id;
        await repo.update(Category(
          id: id,
          name: _name.text,
          iconKey: _icon,
          colorValue: _color,
          type: widget.type,
          isDefault: widget.initial!.isDefault,
        ));
      }
      if (!mounted) return;
      Navigator.of(context).pop(id);
      showAppSnack(widget.initial == null ? 'Kategori ditambahkan.' : 'Kategori diperbarui.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = errorMessage(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.initial == null ? 'Kategori Baru' : 'Ubah Kategori'} · ${widget.type.label}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CategoryAvatar(icon: iconForKey(_icon), color: Color(_color), size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _name,
                    autofocus: widget.initial == null,
                    maxLength: AppLimits.maxCategoryNameLength,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Nama kategori',
                      counterText: '',
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Warna', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in categoryColors)
                  Semantics(
                    selected: c == _color,
                    button: true,
                    label: 'Warna',
                    child: GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c == _color ? theme.colorScheme.onSurface : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: c == _color
                            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Ikon', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in categoryIcons.entries)
                  InkWell(
                    onTap: () => setState(() => _icon = e.key),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: e.key == _icon
                            ? Color(_color).withValues(alpha: 0.16)
                            : theme.colorScheme.surfaceContainerLow,
                        border: Border.all(
                          color: e.key == _icon ? Color(_color) : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        e.value,
                        color: e.key == _icon ? Color(_color) : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Simpan Kategori'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
