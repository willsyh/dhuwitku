import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../l10n/l10n.dart';

/// "Tentang Dhuwitku": what the app is, what it does, and how data is handled.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static List<(IconData, String, String)> _features(AppLocalizations l) => [
        (Icons.bolt_rounded, l.aboutFeatureFastTitle, l.aboutFeatureFastBody),
        (Icons.dashboard_rounded, l.aboutFeatureOverviewTitle, l.aboutFeatureOverviewBody),
        (Icons.flag_rounded, l.aboutFeatureBudgetTitle, l.aboutFeatureBudgetBody),
        (Icons.insights_rounded, l.aboutFeatureStatsTitle, l.aboutFeatureStatsBody),
        (Icons.backup_rounded, l.aboutFeatureBackupTitle, l.aboutFeatureBackupBody),
      ];

  static List<(IconData, String)> _privacy(AppLocalizations l) => [
        (Icons.cloud_off_rounded, l.aboutPrivacyOffline),
        (Icons.no_accounts_rounded, l.aboutPrivacyNoAccount),
        (Icons.phone_android_rounded, l.aboutPrivacyLocal),
        (Icons.block_rounded, l.aboutPrivacyNoAds),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
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
                Text(l.versionLabel(AppInfo.version), style: muted),
                const SizedBox(height: 10),
                Text(
                  l.appTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(color: scheme.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Text(
              l.aboutDescription(AppInfo.name),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: l.aboutFeatures),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              children: [
                for (final (i, f) in _features(l).indexed) ...[
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
          SectionHeader(title: l.aboutPrivacy),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final p in _privacy(l))
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
              l.aboutBackupTip,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(l.aboutFooter,
                style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
