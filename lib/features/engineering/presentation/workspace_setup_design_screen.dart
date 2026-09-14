import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/first_launch_design_draft.dart';
import '../data/workspace_setup_design_draft.dart';
import '../data/workspace_suggestion_service.dart';
import 'design_avatar.dart';
import 'first_launch_hero_panel.dart';
import 'relationship_quality_bar.dart';

class WorkspaceSetupDesignScreen extends StatefulWidget {
  const WorkspaceSetupDesignScreen({
    super.key,
    this.suggestionService = const WorkspaceSuggestionService(),
    this.initialStep = 0,
    this.initialScenario = WorkspaceScenarioDesignScreen.firstLaunch,
  });

  final WorkspaceSuggestionService suggestionService;
  final int initialStep;
  final WorkspaceScenarioDesignScreen initialScenario;

  @override
  State<WorkspaceSetupDesignScreen> createState() =>
      _WorkspaceSetupDesignScreenState();
}

enum WorkspaceScenarioDesignScreen {
  firstLaunch('First Launch'),
  create('Create'),
  modify('Modify'),
  createPair('Create Pair'),
  modifyPair('Modify Pair');

  const WorkspaceScenarioDesignScreen(this.label);
  final String label;
}

class _WorkspaceSetupDesignScreenState
    extends State<WorkspaceSetupDesignScreen> {
  final List<TextEditingController> promptControllersDesignScreen =
      List.generate(
        workspaceCollectionStepsDesignScreen.length,
        (_) => TextEditingController(),
      );
  late final List<FocusNode> promptFocusNodesDesignScreen;
  late final List<List<_WorkspaceFieldControllers>>
  fieldControllersDesignScreen = [
    for (final step in workspaceCollectionStepsDesignScreen)
      [
        for (var index = 0; index < step.fields.length; index++)
          _WorkspaceFieldControllers(),
      ],
  ];
  final List<String?> promptErrorsDesignScreen = List.filled(
    workspaceCollectionStepsDesignScreen.length,
    null,
  );
  final List<String?> statusesDesignScreen = List.filled(
    workspaceCollectionStepsDesignScreen.length,
    null,
  );
  final SpeechToText speechDesignScreen = SpeechToText();
  final Random previewRandomDesignScreen = Random();

  late int stepDesignScreen = widget.initialStep;
  late WorkspaceScenarioDesignScreen scenarioDesignScreen =
      widget.initialScenario;
  int? focusedPromptIndexDesignScreen;
  bool analyzingDesignScreen = false;
  bool speechInitializedDesignScreen = false;
  int? listeningCollectionIndexDesignScreen;
  String dictationPrefixDesignScreen = '';
  DateTime effectiveChangeDateDesignScreen = DateTime.now();

  @override
  void initState() {
    super.initState();
    promptFocusNodesDesignScreen = List.generate(
      workspaceCollectionStepsDesignScreen.length,
      (index) => FocusNode()
        ..addListener(() {
          if (!mounted) return;
          setState(() {
            focusedPromptIndexDesignScreen =
                promptFocusNodesDesignScreen[index].hasFocus ? index : null;
          });
        }),
    );
    loadDraftDesignScreen();
    if (isModifyScenarioDesignScreen(scenarioDesignScreen)) {
      populateModifyPreviewDesignScreen();
    }
  }

  @override
  void dispose() {
    saveDraftDesignScreen();
    for (final controller in promptControllersDesignScreen) {
      controller.dispose();
    }
    for (final focusNode in promptFocusNodesDesignScreen) {
      focusNode.dispose();
    }
    for (final step in fieldControllersDesignScreen) {
      for (final field in step) {
        field.dispose();
      }
    }
    speechDesignScreen.cancel();
    super.dispose();
  }

  void loadDraftDesignScreen() {
    for (
      var section = 0;
      section < fieldControllersDesignScreen.length;
      section++
    ) {
      final savedSection = WorkspaceSetupDesignDraft.sections[section];
      for (
        var fieldIndex = 0;
        fieldIndex < fieldControllersDesignScreen[section].length;
        fieldIndex++
      ) {
        final controller = fieldControllersDesignScreen[section][fieldIndex];
        final saved = savedSection[fieldIndex];
        controller
          ..title.text = saved.title
          ..description.text = saved.description
          ..reviewed = saved.reviewed
          ..relationshipScore = saved.relationshipScore;
      }
    }
  }

  void saveDraftDesignScreen() {
    for (
      var section = 0;
      section < fieldControllersDesignScreen.length;
      section++
    ) {
      final savedSection = WorkspaceSetupDesignDraft.sections[section];
      for (
        var fieldIndex = 0;
        fieldIndex < fieldControllersDesignScreen[section].length;
        fieldIndex++
      ) {
        final controller = fieldControllersDesignScreen[section][fieldIndex];
        final saved = savedSection[fieldIndex];
        saved
          ..title = controller.title.text
          ..description = controller.description.text
          ..reviewed = controller.reviewed
          ..relationshipScore = controller.relationshipScore;
      }
    }
  }

  bool isModifyScenarioDesignScreen(WorkspaceScenarioDesignScreen scenario) =>
      scenario == WorkspaceScenarioDesignScreen.modify ||
      scenario == WorkspaceScenarioDesignScreen.modifyPair;

  void populateModifyPreviewDesignScreen() {
    if (stepDesignScreen < 1 ||
        stepDesignScreen > workspaceCollectionStepsDesignScreen.length) {
      return;
    }
    final collectionIndex = stepDesignScreen - 1;
    final step = workspaceCollectionStepsDesignScreen[collectionIndex];
    final previews = workspacePreviewSuggestions(step.section);
    final controllers = fieldControllersDesignScreen[collectionIndex];
    final reviewPrefilledFields = stepDesignScreen < 3;
    for (var index = 0; index < controllers.length; index++) {
      final controller = controllers[index];
      final preview = previews[index];
      if (controller.title.text.trim().isEmpty) {
        controller.title.text = preview.title;
      }
      if (controller.description.text.trim().isEmpty) {
        controller.description.text = preview.description;
      }
      controller.reviewed = reviewPrefilledFields;
    }
    final relationshipIndex = step.fields.indexWhere(
      (field) => field.relationshipScore,
    );
    if (relationshipIndex >= 0) {
      final score = previewRandomDesignScreen.nextInt(5) / 4;
      controllers[relationshipIndex]
        ..title.text = relationshipLabelForScoreDesignScreen(score)
        ..description.clear()
        ..relationshipScore = score
        ..reviewed = reviewPrefilledFields;
    }
  }

  void changeScenarioDesignScreen(WorkspaceScenarioDesignScreen scenario) {
    setState(() {
      scenarioDesignScreen = scenario;
      if (isModifyScenarioDesignScreen(scenario)) {
        populateModifyPreviewDesignScreen();
      }
    });
  }

  Future<void> selectEffectiveChangeDateDesignScreen() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: effectiveChangeDateDesignScreen,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Change Date',
    );
    if (selected == null || !mounted) return;
    setState(() => effectiveChangeDateDesignScreen = selected);
  }

  void changeStepDesignScreen(int step) {
    if (speechDesignScreen.isListening) {
      speechDesignScreen.stop();
    }
    saveDraftDesignScreen();
    final target = step.clamp(0, workspaceCollectionStepsDesignScreen.length);
    context.go(
      workspaceRouteForStepDesignScreen(target, scenario: scenarioDesignScreen),
    );
  }

  Future<void> toggleVoiceInputDesignScreen(int collectionIndex) async {
    if (speechDesignScreen.isListening) {
      await speechDesignScreen.stop();
      if (mounted) {
        setState(() => listeningCollectionIndexDesignScreen = null);
      }
      return;
    }

    if (!speechInitializedDesignScreen) {
      speechInitializedDesignScreen = await speechDesignScreen.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == SpeechToText.doneStatus ||
              status == SpeechToText.notListeningStatus) {
            setState(() => listeningCollectionIndexDesignScreen = null);
          }
        },
        onError: (_) {
          if (!mounted) return;
          final activeIndex = listeningCollectionIndexDesignScreen;
          setState(() {
            listeningCollectionIndexDesignScreen = null;
            if (activeIndex != null) {
              promptErrorsDesignScreen[activeIndex] =
                  'Voice input stopped. Check microphone and speech permissions';
            }
          });
        },
      );
    }

    if (!speechInitializedDesignScreen) {
      if (mounted) {
        setState(() {
          promptErrorsDesignScreen[collectionIndex] =
              'Voice input is not available on this device';
        });
      }
      return;
    }

    final controller = promptControllersDesignScreen[collectionIndex];
    dictationPrefixDesignScreen = controller.text.trim();
    setState(() {
      listeningCollectionIndexDesignScreen = collectionIndex;
      promptErrorsDesignScreen[collectionIndex] = null;
    });

    await speechDesignScreen.listen(
      onResult: (result) {
        if (!mounted) return;
        final spokenText = result.recognizedWords.trim();
        final text = [
          dictationPrefixDesignScreen,
          spokenText,
        ].where((part) => part.isNotEmpty).join(' ');
        controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        setState(() => promptErrorsDesignScreen[collectionIndex] = null);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        sampleRate: 44100,
      ),
    );
  }

  Future<void> analyzePromptDesignScreen() async {
    final collectionIndex = stepDesignScreen - 1;
    final prompt = promptControllersDesignScreen[collectionIndex].text.trim();
    if (prompt.isEmpty) {
      setState(() {
        promptErrorsDesignScreen[collectionIndex] =
            'Describe this part of your workplace first';
        statusesDesignScreen[collectionIndex] = null;
      });
      return;
    }

    setState(() {
      analyzingDesignScreen = true;
      promptErrorsDesignScreen[collectionIndex] = null;
      statusesDesignScreen[collectionIndex] = null;
    });

    try {
      final step = workspaceCollectionStepsDesignScreen[collectionIndex];
      final result = await widget.suggestionService.suggest(
        section: step.section,
        prompt: prompt,
      );
      if (!mounted) return;
      for (var index = 0; index < result.fields.length; index++) {
        final field = fieldControllersDesignScreen[collectionIndex][index];
        if (!field.reviewed) {
          field
            ..title.text = result.fields[index].title
            ..description.text = result.fields[index].description;
          if (step.fields[index].relationshipScore) {
            field.relationshipScore = relationshipScoreForLabelDesignScreen(
              result.fields[index].title,
            );
          }
        }
      }
      syncAvatarDetailsDesignScreen(collectionIndex);
      promptFocusNodesDesignScreen[collectionIndex].unfocus();
      promptControllersDesignScreen[collectionIndex].clear();
      setState(() {
        statusesDesignScreen[collectionIndex] = result.isLive
            ? 'Politics consultant analysis ready'
            : 'Preview analysis ready';
      });
    } on WorkspaceSuggestionException catch (error) {
      if (!mounted) return;
      setState(() {
        promptErrorsDesignScreen[collectionIndex] = error.message;
      });
    } on Object catch (error, stackTrace) {
      debugPrint('Workspace suggestion failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        promptErrorsDesignScreen[collectionIndex] =
            'The politics consultant encountered an unexpected problem. Try again.';
      });
    } finally {
      if (mounted) {
        setState(() => analyzingDesignScreen = false);
      }
    }
  }

  Future<void> editFieldDesignScreen(
    int collectionIndex,
    int fieldIndex,
  ) async {
    final field = fieldControllersDesignScreen[collectionIndex][fieldIndex];
    final definition = workspaceCollectionStepsDesignScreen[collectionIndex]
        .fields[fieldIndex];
    final edit = await showDialog<_WorkspaceFieldEdit>(
      context: context,
      builder: (dialogContext) => _WorkspaceFieldEditorDialog(
        definition: definition,
        initialTitle: field.title.text,
        initialDescription: field.description.text,
      ),
    );

    if (edit != null && mounted) {
      setState(() {
        final contentChanged =
            field.title.text != edit.title ||
            field.description.text != edit.description;
        field.title.text = edit.title;
        field.description.text = edit.description;
        if (contentChanged) field.reviewed = false;
        syncAvatarDetailsDesignScreen(collectionIndex);
      });
    }
  }

  void toggleFieldReviewedDesignScreen(int collectionIndex, int fieldIndex) {
    final field = fieldControllersDesignScreen[collectionIndex][fieldIndex];
    if (field.title.text.trim().isEmpty) return;
    setState(() => field.reviewed = !field.reviewed);
  }

  void syncAvatarDetailsDesignScreen(int collectionIndex) {
    if (collectionIndex != 1 && collectionIndex != 2) return;
    final definitions =
        workspaceCollectionStepsDesignScreen[collectionIndex].fields;
    final controllers = fieldControllersDesignScreen[collectionIndex];
    String valueFor(String label) {
      final index = definitions.indexWhere(
        (definition) => definition.label == label,
      );
      return index < 0 ? '' : controllers[index].title.text.trim();
    }

    if (collectionIndex == 1) {
      FirstLaunchDesignDraft.selfSex = valueFor('Sex');
      FirstLaunchDesignDraft.selfAgeRange = valueFor('Age');
    } else {
      FirstLaunchDesignDraft.colleagueSex = valueFor('Sex');
      FirstLaunchDesignDraft.colleagueAgeRange = valueFor('Age');
    }
  }

  @override
  Widget build(BuildContext context) {
    final compactHeight = MediaQuery.sizeOf(context).height < 320;
    final collectionIndex = stepDesignScreen - 1;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF4FAFF),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: _WorkspaceHero(
                      compact: compactHeight,
                      step: stepDesignScreen,
                      scenario: scenarioDesignScreen,
                      onBack: () => context.go('/engineering'),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 7,
                    child: stepDesignScreen == 0
                        ? _WorkspaceIntroduction(
                            compact: compactHeight,
                            onNext: () => changeStepDesignScreen(1),
                          )
                        : _WorkspaceCollectionView(
                            key: ValueKey('workspace-step-$stepDesignScreen'),
                            step:
                                workspaceCollectionStepsDesignScreen[collectionIndex],
                            stepNumber: stepDesignScreen,
                            scenario: scenarioDesignScreen,
                            effectiveChangeDate:
                                isModifyScenarioDesignScreen(
                                      scenarioDesignScreen,
                                    ) &&
                                    stepDesignScreen >= 3
                                ? effectiveChangeDateDesignScreen
                                : null,
                            onSelectEffectiveChangeDate:
                                selectEffectiveChangeDateDesignScreen,
                            compact: compactHeight,
                            promptController:
                                promptControllersDesignScreen[collectionIndex],
                            promptFocusNode:
                                promptFocusNodesDesignScreen[collectionIndex],
                            promptFocused:
                                focusedPromptIndexDesignScreen ==
                                collectionIndex,
                            fields:
                                fieldControllersDesignScreen[collectionIndex],
                            promptError:
                                promptErrorsDesignScreen[collectionIndex],
                            status: statusesDesignScreen[collectionIndex],
                            analyzing: analyzingDesignScreen,
                            listening:
                                listeningCollectionIndexDesignScreen ==
                                collectionIndex,
                            onPromptChanged: () => setState(
                              () => promptErrorsDesignScreen[collectionIndex] =
                                  null,
                            ),
                            onVoiceInput: () =>
                                toggleVoiceInputDesignScreen(collectionIndex),
                            onAnalyze: analyzePromptDesignScreen,
                            onEditField: (fieldIndex) => editFieldDesignScreen(
                              collectionIndex,
                              fieldIndex,
                            ),
                            onToggleReviewed: (fieldIndex) =>
                                toggleFieldReviewedDesignScreen(
                                  collectionIndex,
                                  fieldIndex,
                                ),
                            onToggleRelationshipReviewed: () {
                              final fieldIndex =
                                  workspaceCollectionStepsDesignScreen[collectionIndex]
                                      .fields
                                      .indexWhere(
                                        (field) => field.relationshipScore,
                                      );
                              if (fieldIndex < 0) return;
                              setState(() {
                                final field =
                                    fieldControllersDesignScreen[collectionIndex][fieldIndex];
                                if (field.title.text.trim().isEmpty) {
                                  field
                                    ..title.text = 'Neutral'
                                    ..relationshipScore = 0.5;
                                }
                                field.reviewed = !field.reviewed;
                              });
                            },
                            onRelationshipScoreChanged: (score) {
                              final fieldIndex =
                                  workspaceCollectionStepsDesignScreen[collectionIndex]
                                      .fields
                                      .indexWhere(
                                        (field) => field.relationshipScore,
                                      );
                              if (fieldIndex < 0) return;
                              setState(() {
                                final field =
                                    fieldControllersDesignScreen[collectionIndex][fieldIndex];
                                field.title.text =
                                    relationshipLabelForScoreDesignScreen(
                                      score,
                                    );
                                field.relationshipScore = score;
                                field.description.clear();
                                field.reviewed = true;
                              });
                            },
                            onBack: () =>
                                changeStepDesignScreen(stepDesignScreen - 1),
                            onNext: () {
                              if (stepDesignScreen == 3 &&
                                  scenarioDesignScreen !=
                                      WorkspaceScenarioDesignScreen
                                          .firstLaunch) {
                                context.go(
                                  scenarioDesignScreen ==
                                          WorkspaceScenarioDesignScreen.create
                                      ? '/design/face-lab?mode=colleague-create'
                                      : '/design/face-lab?mode=modify-person&name=Alex',
                                );
                                return;
                              }
                              if (stepDesignScreen <
                                  workspaceCollectionStepsDesignScreen.length) {
                                changeStepDesignScreen(stepDesignScreen + 1);
                              } else {
                                context.go(
                                  scenarioDesignScreen ==
                                          WorkspaceScenarioDesignScreen
                                              .firstLaunch
                                      ? '/design/face-lab?mode=first-launch'
                                      : '/design/people-network',
                                );
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (stepDesignScreen > 0)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              right: 16,
              child: _WorkspaceScenarioSelector(
                scenario: scenarioDesignScreen,
                options: workspaceScenarioOptionsForStepDesignScreen(
                  stepDesignScreen,
                ),
                onChanged: changeScenarioDesignScreen,
              ),
            ),
          if (analyzingDesignScreen) const _AnalysisLoadingOverlay(),
        ],
      ),
    );
  }
}

