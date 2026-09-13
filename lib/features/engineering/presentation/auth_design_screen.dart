import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'first_launch_hero_panel.dart';

class AuthDesignScreen extends StatefulWidget {
  const AuthDesignScreen({super.key});

  @override
  State<AuthDesignScreen> createState() => _AuthDesignScreenState();
}

enum _AuthMethodDesignScreen { email, visitor, google, apple }

class _AuthDesignScreenState extends State<AuthDesignScreen> {
  final TextEditingController emailControllerDesignScreen =
      TextEditingController();
  final TextEditingController passwordControllerDesignScreen =
      TextEditingController();
  final TextEditingController confirmPasswordControllerDesignScreen =
      TextEditingController();

  _AuthMethodDesignScreen? selectedMethodDesignScreen;
  bool hidePasswordDesignScreen = true;
  String? emailErrorDesignScreen;
  String? passwordErrorDesignScreen;
  String? confirmPasswordErrorDesignScreen;
  String? statusDesignScreen;

  @override
  void dispose() {
    emailControllerDesignScreen.dispose();
    passwordControllerDesignScreen.dispose();
    confirmPasswordControllerDesignScreen.dispose();
    super.dispose();
  }

  void chooseMethodDesignScreen(_AuthMethodDesignScreen method) {
    setState(() {
      selectedMethodDesignScreen = method;
      emailErrorDesignScreen = null;
      passwordErrorDesignScreen = null;
      confirmPasswordErrorDesignScreen = null;
      statusDesignScreen = null;
    });
  }

  void showMethodChooserDesignScreen() {
    setState(() {
      selectedMethodDesignScreen = null;
      statusDesignScreen = null;
    });
  }

  void submitEmailDesignScreen() {
    final email = emailControllerDesignScreen.text.trim();
    final password = passwordControllerDesignScreen.text;
    final confirmedPassword = confirmPasswordControllerDesignScreen.text;
    setState(() {
      emailErrorDesignScreen =
          RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
          ? null
          : 'Enter a valid email address';
      passwordErrorDesignScreen = password.length >= 8
          ? null
          : 'Use at least 8 characters';
      confirmPasswordErrorDesignScreen = confirmedPassword == password
          ? null
          : 'Passwords do not match';
      statusDesignScreen =
          emailErrorDesignScreen == null &&
              passwordErrorDesignScreen == null &&
              confirmPasswordErrorDesignScreen == null
          ? 'Email details are ready to continue'
          : null;
    });
  }

