import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'first_launch_hero_panel.dart';

class LanguageSetupDesignScreen extends StatefulWidget {
  const LanguageSetupDesignScreen({super.key});

  @override
  State<LanguageSetupDesignScreen> createState() =>
      _LanguageSetupDesignScreenState();
}

class _LanguageSetupDesignScreenState extends State<LanguageSetupDesignScreen> {
  int selectedLanguageDesignScreen = 0;

  @override
  Widget build(BuildContext context) {
    final selected = languagesDesignScreen[selectedLanguageDesignScreen];

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _LanguageWelcome(
                  selected: selected,
                  onBack: () => context.go('/engineering'),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: SizedBox(
                        height: 27,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 1125),
                            reverseDuration: const Duration(milliseconds: 1125),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            layoutBuilder: (currentChild, previousChildren) =>
                                Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
                                ),
                            child: Text(
                              selected.title,
                              key: ValueKey(selected.title),
                              style: const TextStyle(
                                color: Color(0xFF173F5D),
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: FirstLaunchBottomAction(
                        child: GridView.builder(
                          key: const ValueKey('language-grid'),
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.fromLTRB(2, 6, 0, 12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 49,
                              ),
                          itemCount: languagesDesignScreen.length,
                          itemBuilder: (context, index) {
                            final language = languagesDesignScreen[index];
                            final isSelected =
                                index == selectedLanguageDesignScreen;
                            return AppButton(
                              label:
                                  '${isSelected ? '✓  ' : ''}${language.nativeName}',
                              selected: isSelected,
                              onPressed: () => setState(
                                () => selectedLanguageDesignScreen = index,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FirstLaunchBottomAction(
                        child: SizedBox(
                          width: 135,
                          child: AppButton(
                            label: selected.continueLabel,
                            onPressed: () {},
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

class _LanguageWelcome extends StatelessWidget {
  const _LanguageWelcome({required this.selected, required this.onBack});

  final _LanguageFixture selected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return FirstLaunchHeroPanel(
      onBack: onBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(
            Icons.translate_rounded,
            color: Color(0xFF3299D0),
            size: 55,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1125),
            reverseDuration: const Duration(milliseconds: 1125),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previousChildren, ?currentChild],
            ),
            child: Text(
              selected.hero,
              key: ValueKey(selected.hero),
              style: const TextStyle(
                color: Color(0xFF174765),
                fontSize: 24,
                height: 1.06,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1125),
            reverseDuration: const Duration(milliseconds: 1125),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previousChildren, ?currentChild],
            ),
            child: Text(
              selected.previewLabel,
              key: ValueKey(selected.previewLabel),
              style: const TextStyle(
                color: Color(0xFF56819A),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1125),
            reverseDuration: const Duration(milliseconds: 1125),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            layoutBuilder: (currentChild, previousChildren) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previousChildren, ?currentChild],
            ),
            child: Container(
              key: ValueKey(selected.nativeName),
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFBBDFF1)),
              ),
              child: Text(
                selected.preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF315F79),
                  fontSize: 10,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageFixture {
  const _LanguageFixture({
    required this.nativeName,
    required this.preview,
    required this.title,
    required this.hero,
    required this.previewLabel,
    required this.selectedLabel,
    required this.continueLabel,
  });

  final String nativeName;
  final String preview;
  final String title;
  final String hero;
  final String previewLabel;
  final String selectedLabel;
  final String continueLabel;
}

const languagesDesignScreen = <_LanguageFixture>[
  _LanguageFixture(
    nativeName: 'English',
    preview: 'Stay calm. Keep the reply factual.',
    title: 'Choose your language',
    hero: 'Your office\nYour language',
    previewLabel: 'Coaching preview',
    selectedLabel: 'Selected',
    continueLabel: 'Continue',
  ),
  _LanguageFixture(
    nativeName: '简体中文',
    preview: '保持冷静，让回复以事实为依据。',
    title: '选择语言',
    hero: '你的办公室\n你的语言',
    previewLabel: '建议预览',
    selectedLabel: '已选择',
    continueLabel: '继续',
  ),
  _LanguageFixture(
    nativeName: '繁體中文',
    preview: '保持冷靜，讓回覆以事實為依據。',
    title: '選擇語言',
    hero: '你的辦公室\n你的語言',
    previewLabel: '建議預覽',
    selectedLabel: '已選擇',
    continueLabel: '繼續',
  ),
  _LanguageFixture(
    nativeName: 'Español',
    preview: 'Mantén la calma y responde con hechos.',
    title: 'Elige tu idioma',
    hero: 'Tu oficina\nTu idioma',
    previewLabel: 'Vista previa del consejo',
    selectedLabel: 'Seleccionado',
    continueLabel: 'Continuar',
  ),
  _LanguageFixture(
    nativeName: 'Français',
    preview: 'Restez calme et répondez avec des faits.',
    title: 'Choisissez votre langue',
    hero: 'Votre bureau\nVotre langue',
    previewLabel: 'Aperçu du conseil',
    selectedLabel: 'Sélectionné',
    continueLabel: 'Continuer',
  ),
  _LanguageFixture(
    nativeName: 'Deutsch',
    preview: 'Bleiben Sie ruhig und sachlich.',
    title: 'Sprache auswählen',
    hero: 'Ihr Büro\nIhre Sprache',
    previewLabel: 'Vorschau der Beratung',
    selectedLabel: 'Ausgewählt',
    continueLabel: 'Weiter',
  ),
  _LanguageFixture(
    nativeName: '日本語',
    preview: '冷静に、事実に基づいて返信しましょう。',
    title: '言語を選択',
    hero: 'あなたの職場\nあなたの言語',
    previewLabel: 'アドバイスのプレビュー',
    selectedLabel: '選択済み',
    continueLabel: '続ける',
  ),
  _LanguageFixture(
    nativeName: '한국어',
    preview: '침착하게 사실을 바탕으로 답장하세요.',
    title: '언어 선택',
    hero: '당신의 사무실\n당신의 언어',
    previewLabel: '조언 미리보기',
    selectedLabel: '선택됨',
    continueLabel: '계속',
  ),
  _LanguageFixture(
    nativeName: 'Português',
    preview: 'Mantenha a calma e responda com fatos.',
    title: 'Escolha seu idioma',
    hero: 'Seu escritório\nSeu idioma',
    previewLabel: 'Prévia do conselho',
    selectedLabel: 'Selecionado',
    continueLabel: 'Continuar',
  ),
  _LanguageFixture(
    nativeName: 'Bahasa Melayu',
    preview: 'Kekal tenang dan jawab berdasarkan fakta.',
    title: 'Pilih bahasa anda',
    hero: 'Pejabat anda\nBahasa anda',
    previewLabel: 'Pratonton nasihat',
    selectedLabel: 'Dipilih',
    continueLabel: 'Teruskan',
  ),
  _LanguageFixture(
    nativeName: 'हिन्दी',
    preview: 'शांत रहें और तथ्यों के आधार पर उत्तर दें।',
    title: 'अपनी भाषा चुनें',
    hero: 'आपका कार्यालय\nआपकी भाषा',
    previewLabel: 'सलाह पूर्वावलोकन',
    selectedLabel: 'चयनित',
    continueLabel: 'जारी रखें',
  ),
  _LanguageFixture(
    nativeName: 'العربية',
    preview: 'حافظ على هدوئك واجعل ردك مبنياً على الحقائق.',
    title: 'اختر لغتك',
    hero: 'مكتبك\nلغتك',
    previewLabel: 'معاينة النصيحة',
    selectedLabel: 'تم الاختيار',
    continueLabel: 'متابعة',
  ),
];
