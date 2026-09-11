import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/session_controller.dart';
import '../domain/account_profile.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  var _busy = false;
  var _confirmDelete = false;
  var _exported = false;

  String _planLabel(AppLocalizations l10n, AccountProfile profile) {
    if (!profile.hasPremiumAccess) return l10n.planFree;
    if (profile.accessSource == AccessSource.contest) {
      return l10n.planContest;
    }
    return l10n.planPremium;
  }

  String _accessDetail(AppLocalizations l10n, AccountProfile profile) {
    final until = profile.premiumUntil;
    if (!profile.hasPremiumAccess) return l10n.planFree;
    if (until == null) return l10n.premiumUntilForever;
    return l10n.planExpires(
      DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(
        until.toLocal(),
      ),
    );
  }

  Future<void> _export() async {
    final data = await ref.read(sessionProvider.notifier).exportAccount();
    await Clipboard.setData(
      ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)),
    );
    if (!mounted) return;
    setState(() => _exported = true);
  }

  Future<void> _delete() async {
    setState(() => _busy = true);
    try {
      await ref.read(sessionProvider.notifier).deleteAccount();
      if (mounted) context.go('/auth');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(sessionProvider).value;

    if (profile == null) {
      return const Scaffold(body: SizedBox.shrink());
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.shellGutter,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back, color: AppColors.paper),
                    tooltip: l10n.cancel,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.account,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.paper,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const LanguageSwitcher(),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.panel,
                          border: Border.all(color: AppColors.panelEdge),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.accountEmail(profile.email),
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppColors.paper,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                _planLabel(l10n, profile),
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.brass,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _accessDetail(l10n, profile),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                AppConfig.useSupabase
                                    ? l10n.cloudAccountNote
                                    : l10n.localAccountNote,
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        children: [
                          AppButton(
                            label: l10n.exportAccount,
                            primary: false,
                            onPressed: _export,
                          ),
                          if (_exported) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.exported,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.brass,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          if (!profile.hasPremiumAccess) ...[
                            AppButton(
                              label: l10n.subscribe,
                              onPressed: () => context.go('/paywall'),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          AppButton(
                            label: l10n.signOut,
                            primary: false,
                            onPressed: () async {
                              await ref.read(sessionProvider.notifier).signOut();
                              if (context.mounted) context.go('/auth');
                            },
                          ),
                          const Spacer(),
                          if (_confirmDelete) ...[
                            Text(
                              l10n.deleteAccountConfirm,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: AppButton(
                                    label: l10n.cancel,
                                    primary: false,
                                    onPressed: () =>
                                        setState(() => _confirmDelete = false),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: AppButton(
                                    label: l10n.deleteAccountAction,
                                    destructive: true,
                                    busy: _busy,
                                    onPressed: _delete,
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            AppButton(
                              label: l10n.deleteAccount,
                              destructive: true,
                              onPressed: () =>
                                  setState(() => _confirmDelete = true),
                            ),
                        ],
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
}