  void continueMethodDesignScreen(_AuthMethodDesignScreen method) {
    setState(() {
      statusDesignScreen = switch (method) {
        _AuthMethodDesignScreen.visitor => 'Visitor access selected',
        _AuthMethodDesignScreen.google => 'Google access selected',
        _AuthMethodDesignScreen.apple => 'Apple access selected',
        _AuthMethodDesignScreen.email => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: FirstLaunchHeroPanel(
                  onBack: () => context.go('/engineering'),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Icon(
                        Icons.security_rounded,
                        color: Color(0xFF3299D0),
                        size: 55,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Keep your\nworkspace available',
                        style: TextStyle(
                          color: Color(0xFF174765),
                          fontSize: 24,
                          height: 1.06,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Connect your records to an email, Google, or Apple account so you can restore them on another device.',
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF56819A),
                          fontSize: 9,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Text(
                        'Choose how to save your records',
                        style: TextStyle(
                          color: Color(0xFF173F5D),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: switch (selectedMethodDesignScreen) {
                          _AuthMethodDesignScreen.email => _EmailAccessForm(
                            key: const ValueKey('email-access-form'),
                            emailController: emailControllerDesignScreen,
                            passwordController: passwordControllerDesignScreen,
                            confirmPasswordController:
                                confirmPasswordControllerDesignScreen,
                            hidePassword: hidePasswordDesignScreen,
                            emailError: emailErrorDesignScreen,
                            passwordError: passwordErrorDesignScreen,
                            confirmPasswordError:
                                confirmPasswordErrorDesignScreen,
                            onTogglePassword: () => setState(
                              () => hidePasswordDesignScreen =
                                  !hidePasswordDesignScreen,
                            ),
                            onBack: showMethodChooserDesignScreen,
                            onContinue: submitEmailDesignScreen,
                          ),
                          _AuthMethodDesignScreen.visitor => _AuthMethodView(
                            key: const ValueKey('visitor-access-view'),
                            icon: Icons.person_rounded,
                            title: 'Continue as a visitor',
                            description:
                                'You can begin as a visitor now. Later, you can link your records and progress to an email, Google, or Apple account so they can be restored on another device.',
                            onBack: showMethodChooserDesignScreen,
                            onContinue: () => continueMethodDesignScreen(
                              _AuthMethodDesignScreen.visitor,
                            ),
                          ),
                          _AuthMethodDesignScreen.google => _AuthMethodView(
                            key: const ValueKey('google-access-view'),
                            iconAsset: 'images/google.png',
                            title: 'Save with Google',
                            description:
                                'Use your Google account to keep your records and progress available when you move to another supported device.',
                            onBack: showMethodChooserDesignScreen,
                            onContinue: () => continueMethodDesignScreen(
                              _AuthMethodDesignScreen.google,
                            ),
                          ),
                          _AuthMethodDesignScreen.apple => _AuthMethodView(
                            key: const ValueKey('apple-access-view'),
                            iconAsset: 'images/apple.png',
                            tintAsset: true,
                            title: 'Save with Apple',
                            description:
                                'Use your Apple account to keep your records and progress available when you move to another supported device.',
                            onBack: showMethodChooserDesignScreen,
                            onContinue: () => continueMethodDesignScreen(
                              _AuthMethodDesignScreen.apple,
                            ),
                          ),
                          null => _AuthMethodChooser(
                            key: const ValueKey('auth-method-chooser'),
                            onSelected: chooseMethodDesignScreen,
                          ),
                        },
                      ),
                    ),
                    if (statusDesignScreen != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 7, left: 18),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Color(0xFF358FC4),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                statusDesignScreen!,
                                style: const TextStyle(
                                  color: Color(0xFF337FA8),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
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

class _AuthMethodChooser extends StatelessWidget {
  const _AuthMethodChooser({super.key, required this.onSelected});

  final ValueChanged<_AuthMethodDesignScreen> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 4, 4),
      children: [
        AppButton(
          label: 'Email',
          leading: const Icon(Icons.mail_outline_rounded),
          onPressed: () => onSelected(_AuthMethodDesignScreen.email),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Google',
          leading: Image.asset(
            'images/google.png',
            width: 17,
            height: 17,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          onPressed: () => onSelected(_AuthMethodDesignScreen.google),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Apple',
          leading: Image.asset(
            'images/apple.png',
            width: 17,
            height: 17,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            color: const Color(0xFF276F9E),
            colorBlendMode: BlendMode.srcIn,
          ),
          onPressed: () => onSelected(_AuthMethodDesignScreen.apple),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Visitor',
          leading: const Icon(Icons.person_rounded),
          onPressed: () => onSelected(_AuthMethodDesignScreen.visitor),
        ),
      ],
    );
  }
}

class _EmailAccessForm extends StatelessWidget {
  const _EmailAccessForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.hidePassword,
    required this.emailError,
    required this.passwordError,
    required this.confirmPasswordError,
    required this.onTogglePassword,
    required this.onBack,
    required this.onContinue,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool hidePassword;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final VoidCallback onTogglePassword;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 0, 4),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                TextField(
                  key: const ValueKey('auth-email-field'),
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  onTap: requestAppKeyboard,
                  decoration: appInputDecoration(
                    label: 'Email address',
                    hint: 'name@example.com',
                    error: emailError,
                  ),
                ),
                const SizedBox(height: 9),
                TextField(
                  key: const ValueKey('auth-password-field'),
                  controller: passwordController,
                  obscureText: hidePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  onTap: requestAppKeyboard,
                  decoration: appInputDecoration(
                    label: 'Password',
                    hint: 'At least 8 characters',
                    error: passwordError,
                    suffix: IconButton(
                      onPressed: onTogglePassword,
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                      ),
                      color: const Color(0xFF4D819C),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                TextField(
                  key: const ValueKey('auth-confirm-password-field'),
                  controller: confirmPasswordController,
                  obscureText: hidePassword,
                  autofillHints: const [AutofillHints.newPassword],
                  onTap: requestAppKeyboard,
                  decoration: appInputDecoration(
                    label: 'Confirm password',
                    hint: 'Enter the same password again',
                    error: confirmPasswordError,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FirstLaunchBottomAction(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 160,
                    child: AppButton(label: 'Other Methods', onPressed: onBack),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 175,
                    child: AppButton(
                      label: 'Continue with Email',
                      onPressed: onContinue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthMethodView extends StatelessWidget {
  const _AuthMethodView({
    super.key,
    this.icon,
    this.iconAsset,
    this.tintAsset = false,
    required this.title,
    required this.description,
    required this.onBack,
    required this.onContinue,
  });

  final IconData? icon;
  final String? iconAsset;
  final bool tintAsset;
  final String title;
  final String description;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final image = iconAsset == null
        ? Icon(icon, color: const Color(0xFF3299D0), size: 38)
        : Image.asset(
            iconAsset!,
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            color: tintAsset ? const Color(0xFF276F9E) : null,
            colorBlendMode: tintAsset ? BlendMode.srcIn : null,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 0, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          image,
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF245672),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Text(
              description,
              style: const TextStyle(
                color: Color(0xFF5A7F94),
                fontSize: 11,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: FirstLaunchBottomAction(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 160,
                    child: AppButton(label: 'Other Methods', onPressed: onBack),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 135,
                    child: AppButton(label: 'Continue', onPressed: onContinue),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
