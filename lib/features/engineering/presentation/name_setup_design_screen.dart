import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'first_launch_hero_panel.dart';

class NameSetupDesignScreen extends StatefulWidget {
  const NameSetupDesignScreen({super.key});

  @override
  State<NameSetupDesignScreen> createState() => _NameSetupDesignScreenState();
}

class _NameSetupDesignScreenState extends State<NameSetupDesignScreen> {
  final TextEditingController nameControllerDesignScreen =
      TextEditingController();
  String? errorDesignScreen;

  @override
  void dispose() {
    nameControllerDesignScreen.dispose();
    super.dispose();
  }

  void continueDesignScreen() {
    if (nameControllerDesignScreen.text.trim().isEmpty) {
      setState(() => errorDesignScreen = 'Enter a display name to continue.');
      return;
    }
    setState(() => errorDesignScreen = null);
  }

  @override
  Widget build(BuildContext context) {
    final name = nameControllerDesignScreen.text.trim();

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF3299D0),
                        size: 55,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        name.isEmpty ? 'Your name' : name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF174765),
                          fontSize: 24,
                          height: 1.06,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This name appears on your character. You can write it in any language.',
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
                        'What should we call you?',
                        style: TextStyle(
                          color: Color(0xFF173F5D),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: SizedBox(
                        width: 320,
                        child: TextField(
                          key: const ValueKey('name-setup-field'),
                          controller: nameControllerDesignScreen,
                          maxLength: 15,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(15),
                          ],
                          onTap: requestAppKeyboard,
                          onChanged: (_) {
                            setState(() => errorDesignScreen = null);
                          },
                          style: const TextStyle(
                            color: Color(0xFF255873),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: appInputDecoration(
                            label: 'Display Name',
                            hint: 'Enter up to 15 characters',
                            error: errorDesignScreen,
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FirstLaunchBottomAction(
                        child: SizedBox(
                          width: 135,
                          child: AppButton(
                            label: 'Continue',
                            onPressed: name.isEmpty
                                ? null
                                : continueDesignScreen,
                          ),
                        ),
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
