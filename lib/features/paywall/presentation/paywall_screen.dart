import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../account/application/session_controller.dart';
import '../../account/domain/account_profile.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  var _busy = false;
  String? _errorCode;

  Future<void> _subscribe() async {
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      await ref.read(sessionProvider.notifier).subscribeMonthly();
      if (mounted) context.go('/');
    } on AccountException catch (error) {
      if (mounted) setState(() => _errorCode = error.code);
    } catch (_) {
      if (mounted) setState(() => _errorCode = 'genericError');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

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
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back, color: AppColors.paper),
                    tooltip: l10n.cancel,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.paywallTitle,
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
                      child: Text(
                        l10n.paywallBody,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_errorCode != null) ...[
                            Text(
                              l10n.genericError,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          AppButton(
                            label: l10n.subscribe,
                            busy: _busy,
                            onPressed: _subscribe,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.subscribeHint,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            label: l10n.contestCta,
                            primary: false,
                            onPressed: () => context.go('/'),
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
