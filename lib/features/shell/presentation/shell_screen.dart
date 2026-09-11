import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../account/application/session_controller.dart';
import '../../account/domain/account_profile.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(sessionProvider).value;
    final premium = profile?.hasPremiumAccess ?? false;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.shellGutter,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appTitle,
                          style: textTheme.headlineMedium?.copyWith(
                            color: AppColors.paper,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.appTagline,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LanguageSwitcher(),
                  const SizedBox(width: AppSpacing.sm),
                  _AccountChip(
                    email: profile?.email ?? '',
                    plan: premium
                        ? (profile?.accessSource == AccessSource.contest
                              ? l10n.planContest
                              : l10n.planPremium)
                        : l10n.planFree,
                    onTap: () => context.go('/account'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: AppPanel(
                        kicker: l10n.comingNext,
                        title: l10n.arcadeTitle,
                        body: l10n.arcadeBody,
                        badge: l10n.planFree,
                        onTap: () => _soon(context, l10n),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPanel(
                        kicker: premium ? l10n.planPremium : l10n.coachLocked,
                        title: l10n.coachTitle,
                        body: l10n.coachBody,
                        badge: premium ? l10n.planPremium : l10n.planFree,
                        onTap: () {
                          if (premium) {
                            _soon(context, l10n);
                          } else {
                            context.go('/paywall');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppPanel(
                        kicker: l10n.comingNext,
                        title: l10n.mapTitle,
                        body: l10n.mapBody,
                        onTap: () => _soon(context, l10n),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _soon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingNext)));
  }
}

class _AccountChip extends StatelessWidget {
  const _AccountChip({
    required this.email,
    required this.plan,
    required this.onTap,
  });

  final String email;
  final String plan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 18, color: AppColors.paper),
              const SizedBox(width: AppSpacing.xs),
              Text(
                plan,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.brass,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
