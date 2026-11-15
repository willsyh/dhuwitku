import 'dart:io';

import 'package:dhuwitku/app/theme/festive_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every festive theme has a banner asset, and "none" has none', () {
    expect(FestiveTheme.none.bannerAsset, isNull);
    for (final t in FestiveTheme.values.where((t) => t.isActive)) {
      final path = t.bannerAsset!;
      expect(File(path).existsSync(), isTrue, reason: 'missing $path for ${t.label}');
    }
  });

  test('banner files are small enough for the APK (< 250 KB each)', () {
    for (final f in Directory('assets/banners').listSync().whereType<File>()) {
      expect(f.lengthSync(), lessThan(250 * 1024), reason: f.path);
    }
  });
}
