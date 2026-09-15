import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/workspace_suggestion_service.dart';
import 'first_launch_hero_panel.dart';

enum AdviceVoiceLanguageDesignScreen {
  english('English'),
  simplifiedChinese('简体中文'),
  traditionalChinese('繁體中文');

  const AdviceVoiceLanguageDesignScreen(this.label);
  final String label;
}

class AdviceInputDesignScreen extends StatefulWidget {
  const AdviceInputDesignScreen({
    super.key,
    this.suggestionService = const WorkspaceSuggestionService(),
  });

  final WorkspaceSuggestionService suggestionService;

  @override
  State<AdviceInputDesignScreen> createState() =>
      _AdviceInputDesignScreenState();
}

class _AdviceInputDesignScreenState extends State<AdviceInputDesignScreen> {
  final notesController = TextEditingController();
  final analysisControllers = List.generate(5, (_) => TextEditingController());
  final speech = SpeechToText();
  final imagePicker = ImagePicker();

  AdviceVoiceLanguageDesignScreen voiceLanguage =
      AdviceVoiceLanguageDesignScreen.english;
  String dictationPrefix = '';
  String? selectedImagePath;
  String status = 'Add text, scan an image, or dictate what happened';
  bool initializedLanguage = false;
  bool analyzing = false;
  bool processingImage = false;
  bool listening = false;
  bool keyboardInputModeDesignScreen = true;

