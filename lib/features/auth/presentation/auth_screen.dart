import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../account/application/session_controller.dart';
import '../../account/domain/account_profile.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _creating = false;
  var _busy = false;
  String? _errorCode;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    final session = ref.read(sessionProvider.notifier);
    try {
      if (_creating) {
        await session.signUp(email: _email.text, password: _password.text);
      } else {
        await session.signIn(email: _email.text, password: _password.text);
      }
    } on AccountException catch (error) {
      if (mounted) {
        setState(() => _errorCode = error.code);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorCode = 'genericError');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _errorText(AppLocalizations l10n) {
    return switch (_errorCode) {
      'invalidCredentials' => l10n.invalidCredentials,
      'emailTaken' => l10n.emailTaken,
      'weakPassword' => l10n.weakPassword,
      'invalidEmail' => l10n.invalidEmail,
      'confirmEmail' => l10n.confirmEmail,
      _ => l10n.genericError,
    };
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LanguageSwitcher(),
                    const Spacer(),
                    Text(
                      l10n.appTitle,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.paper,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.authSubtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.muted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.sensitiveWarning,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.brass,
                        height: 1.35,
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
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppTextField(
                        controller: _email,
                        label: l10n.email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _password,
                        label: l10n.password,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: _creating
                            ? const [AutofillHints.newPassword]
                            : const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                      ),
                      if (_errorCode != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _errorText(l10n),
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: _creating ? l10n.createAccount : l10n.signIn,
                        busy: _busy,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                _creating = !_creating;
                                _errorCode = null;
                              }),
                        child: Text(
                          _creating ? l10n.haveAccount : l10n.needAccount,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.brass,
                          ),
                        ),
                      ),
                    ],
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
