import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../locale/app_locale.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return Semantics(
      label: l10n.language,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageChip(
            label: l10n.languageEnglish,
            selected: locale.languageCode == 'en',
            onTap: () =>
                ref.read(localeProvider.notifier).setLocale(const Locale('en')),
          ),
          const SizedBox(width: AppSpacing.xs),
          _LanguageChip(
            label: l10n.languageSimplifiedChinese,
            selected: locale.languageCode == 'zh' && locale.countryCode != 'TW',
            onTap: () =>
                ref.read(localeProvider.notifier).setLocale(const Locale('zh')),
          ),
          const SizedBox(width: AppSpacing.xs),
          _LanguageChip(
            label: l10n.languageTraditionalChinese,
            selected: locale.languageCode == 'zh' && locale.countryCode == 'TW',
            onTap: () => ref
                .read(localeProvider.notifier)
                .setLocale(
                  const Locale.fromSubtags(
                    languageCode: 'zh',
                    countryCode: 'TW',
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brass : AppColors.panel,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.brass : AppColors.panelEdge,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? AppColors.ink : AppColors.paper,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