  static const analysisLabels = [
    'Situation Summary',
    'Desired Outcome',
    'Involved People',
    'Key Evidence',
    'Missing Information',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initializedLanguage) return;
    initializedLanguage = true;
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh') {
      final traditional =
          locale.scriptCode == 'Hant' ||
          locale.countryCode == 'TW' ||
          locale.countryCode == 'HK';
      voiceLanguage = traditional
          ? AdviceVoiceLanguageDesignScreen.traditionalChinese
          : AdviceVoiceLanguageDesignScreen.simplifiedChinese;
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    for (final controller in analysisControllers) {
      controller.dispose();
    }
    speech.cancel();
    super.dispose();
  }

  Future<void> showImageSourceDialogDesignScreen() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => const _AdviceImageSourceDialog(),
    );
    if (source == null || !mounted) return;
    await pickAndRecognizeDesignScreen(source);
  }

  Future<void> pickAndRecognizeDesignScreen(ImageSource source) async {
    if (processingImage) return;
    setState(() {
      processingImage = true;
      status = source == ImageSource.camera
          ? 'Opening camera...'
          : 'Opening photo library...';
    });
    try {
      final image = await imagePicker.pickImage(
        source: source,
        imageQuality: 95,
      );
      if (image == null || !mounted) return;
      setState(() {
        selectedImagePath = image.path;
        status = 'Recognizing text on this device...';
      });
      final script = voiceLanguage == AdviceVoiceLanguageDesignScreen.english
          ? TextRecognitionScript.latin
          : TextRecognitionScript.chinese;
      final recognizer = TextRecognizer(script: script);
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(image.path),
      );
      await recognizer.close();
      if (!mounted) return;
      final text = recognized.text.trim();
      if (text.isEmpty) {
        setState(() => status = 'No readable text was found in this image');
        return;
      }
      appendToNotesDesignScreen('Recognized image text:\n$text');
      setState(() => status = 'Recognized text added for your review');
    } on Object {
      if (mounted) {
        setState(
          () => status =
              'The image could not be read. Retake it with clearer lighting.',
        );
      }
    } finally {
      if (mounted) setState(() => processingImage = false);
    }
  }

  void appendToNotesDesignScreen(String text) {
    final existing = notesController.text.trim();
    final combined = existing.isEmpty ? text : '$existing\n\n$text';
    notesController.value = TextEditingValue(
      text: combined,
      selection: TextSelection.collapsed(offset: combined.length),
    );
  }

  Future<void> selectKeyboardInputDesignScreen() async {
    if (speech.isListening) {
      await speech.stop();
    }
    if (!mounted) return;
    setState(() {
      listening = false;
      keyboardInputModeDesignScreen = true;
      status = 'Keyboard ready. Type what happened.';
    });
    await requestAppKeyboard();
  }

  Future<void> selectVoiceInputDesignScreen() async {
    setState(() => keyboardInputModeDesignScreen = false);
    await toggleVoiceDesignScreen();
  }

  Future<void> toggleVoiceDesignScreen() async {
    if (speech.isListening) {
      await speech.stop();
      if (mounted) {
        setState(() {
          listening = false;
          status = 'Voice text added. Review it before analysis.';
        });
      }
      return;
    }
    final available = await speech.initialize(
      onStatus: (value) {
        if (!mounted) return;
        if (value == SpeechToText.doneStatus ||
            value == SpeechToText.notListeningStatus) {
          setState(() => listening = false);
        }
      },
      onError: (_) {
        if (mounted) {
          setState(() {
            listening = false;
            status =
                'Voice recognition stopped. Check microphone and speech permissions.';
          });
        }
      },
    );
    if (!available || !mounted) {
      if (mounted) {
        setState(
          () => status = 'Voice recognition is unavailable on this device',
        );
      }
      return;
    }
    final localeId = await resolveSpeechLocaleDesignScreen();
    dictationPrefix = notesController.text.trim();
    setState(() {
      listening = true;
      status = 'Listening in ${voiceLanguage.label} · up to 55 seconds';
    });
    await speech.listen(
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        localeId: localeId,
        listenFor: const Duration(seconds: 55),
        pauseFor: const Duration(seconds: 5),
      ),
      onResult: (result) {
        if (!mounted) return;
        final spoken = result.recognizedWords.trim();
        final combined = [
          dictationPrefix,
          spoken,
        ].where((part) => part.isNotEmpty).join('\n\n');
        notesController.value = TextEditingValue(
          text: combined,
          selection: TextSelection.collapsed(offset: combined.length),
        );
      },
    );
  }

  Future<String?> resolveSpeechLocaleDesignScreen() async {
    final locales = await speech.locales();
    final preferredTokens = switch (voiceLanguage) {
      AdviceVoiceLanguageDesignScreen.english => ['en-US', 'en_US', 'en'],
      AdviceVoiceLanguageDesignScreen.simplifiedChinese => [
        'zh-CN',
        'zh_CN',
        'cmn-Hans',
      ],
      AdviceVoiceLanguageDesignScreen.traditionalChinese => [
        'zh-TW',
        'zh_TW',
        'zh-HK',
        'zh_HK',
        'cmn-Hant',
      ],
    };
    for (final token in preferredTokens) {
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith(token.toLowerCase())) {
          return locale.localeId;
        }
      }
    }
    return null;
  }

  Future<void> analyzeDesignScreen() async {
    final prompt = notesController.text.trim();
    if (prompt.length < 10) {
      setState(() => status = 'Add more detail before analysis');
      return;
    }
    if (speech.isListening) await speech.stop();
    setState(() {
      listening = false;
      analyzing = true;
      status = 'Organizing your situation...';
    });
    try {
      final result = await widget.suggestionService.suggest(
        section: WorkspaceSetupSection.advice,
        prompt: prompt,
      );
      if (!mounted) return;
      for (var index = 0; index < analysisControllers.length; index++) {
        final suggestion = result.fields[index];
        analysisControllers[index].text = suggestion.description.isEmpty
            ? suggestion.title
            : suggestion.description;
      }
      setState(() {
        status = result.isLive
            ? 'Consultant preparation ready for review'
            : 'Preview preparation ready for review';
      });
    } on WorkspaceSuggestionException catch (error) {
      if (mounted) setState(() => status = error.message);
    } on Object {
      if (mounted) {
        setState(
          () => status = 'The politics consultant could not analyze this text',
        );
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: FirstLaunchHeroPanel(
                      onBack: () => context.go('/engineering'),
                      child: const _AdviceInputHero(),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tell us what happened',
                                    style: TextStyle(
                                      color: Color(0xFF173F5D),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'Combine typed notes, recognized image text, and device dictation',
                                    style: TextStyle(
                                      color: Color(0xFF5E8196),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _VoiceLanguageSelector(
                              value: voiceLanguage,
                              onChanged: (value) =>
                                  setState(() => voiceLanguage = value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          TextField(
                                            key: const ValueKey(
                                              'advice-input-notes',
                                            ),
                                            controller: notesController,
                                            expands: true,
                                            minLines: null,
                                            maxLines: null,
                                            readOnly: !keyboardInputModeDesignScreen,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            onTap: keyboardInputModeDesignScreen
                                                ? requestAppKeyboard
                                                : selectKeyboardInputDesignScreen,
                                            decoration: appInputDecoration(
                                              label: 'Situation and Question',
                                              hint:
                                                  keyboardInputModeDesignScreen
                                                  ? 'Describe what happened, what concerns you, and the outcome you want...'
                                                  : 'Voice input mode. Speak, or tap the keyboard to type.',
                                              contentPadding:
                                                  const EdgeInsets.fromLTRB(
                                                    12,
                                                    12,
                                                    12,
                                                    46,
                                                  ),
                                            ),
                                          ),
                                          if (selectedImagePath != null)
                                            Positioned(
                                              right: 9,
                                              top: 9,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: Image.file(
                                                  File(selectedImagePath!),
                                                  width: 50,
                                                  height: 42,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          Positioned(
                                            left: 8,
                                            bottom: 8,
                                            child: _AdviceComposerCircle(
                                              key: const ValueKey(
                                                'advice-plus',
                                              ),
                                              icon: processingImage
                                                  ? Icons.hourglass_top_rounded
                                                  : Icons.add_rounded,
                                              selected: false,
                                              onPressed: processingImage
                                                  ? null
                                                  : showImageSourceDialogDesignScreen,
                                            ),
                                          ),
                                          Positioned(
                                            right: 8,
                                            bottom: 8,
                                            child: Row(
                                              children: [
                                                _AdviceComposerCircle(
                                                  key: const ValueKey(
                                                    'advice-voice',
                                                  ),
                                                  icon: listening
                                                      ? Icons
                                                            .stop_circle_rounded
                                                      : Icons.mic_rounded,
                                                  selected:
                                                      !keyboardInputModeDesignScreen,
                                                  onPressed:
                                                      selectVoiceInputDesignScreen,
                                                ),
                                                const SizedBox(width: 6),
                                                _AdviceComposerCircle(
                                                  key: const ValueKey(
                                                    'advice-keyboard',
                                                  ),
                                                  icon: Icons
                                                      .keyboard_rounded,
                                                  selected:
                                                      keyboardInputModeDesignScreen,
                                                  onPressed:
                                                      selectKeyboardInputDesignScreen,
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
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CONSULTANT PREPARATION',
                                      style: TextStyle(
                                        color: Color(0xFF318DB6),
                                        fontSize: 8,
                                        letterSpacing: 0.3,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(top: 8),
                                        itemCount: analysisLabels.length,
                                        separatorBuilder: (_, _) =>
                                            const SizedBox(height: 8),
                                        itemBuilder: (context, index) =>
                                            SizedBox(
                                              height: 68,
                                              child: TextField(
                                                key: ValueKey(
                                                  'advice-analysis-$index',
                                                ),
                                                controller:
                                                    analysisControllers[index],
                                                maxLines: 2,
                                                decoration: appInputDecoration(
                                                  hint: 'Not analyzed yet',
                                                  contentPadding:
                                                      const EdgeInsets.fromLTRB(
                                                        10,
                                                        16,
                                                        10,
                                                        6,
                                                      ),
                                                ).copyWith(
                                                  label: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      analysisLabels[index],
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: const TextStyle(
                                                        color: Color(0xFF318DB6),
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                status,
                                key: const ValueKey('advice-input-status'),
                                style: const TextStyle(
                                  color: Color(0xFF337FA8),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 125,
                              height: 49,
                              child: AppButton(
                                label: 'Analyze',
                                leading: const Icon(Icons.auto_awesome_rounded),
                                busy: analyzing,
                                height: 49,
                                animateScale: false,
                                visualKey: const ValueKey(
                                  'advice-analyze-visual',
                                ),
                                onPressed: analyzing
                                    ? null
                                    : analyzeDesignScreen,
                              ),
                            ),
                            const SizedBox(width: 7),
                            SizedBox(
                              width: 140,
                              child: AppButton(
                                label: 'Get Advice',
                                onPressed: () =>
                                    context.go('/design/advice-result'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (analyzing || processingImage) const _AdviceProcessingOverlay(),
        ],
      ),
    );
  }
}

class _AdviceInputHero extends StatelessWidget {
  const _AdviceInputHero();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Icon(Icons.psychology_alt_rounded, color: Color(0xFF3299D0), size: 55),
        SizedBox(height: 8),
        Text(
          'Prepare the facts\nbefore advice',
          style: TextStyle(
            color: Color(0xFF174765),
            fontSize: 24,
            height: 1.06,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Use text, a non-sensitive image, or voice. Recognized and dictated text remains editable before the politics consultant analyzes it.',
          style: TextStyle(
            color: Color(0xFF56819A),
            fontSize: 9,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'Do not photograph or upload confidential workplace material.',
          style: TextStyle(
            color: Color(0xFF725ED2),
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _VoiceLanguageSelector extends StatelessWidget {
  const _VoiceLanguageSelector({required this.value, required this.onChanged});

  final AdviceVoiceLanguageDesignScreen value;
  final ValueChanged<AdviceVoiceLanguageDesignScreen> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AdviceVoiceLanguageDesignScreen>(
      key: const ValueKey('advice-voice-language'),
      tooltip: 'Voice recognition language',
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final language in AdviceVoiceLanguageDesignScreen.values)
          PopupMenuItem(value: language, child: Text(language.label)),
      ],
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFF65C5ED)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.record_voice_over_rounded,
              color: Color(0xFF3299D0),
              size: 16,
            ),
            const SizedBox(width: 5),
            Text(
              value.label,
              style: const TextStyle(
                color: Color(0xFF356A84),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFF725ED2),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdviceImageSourceDialog extends StatelessWidget {
  const _AdviceImageSourceDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 430,
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF39BCEA), Color(0xFF68A8F5), Color(0xFFA184F0)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FCFF),
            borderRadius: BorderRadius.circular(21),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Color(0xFF238DCC),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Add an image',
                        style: TextStyle(
                          color: Color(0xFF143D5B),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF4C7895),
                    ),
                  ],
                ),
                const Text(
                  'Use a photo from this device or take a new one. Do not upload confidential workplace material.',
                  style: TextStyle(
                    color: Color(0xFF54758B),
                    fontSize: 11,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _AdviceImageSourceOption(
                  key: const ValueKey('advice-gallery'),
                  icon: Icons.photo_library_rounded,
                  title: 'Photo from device',
                  subtitle:
                      'Choose an existing image for on-device text recognition.',
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 8),
                _AdviceImageSourceOption(
                  key: const ValueKey('advice-camera'),
                  icon: Icons.camera_alt_rounded,
                  title: 'Take photo',
                  subtitle: 'Capture a new photo with the camera.',
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 105,
                    child: AppButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdviceImageSourceOption extends StatelessWidget {
  const _AdviceImageSourceOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF65C5ED), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFDDF2FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF238DCC), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF143D5B),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF54758B),
                        fontSize: 10,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
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

class _AdviceComposerCircle extends StatelessWidget {
  const _AdviceComposerCircle({
    super.key,
    required this.icon,
    required this.selected,
    this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final button = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF3299D0) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF3299D0) : const Color(0xFF65C5ED),
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : const Color(0xFF3299D0),
      ),
    );
    if (onPressed == null) return button;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: button,
      ),
    );
  }
}

class _AdviceProcessingOverlay extends StatelessWidget {
  const _AdviceProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('advice-processing-overlay'),
      children: [
        const ModalBarrier(dismissible: false, color: Color(0x73000000)),
        Center(
          child: Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(13),
            decoration: const BoxDecoration(
              color: Color(0xFFF4FAFF),
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF806DE2),
              strokeWidth: 4,
            ),
          ),
        ),
      ],
    );
  }
}