class _AnalysisLoadingOverlay extends StatelessWidget {
  const _AnalysisLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('workspace-analysis-overlay'),
      children: [
        const ModalBarrier(dismissible: false, color: Color(0x80000000)),
        Center(
          child: SizedBox(
            width: 106,
            height: 106,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: CircularProgressIndicator(
                    color: Color(0xFF63C9F4),
                    backgroundColor: Color(0x66FFFFFF),
                    strokeWidth: 4,
                  ),
                ),
                Container(
                  width: 86,
                  height: 86,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4FAFF),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/the_wings_mission_logo.png',
                      fit: BoxFit.contain,
                      color: Color(0xFF3299D0),
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkspaceHero extends StatelessWidget {
  const _WorkspaceHero({
    required this.compact,
    required this.step,
    required this.scenario,
    required this.onBack,
  });

  final bool compact;
  final int step;
  final WorkspaceScenarioDesignScreen scenario;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return FirstLaunchHeroPanel(
      onBack: onBack,
      child: step == 4
          ? _RelationshipSetupHero(scenario: scenario, compact: compact)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Icon(
                  Icons.dashboard_customize_outlined,
                  color: const Color(0xFF3299D0),
                  size: compact ? 40 : 55,
                ),
                SizedBox(height: compact ? 4 : 8),
                Text(
                  'Start with a\nsmall office picture',
                  style: TextStyle(
                    color: const Color(0xFF174765),
                    fontSize: compact ? 19 : 24,
                    height: 1.06,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: compact ? 4 : 8),
                Text(
                  'Record only the essentials now. You can expand and refine everything later.',
                  style: TextStyle(
                    color: const Color(0xFF56819A),
                    fontSize: compact ? 7.5 : 9,
                    height: compact ? 1.25 : 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
    );
  }
}

class _RelationshipSetupHero extends StatelessWidget {
  const _RelationshipSetupHero({required this.scenario, required this.compact});

  final WorkspaceScenarioDesignScreen scenario;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pair = switch (scenario) {
      WorkspaceScenarioDesignScreen.createPair => (
        'Maya',
        'Jordan',
        'Operations lead · Calm and cautious',
        'Finance partner · Formal and evidence-focused',
      ),
      WorkspaceScenarioDesignScreen.modifyPair => (
        'Maya',
        'Jordan',
        'Operations lead · Calm and cautious',
        'Finance partner · Formal and evidence-focused',
      ),
      WorkspaceScenarioDesignScreen.create => (
        'You',
        'Alex',
        'Product analyst · Cross-team coordinator',
        'Project manager · Direct and deadline-focused',
      ),
      _ => (
        'You',
        'Alex',
        'Product analyst · Cross-team coordinator',
        'Project manager · Direct and deadline-focused',
      ),
    };
    return Column(
      key: const ValueKey('relationship-setup-pair-hero'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RelationshipHeroPerson(
              name: pair.$1,
              avatar: pair.$1 == 'You'
                  ? DesignAvatarDraft.self
                  : const DesignAvatarData(
                      skinColor: Color(0xFFAE6E48),
                      hairColor: Color(0xFF342B2B),
                      outfitColor: Color(0xFF4DA988),
                      hair: 5,
                    ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.sync_alt_rounded,
                color: Color(0xFF806DE2),
                size: 24,
              ),
            ),
            _RelationshipHeroPerson(
              name: pair.$2,
              avatar: pair.$2 == 'Alex'
                  ? DesignAvatarDraft.firstColleague
                  : const DesignAvatarData(
                      skinColor: Color(0xFFFBD0AF),
                      hairColor: Color(0xFF87563A),
                      outfitColor: Color(0xFFD39B42),
                      face: 3,
                      hair: 1,
                      accessory: 1,
                    ),
            ),
          ],
        ),
        SizedBox(height: compact ? 3 : 7),
        Text(
          '${pair.$1} and ${pair.$2}',
          style: TextStyle(
            color: const Color(0xFF174765),
            fontSize: compact ? 17 : 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 3 : 7),
        _RelationshipPersonaSummary(name: pair.$1, summary: pair.$3),
        const SizedBox(height: 5),
        _RelationshipPersonaSummary(name: pair.$2, summary: pair.$4),
      ],
    );
  }
}

class _RelationshipHeroPerson extends StatelessWidget {
  const _RelationshipHeroPerson({required this.name, required this.avatar});

  final String name;
  final DesignAvatarData avatar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CustomPaint(painter: DesignAvatarPainter(avatar)),
          ),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF245672),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipPersonaSummary extends StatelessWidget {
  const _RelationshipPersonaSummary({
    required this.name,
    required this.summary,
  });

  final String name;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: Text(
        '$name · $summary',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF4C748A),
          fontSize: 7.5,
          height: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _WorkspaceIntroduction extends StatelessWidget {
  const _WorkspaceIntroduction({required this.compact, required this.onNext});

  final bool compact;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            'Complete four short setup steps',
            style: TextStyle(
              color: const Color(0xFF173F5D),
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: compact ? 5 : 10),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _IntroductionCard(
                compact: compact,
                number: '1',
                icon: Icons.apartment_rounded,
                title: 'Your workplace',
                description:
                    'The industry, department, location, culture, structure, and current situation.',
              ),
              const SizedBox(width: 10),
              _IntroductionCard(
                compact: compact,
                number: '2',
                icon: Icons.badge_rounded,
                title: 'Yourself',
                description:
                    'Your role and duties, age, tenure, goals, and important context.',
              ),
              const SizedBox(width: 10),
              _IntroductionCard(
                compact: compact,
                number: '3',
                icon: Icons.people_alt_rounded,
                title: 'First colleague',
                description:
                    'Their pseudonym, role, age, and observed working style.',
              ),
              const SizedBox(width: 10),
              _IntroductionCard(
                compact: compact,
                number: '4',
                icon: Icons.hub_rounded,
                title: 'Relationship',
                description:
                    'Your work connection, major events, and current relationship.',
              ),
            ],
          ),
        ),
        SizedBox(height: compact ? 5 : 9),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: const Text(
                  'After setup, you can add or change colleagues at any time and record relationships between any pair of colleagues.',
                  key: ValueKey('workspace-after-setup-text'),
                  style: TextStyle(
                    color: Color(0xFF527A91),
                    fontSize: 9,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FirstLaunchBottomAction(
              child: SizedBox(
                width: 135,
                child: AppButton(label: 'Next', onPressed: onNext),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _IntroductionCard extends StatelessWidget {
  const _IntroductionCard({
    required this.compact,
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final bool compact;
  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(compact ? 7 : 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF3DB9EE), width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: const Color(0xFFE1F5FF),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Color(0xFF277BAA),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(icon, color: const Color(0xFF3599C9), size: 22),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF245672),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF65889A),
                  fontSize: 9.6,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkspaceScenarioSelector extends StatelessWidget {
  const _WorkspaceScenarioSelector({
    required this.scenario,
    required this.options,
    required this.onChanged,
  });

  final WorkspaceScenarioDesignScreen scenario;
  final List<WorkspaceScenarioDesignScreen> options;
  final ValueChanged<WorkspaceScenarioDesignScreen> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<WorkspaceScenarioDesignScreen>(
      key: const ValueKey('workspace-scenario-selector'),
      tooltip: 'Temporary scenario selector',
      initialValue: scenario,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem(
            key: ValueKey('workspace-scenario-${option.name}'),
            value: option,
            child: Text(option.label),
          ),
      ],
      child: Container(
        width: 118,
        height: 27,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFDDF5FF),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFF806DE2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                scenario.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF356A84),
                  fontSize: 6.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(
              Icons.expand_more_rounded,
              color: Color(0xFF725ED2),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkspaceCollectionView extends StatelessWidget {
  const _WorkspaceCollectionView({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.scenario,
    required this.effectiveChangeDate,
    required this.onSelectEffectiveChangeDate,
    required this.compact,
    required this.promptController,
    required this.promptFocusNode,
    required this.promptFocused,
    required this.fields,
    required this.promptError,
    required this.status,
    required this.analyzing,
    required this.listening,
    required this.onPromptChanged,
    required this.onVoiceInput,
    required this.onAnalyze,
    required this.onEditField,
    required this.onToggleReviewed,
    required this.onToggleRelationshipReviewed,
    required this.onRelationshipScoreChanged,
    required this.onBack,
    required this.onNext,
  });

  final _WorkspaceCollectionStep step;
  final int stepNumber;
  final WorkspaceScenarioDesignScreen scenario;
  final DateTime? effectiveChangeDate;
  final VoidCallback onSelectEffectiveChangeDate;
  final bool compact;
  final TextEditingController promptController;
  final FocusNode promptFocusNode;
  final bool promptFocused;
  final List<_WorkspaceFieldControllers> fields;
  final String? promptError;
  final String? status;
  final bool analyzing;
  final bool listening;
  final VoidCallback onPromptChanged;
  final VoidCallback onVoiceInput;
  final VoidCallback onAnalyze;
  final ValueChanged<int> onEditField;
  final ValueChanged<int> onToggleReviewed;
  final VoidCallback onToggleRelationshipReviewed;
  final ValueChanged<double> onRelationshipScoreChanged;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final promptHeight = promptFocused
        ? (compact ? 92.0 : 146.0)
        : (compact ? 53.0 : 65.0);
    final controlGap = promptFocused && !compact ? 15.0 : 8.0;
    final relationshipScoreIndex = step.fields.indexWhere(
      (field) => field.relationshipScore,
    );
    final visibleFieldIndexes = [
      for (var index = 0; index < step.fields.length; index++)
        if (index != relationshipScoreIndex) index,
    ];
    final relationshipScore = relationshipScoreIndex < 0
        ? 0.5
        : fields[relationshipScoreIndex].relationshipScore ??
              relationshipScoreForLabelDesignScreen(
                fields[relationshipScoreIndex].title.text,
              );
    final relationshipLabel =
        relationshipScoreIndex < 0 ||
            fields[relationshipScoreIndex].title.text.trim().isEmpty
        ? 'Neutral'
        : fields[relationshipScoreIndex].title.text;
    final screenTitle = switch ((stepNumber, scenario)) {
      (3, WorkspaceScenarioDesignScreen.create) => 'Create a Colleague',
      (3, WorkspaceScenarioDesignScreen.modify) => 'Modify a Colleague',
      (
        4,
        WorkspaceScenarioDesignScreen.create ||
            WorkspaceScenarioDesignScreen.createPair,
      ) =>
        'Create a Relationship',
      (
        4,
        WorkspaceScenarioDesignScreen.modify ||
            WorkspaceScenarioDesignScreen.modifyPair,
      ) =>
        'Modify a Relationship',
      _ => step.title,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                screenTitle,
                style: TextStyle(
                  color: const Color(0xFF173F5D),
                  fontSize: compact ? 18 : 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 3),
                Text(
                  step.instruction,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color(0xFF5E8196),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: compact ? 4 : 8),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          tween: Tween(end: promptHeight),
          builder: (context, animatedPromptHeight, _) => SizedBox(
            height: animatedPromptHeight,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    key: ValueKey('workspace-prompt-visual-$stepNumber'),
                    height: animatedPromptHeight,
                    child: TextField(
                      key: ValueKey('workspace-prompt-$stepNumber'),
                      controller: promptController,
                      focusNode: promptFocusNode,
                      minLines: null,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onTap: requestAppKeyboard,
                      onTapOutside: (_) => promptFocusNode.unfocus(),
                      onChanged: (_) => onPromptChanged(),
                      decoration: appInputDecoration(
                        hint: promptFocused
                            ? step.expandedPromptHint
                            : step.promptHint,
                        error: promptError,
                        fillColor: promptController.text.trim().isEmpty
                            ? Colors.white
                            : const Color(0xFFE7F4FF),
                        suffix: IconButton(
                          key: ValueKey('workspace-voice-$stepNumber'),
                          tooltip: listening
                              ? 'Stop listening'
                              : 'Use voice input',
                          onPressed: onVoiceInput,
                          icon: Icon(
                            listening
                                ? Icons.stop_circle_rounded
                                : Icons.mic_rounded,
                            color: listening
                                ? const Color(0xFF7E71D8)
                                : const Color(0xFF318DB6),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 125,
                  height: animatedPromptHeight,
                  child: AppButton(
                    key: ValueKey(
                      'workspace-analyze-$stepNumber-${animatedPromptHeight.toStringAsFixed(2)}',
                    ),
                    label: 'Analyze',
                    leading: const Icon(Icons.auto_awesome_rounded),
                    busy: analyzing,
                    height: animatedPromptHeight,
                    animateScale: false,
                    visualKey: ValueKey('workspace-analyze-visual-$stepNumber'),
                    onPressed: analyzing ? null : onAnalyze,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (effectiveChangeDate != null) ...[
          const SizedBox(height: 5),
          _EffectiveChangeDateRow(
            key: const ValueKey('workspace-effective-change-date'),
            label: stepNumber == 3
                ? 'Profile Change Date'
                : 'Relationship Change Date',
            date: effectiveChangeDate!,
            onTap: onSelectEffectiveChangeDate,
          ),
        ],
        SizedBox(
          height: relationshipScoreIndex >= 0
              ? (compact ? 10 : 14)
              : (compact ? 7 : controlGap),
        ),
        if (relationshipScoreIndex >= 0) ...[
          Row(
            children: [
              const Text(
                'Relationship Score',
                style: TextStyle(
                  color: Color(0xFF318DB6),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              RelationshipScorePill(
                key: const ValueKey('workspace-relationship-value'),
                label: relationshipLabel,
                score: relationshipScore,
              ),
              const SizedBox(width: 7),
              GestureDetector(
                key: const ValueKey('review-Relationship Score'),
                behavior: HitTestBehavior.opaque,
                onTap: onToggleRelationshipReviewed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: fields[relationshipScoreIndex].reviewed
                        ? const Color(0xFF3C98CF)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: fields[relationshipScoreIndex].reviewed
                        ? null
                        : Border.all(color: const Color(0xFF318DB6), width: 2),
                  ),
                  child: fields[relationshipScoreIndex].reviewed
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 15,
                        )
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          RelationshipQualityBar(
            score: relationshipScore,
            keyPrefix: 'workspace-relationship',
            onChanged: onRelationshipScoreChanged,
          ),
          SizedBox(height: compact ? 10 : 14),
        ],
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 7,
              mainAxisExtent: compact ? 55 : 57,
            ),
            itemCount: visibleFieldIndexes.length,
            itemBuilder: (context, visibleIndex) {
              final index = visibleFieldIndexes[visibleIndex];
              final definition = step.fields[index];
              return _WorkspaceReviewField(
                key: ValueKey('workspace-field-$stepNumber-$index'),
                definition: definition,
                value: fields[index].title.text,
                reviewed: fields[index].reviewed,
                onOpen: () => onEditField(index),
                onToggleReviewed: () => onToggleReviewed(index),
              );
            },
          ),
        ),
        SizedBox(height: compact ? 3 : 6),
        Row(
          children: [
            Expanded(
              child: Text(
                status ?? '',
                softWrap: true,
                style: const TextStyle(
                  color: Color(0xFF337FA8),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FirstLaunchBottomAction(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 135,
                    child: AppButton(label: 'Back', onPressed: onBack),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 135,
                    child: AppButton(
                      label:
                          stepNumber ==
                              workspaceCollectionStepsDesignScreen.length
                          ? 'Finish'
                          : 'Next',
                      onPressed: onNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EffectiveChangeDateRow extends StatelessWidget {
  const _EffectiveChangeDateRow({
    super.key,
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final dateText = isToday
        ? 'Today'
        : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Material(
      color: const Color(0xFFE7F4FF),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 29,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF9EDCF5)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 15,
                color: Color(0xFF318DB6),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$label · used in history',
                  style: const TextStyle(
                    color: Color(0xFF356A84),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                dateText,
                style: const TextStyle(
                  color: Color(0xFF725ED2),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.calendar_month_rounded,
                size: 14,
                color: Color(0xFF725ED2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceReviewField extends StatelessWidget {
  const _WorkspaceReviewField({
    super.key,
    required this.definition,
    required this.value,
    required this.reviewed,
    required this.onOpen,
    required this.onToggleReviewed,
  });

  final _WorkspaceFieldData definition;
  final String value;
  final bool reviewed;
  final VoidCallback onOpen;
  final VoidCallback onToggleReviewed;

  @override
  Widget build(BuildContext context) {
    final hasValue = value.trim().isNotEmpty;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF3CA9DD), width: 2),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                left: 10,
                top: 5,
                right: 34,
                bottom: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          definition.icon,
                          color: const Color(0xFF3494BE),
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            definition.label,
                            style: const TextStyle(
                              color: Color(0xFF318DB6),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: definition.relationshipScore && hasValue
                            ? RelationshipQualityBar(
                                score: relationshipScoreForLabelDesignScreen(
                                  value,
                                ),
                                keyPrefix: 'workspace-relationship-card',
                                showLabels: false,
                              )
                            : Text(
                                hasValue ? value : definition.hint,
                                style: TextStyle(
                                  color: hasValue
                                      ? const Color(0xFF255873)
                                      : const Color(0xFF87A5B6),
                                  fontSize: hasValue ? 10.5 : 8.5,
                                  height: 1.15,
                                  fontWeight: hasValue
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 6,
                child: GestureDetector(
                  key: ValueKey('review-${definition.label}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: hasValue ? onToggleReviewed : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: reviewed
                          ? const Color(0xFF3C98CF)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: reviewed
                          ? null
                          : Border.all(
                              color: hasValue
                                  ? const Color(0xFF318DB6)
                                  : const Color(0xFFAFCFDE),
                              width: 2,
                            ),
                    ),
                    child: reviewed
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          )
                        : null,
                  ),
                ),
              ),
              const Positioned(
                right: 4,
                bottom: 0,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF4F90AF),
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceFieldEditorDialog extends StatefulWidget {
  const _WorkspaceFieldEditorDialog({
    required this.definition,
    required this.initialTitle,
    required this.initialDescription,
  });

  final _WorkspaceFieldData definition;
  final String initialTitle;
  final String initialDescription;

  @override
  State<_WorkspaceFieldEditorDialog> createState() =>
      _WorkspaceFieldEditorDialogState();
}

class _WorkspaceFieldEditorDialogState
    extends State<_WorkspaceFieldEditorDialog> {
  late final TextEditingController titleController = TextEditingController(
    text: widget.initialTitle,
  );
  late final TextEditingController descriptionController =
      TextEditingController(text: widget.initialDescription);
  late double relationshipScore = relationshipScoreForLabelDesignScreen(
    widget.initialTitle,
  );

  @override
  void initState() {
    super.initState();
    if (widget.definition.relationshipScore &&
        titleController.text.trim().isEmpty) {
      titleController.text = relationshipLabelForScoreDesignScreen(
        relationshipScore,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF4FAFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 330),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.definition.label,
                style: const TextStyle(
                  color: Color(0xFF173F5D),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.definition.relationshipScore) ...[
                const Text(
                  'Tap the scale to rate the current relationship.',
                  style: TextStyle(
                    color: Color(0xFF56819A),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                RelationshipQualityBar(
                  score: relationshipScore,
                  keyPrefix: 'workspace-relationship',
                  onChanged: (value) {
                    setState(() {
                      relationshipScore = value;
                      titleController.text =
                          relationshipLabelForScoreDesignScreen(value);
                    });
                  },
                ),
                const SizedBox(height: 12),
                Center(
                  child: RelationshipScorePill(
                    key: const ValueKey('workspace-relationship-value'),
                    label: relationshipLabelForScoreDesignScreen(
                      relationshipScore,
                    ),
                    score: relationshipScore,
                  ),
                ),
                const Spacer(),
              ] else ...[
                TextField(
                  key: const ValueKey('workspace-editor-title'),
                  controller: titleController,
                  maxLength: 50,
                  onTap: requestAppKeyboard,
                  decoration: appInputDecoration(
                    label: widget.definition.factOnly
                        ? 'Answer'
                        : 'Brief Heading',
                    hint: widget.definition.factOnly
                        ? widget.definition.editorExample
                        : widget.definition.hint,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 10),
                if (widget.definition.factOnly)
                  const Spacer()
                else
                  Expanded(
                    child: TextField(
                      key: const ValueKey('workspace-editor-description'),
                      controller: descriptionController,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      onTap: requestAppKeyboard,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: appInputDecoration(
                        label: 'Full Description',
                        hint: widget.definition.editorExample,
                      ),
                    ),
                  ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 105,
                    child: AppButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 105,
                    child: AppButton(
                      label: 'OK',
                      onPressed: () => Navigator.pop(
                        context,
                        _WorkspaceFieldEdit(
                          titleController.text.trim(),
                          widget.definition.factOnly ||
                                  widget.definition.relationshipScore
                              ? ''
                              : descriptionController.text.trim(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceFieldEdit {
  const _WorkspaceFieldEdit(this.title, this.description);

  final String title;
  final String description;
}

class _WorkspaceFieldControllers {
  final TextEditingController title = TextEditingController();
  final TextEditingController description = TextEditingController();
  double? relationshipScore;
  bool reviewed = false;

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

class _WorkspaceFieldData {
  const _WorkspaceFieldData(
    this.label,
    this.hint,
    this.editorExample,
    this.icon, {
    this.factOnly = false,
    this.relationshipScore = false,
  });

  final String label;
  final String hint;
  final String editorExample;
  final IconData icon;
  final bool factOnly;
  final bool relationshipScore;
}

class _WorkspaceCollectionStep {
  const _WorkspaceCollectionStep({
    required this.section,
    required this.title,
    required this.instruction,
    required this.promptHint,
    required this.expandedPromptHint,
    required this.icon,
    required this.fields,
  });

  final WorkspaceSetupSection section;
  final String title;
  final String instruction;
  final String promptHint;
  final String expandedPromptHint;
  final IconData icon;
  final List<_WorkspaceFieldData> fields;
}

double relationshipScoreForLabelDesignScreen(String label) {
  return switch (label.trim().toLowerCase()) {
    'very bad' => 0,
    'bad' => 0.25,
    'good' => 0.75,
    'very good' => 1,
    _ => 0.5,
  };
}

String relationshipLabelForScoreDesignScreen(double score) {
  if (score <= 0.125) return 'Very Bad';
  if (score <= 0.375) return 'Bad';
  if (score <= 0.625) return 'Neutral';
  if (score <= 0.875) return 'Good';
  return 'Very Good';
}

String workspaceRouteForStepDesignScreen(
  int step, {
  WorkspaceScenarioDesignScreen scenario =
      WorkspaceScenarioDesignScreen.firstLaunch,
}) {
  final route = switch (step) {
    0 => '/design/workspace-setup',
    1 => '/design/workplace',
    2 => '/design/yourself',
    3 => '/design/colleague',
    _ => '/design/relationship-setup',
  };
  if (scenario == WorkspaceScenarioDesignScreen.firstLaunch || step == 0) {
    return route;
  }
  final mode = switch (scenario) {
    WorkspaceScenarioDesignScreen.firstLaunch => 'first-launch',
    WorkspaceScenarioDesignScreen.create => 'create',
    WorkspaceScenarioDesignScreen.modify => 'modify',
    WorkspaceScenarioDesignScreen.createPair => 'create-pair',
    WorkspaceScenarioDesignScreen.modifyPair => 'modify-pair',
  };
  return '$route?mode=$mode';
}

List<WorkspaceScenarioDesignScreen> workspaceScenarioOptionsForStepDesignScreen(
  int step,
) => switch (step) {
  1 || 2 => const [
    WorkspaceScenarioDesignScreen.firstLaunch,
    WorkspaceScenarioDesignScreen.modify,
  ],
  3 => const [
    WorkspaceScenarioDesignScreen.firstLaunch,
    WorkspaceScenarioDesignScreen.create,
    WorkspaceScenarioDesignScreen.modify,
  ],
  _ => const [
    WorkspaceScenarioDesignScreen.firstLaunch,
    WorkspaceScenarioDesignScreen.create,
    WorkspaceScenarioDesignScreen.modify,
    WorkspaceScenarioDesignScreen.createPair,
    WorkspaceScenarioDesignScreen.modifyPair,
  ],
};

const workspaceCollectionStepsDesignScreen = <_WorkspaceCollectionStep>[
  _WorkspaceCollectionStep(
    section: WorkspaceSetupSection.workplace,
    title: 'Step 1 · Describe your workplace',
    instruction:
        'Include: industry • department • location • work culture • current situation',
    promptHint: 'Describe the workplace details listed above...',
    expandedPromptHint:
        'Include industry, department, location, work culture, current situation, and anything else important. Do not use the organization’s real name.',
    icon: Icons.apartment_rounded,
    fields: [
      _WorkspaceFieldData(
        'Industry',
        'Example: Financial Services',
        'Example: Financial Services, Healthcare, Retail, Manufacturing, Construction, Hospitality, Education, or Telecommunications',
        Icons.factory_outlined,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Department',
        'Example: Human Resources',
        'Example: Human Resources, Finance, Operations, Sales, Marketing, IT, Legal, Procurement, or Customer Service',
        Icons.groups_outlined,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Location',
        'Example: Hong Kong or remote',
        'Example: Hong Kong, London, Singapore, or fully remote',
        Icons.location_on_outlined,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Work Culture',
        'Example: Top-down and competitive',
        '• Decision-Making\n  ◦ Senior leaders make most final decisions\n• Communication\n  ◦ People avoid written disagreement\n• Recognition\n  ◦ Colleagues compete for senior-level visibility',
        Icons.psychology_outlined,
      ),
      _WorkspaceFieldData(
        'Current Situation',
        'Example: Budget cuts and restructuring',
        '• Business Pressure\n  ◦ Revenue has recently fallen\n  ◦ Budgets are being reduced\n• Organizational Change\n  ◦ Teams expect restructuring within three months',
        Icons.insights_outlined,
      ),
      _WorkspaceFieldData(
        'Other Information',
        'Example: Anything important we should know',
        'Add workplace information you think is important for the politics consultant to know.\n\n• Organizational Context\n  ◦ Project decisions involve several departments\n• Informal Practice\n  ◦ Senior approval is often requested before formal meetings',
        Icons.notes_rounded,
      ),
    ],
  ),
  _WorkspaceCollectionStep(
    section: WorkspaceSetupSection.yourself,
    title: 'Step 2 · Describe yourself at work',
    instruction:
        'Include: role and duties • sex • age • tenure • goals • other important context',
    promptHint: 'Describe your role and duties, age, tenure, and goals...',
    expandedPromptHint:
        'Include your role and main duties, sex, exact or approximate age, tenure, goals, and any other work context important for suitable advice.',
    icon: Icons.badge_rounded,
    fields: [
      _WorkspaceFieldData(
        'Role',
        'Example: Product Analyst',
        '• Position\n  ◦ Product Analyst\n• Main Responsibilities\n  ◦ Analyze product and customer data\n  ◦ Coordinate findings across teams',
        Icons.badge_outlined,
      ),
      _WorkspaceFieldData(
        'Sex',
        'Example: Female',
        'Example: Female, male, intersex, or prefer not to say',
        Icons.wc_rounded,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Age',
        'Example: 32 or 30–39',
        'Example: 32, 25–34, in their forties, or 55+',
        Icons.calendar_today_outlined,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Tenure',
        'Example: Two years in this role',
        'Example: Four years at the organization; two years in the current role',
        Icons.schedule_rounded,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Goals',
        'Example: Protect credibility',
        '• Professional Credibility\n  ◦ Keep decisions and contributions accurately documented\n• Delivery\n  ◦ Complete the current project successfully\n• Career\n  ◦ Remain eligible for promotion',
        Icons.flag_outlined,
      ),
      _WorkspaceFieldData(
        'Other Information',
        'Example: New to senior meetings',
        '• Work Context\n  ◦ Recently began attending senior planning meetings\n• Support\n  ◦ Has an experienced mentor in another department',
        Icons.notes_rounded,
      ),
    ],
  ),
  _WorkspaceCollectionStep(
    section: WorkspaceSetupSection.colleague,
    title: 'Step 3 · Add one colleague',
    instruction:
        'Include: pseudonym • role and duties • sex • age • observed working style',
    promptHint:
        'Using a pseudonym, describe this colleague and how they work...',
    expandedPromptHint:
        'Include their pseudonym, role and duties, sex, exact or approximate age, observed working style, and other important details. Do not describe your relationship yet.',
    icon: Icons.people_alt_rounded,
    fields: [
      _WorkspaceFieldData(
        'Pseudonym',
        'Example: Alex',
        'Example: Alex — use an invented name, not the colleague’s real name',
        Icons.person_outline_rounded,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Role',
        'Example: Project Manager',
        '• Position\n  ◦ Project Manager\n• Main Responsibilities\n  ◦ Coordinate project plans and deadlines\n  ◦ Report delivery progress to stakeholders',
        Icons.work_outline_rounded,
      ),
      _WorkspaceFieldData(
        'Sex',
        'Example: Male',
        'Example: Female, male, intersex, or prefer not to say',
        Icons.wc_rounded,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Age',
        'Example: 41 or 40–49',
        'Example: 41, 35–44, in their forties, or 55+',
        Icons.calendar_today_outlined,
        factOnly: true,
      ),
      _WorkspaceFieldData(
        'Observed Style',
        'Example: Direct and deadline-focused',
        '• Meeting Behavior\n  ◦ Directly challenges unclear deadlines\n• Documentation\n  ◦ Asks for decisions to be confirmed by email\n• Evidence\n  ◦ Observed across three recent meetings',
        Icons.visibility_outlined,
      ),
      _WorkspaceFieldData(
        'Other Information',
        'Example: Strong executive access',
        '• Informal Influence\n  ◦ Regularly briefs a senior executive\n• Unknown\n  ◦ The purpose of those discussions is not known',
        Icons.notes_rounded,
      ),
    ],
  ),
  _WorkspaceCollectionStep(
    section: WorkspaceSetupSection.relationship,
    title: 'Step 4 · Describe your relationship',
    instruction:
        'Include: how you work together • major shared events • current dynamic • relationship score',
    promptHint:
        'Describe how you and Alex work together and what has happened...',
    expandedPromptHint:
        'Include how you work together, work dependencies, major shared events, current cooperation, communication, trust, a relationship score, and other important context.',
    icon: Icons.hub_rounded,
    fields: [
      _WorkspaceFieldData(
        'How You Work Together',
        'Example: Frequent collaborator',
        '• Organizational Relationship\n  ◦ Peers in different departments\n  ◦ Neither person manages the other\n• Work Dependency\n  ◦ Jointly responsible for the same project',
        Icons.link_rounded,
      ),
      _WorkspaceFieldData(
        'Major Events',
        'Example: Disagreement over ownership',
        '• Missed Deadline\n  ◦ Disagreed about who owned the task\n• Escalation\n  ◦ Alex copied the director when replying by email\n• Timing\n  ◦ Happened last month',
        Icons.event_note_outlined,
      ),
      _WorkspaceFieldData(
        'Current Dynamic',
        'Example: Tense but workable',
        '• Cooperation\n  ◦ Still coordinate on required work\n• Communication\n  ◦ Exchanges have become formal\n• Trust\n  ◦ Current trust appears limited',
        Icons.handshake_outlined,
      ),
      _WorkspaceFieldData(
        'Relationship Score',
        'Choose from Very Bad to Very Good',
        'Choose the current relationship quality',
        Icons.linear_scale_rounded,
        relationshipScore: true,
      ),
      _WorkspaceFieldData(
        'Other Information',
        'Example: Written confirmation helps',
        '• Practical Context\n  ◦ Important decisions are best confirmed in writing\n• Unknown\n  ◦ It is unclear whether recent tension is temporary',
        Icons.notes_rounded,
      ),
    ],
  ),
];
