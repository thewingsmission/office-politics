import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/workspace_suggestion_service.dart';
import 'first_launch_hero_panel.dart';

enum EventEditorModeDesignScreen { inspect, create }

class EventEditorDesignScreen extends StatefulWidget {
  const EventEditorDesignScreen({
    super.key,
    this.initialMode = EventEditorModeDesignScreen.inspect,
    this.suggestionService = const WorkspaceSuggestionService(),
  });

  final EventEditorModeDesignScreen initialMode;
  final WorkspaceSuggestionService suggestionService;

  @override
  State<EventEditorDesignScreen> createState() =>
      _EventEditorDesignScreenState();
}

class _EventEditorDesignScreenState extends State<EventEditorDesignScreen> {
  final titleController = TextEditingController();
  final dateTimeController = TextEditingController();
  final peopleController = TextEditingController();
  final storyController = TextEditingController();
  final feelingController = TextEditingController();
  final promptController = TextEditingController();

  late EventEditorModeDesignScreen mode = widget.initialMode;
  double politicalImpact = 0;
  double personalStress = 0;
  double urgency = 0;
  double evidenceConfidence = 0;
  bool analyzing = false;
  String? status;

  bool get creating => mode == EventEditorModeDesignScreen.create;

  @override
  void initState() {
    super.initState();
    loadModeDesignScreen();
  }

  @override
  void dispose() {
    titleController.dispose();
    dateTimeController.dispose();
    peopleController.dispose();
    storyController.dispose();
    feelingController.dispose();
    promptController.dispose();
    super.dispose();
  }

  void loadModeDesignScreen() {
    if (creating) {
      for (final controller in [
        titleController,
        dateTimeController,
        peopleController,
        storyController,
        feelingController,
        promptController,
      ]) {
        controller.clear();
      }
      politicalImpact = 0;
      personalStress = 0;
      urgency = 0;
      evidenceConfidence = 0;
    } else {
      titleController.text = 'Deadline ownership escalation';
      dateTimeController.text = '12 Sep 2026 · 3:30 PM';
      peopleController.text = 'You, Alex, Director Lee';
      storyController.text =
          '• What Happened\n  ◦ Alex disputed ownership of a missed deadline by email\n  ◦ The director was copied into the reply\n• Immediate Outcome\n  ◦ A clarification meeting was requested';
      feelingController.text =
          '• Personal Feeling\n  ◦ Worried about professional reputation\n  ◦ Frustrated by the public escalation';
      promptController.clear();
      politicalImpact = 0.78;
      personalStress = 0.68;
      urgency = 0.72;
      evidenceConfidence = 0.84;
    }
    status = null;
  }

  void selectModeDesignScreen(EventEditorModeDesignScreen nextMode) {
    setState(() {
      mode = nextMode;
      loadModeDesignScreen();
    });
  }

  Future<void> analyzeDesignScreen() async {
    final prompt = promptController.text.trim();
    if (prompt.length < 10 || analyzing) {
      setState(() => status = 'Add more event detail before analyzing.');
      return;
    }
    setState(() {
      analyzing = true;
      status = null;
    });
    try {
      final result = await widget.suggestionService.suggest(
        section: WorkspaceSetupSection.event,
        prompt: prompt,
      );
      if (!mounted) return;
      titleController.text = result.fields[0].title;
      dateTimeController.text = result.fields[1].title;
      peopleController.text = result.fields[2].title;
      storyController.text = _combinedSuggestion(result.fields[3]);
      feelingController.text = _combinedSuggestion(result.fields[4]);
      politicalImpact = _metricValue(result.fields[5].title);
      personalStress = _metricValue(result.fields[6].title);
      urgency = _metricValue(result.fields[7].title);
      evidenceConfidence = _metricValue(result.fields[8].title);
      promptController.clear();
      setState(() {
        status = result.isLive
            ? 'Politics consultant analysis ready'
            : 'Preview analysis ready';
      });
    } on Object {
      if (mounted) {
        setState(
          () =>
              status = 'The politics consultant could not analyze this event.',
        );
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  String _combinedSuggestion(WorkspaceFieldSuggestion suggestion) {
    if (suggestion.description.isEmpty) return suggestion.title;
    return suggestion.description;
  }

  double _metricValue(String value) {
    final parsed = double.tryParse(value);
    return ((parsed ?? 0) / 100).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: FirstLaunchHeroPanel(
                  onBack: () => context.go('/design/event-timeline'),
                  child: _EventImpactPanel(
                    creating: creating,
                    title: titleController.text,
                    dateTime: dateTimeController.text,
                    politicalImpact: politicalImpact,
                    personalStress: personalStress,
                    urgency: urgency,
                    evidenceConfidence: evidenceConfidence,
                    onPoliticalImpactChanged: (value) =>
                        setState(() => politicalImpact = value),
                    onPersonalStressChanged: (value) =>
                        setState(() => personalStress = value),
                    onUrgencyChanged: (value) =>
                        setState(() => urgency = value),
                    onEvidenceConfidenceChanged: (value) =>
                        setState(() => evidenceConfidence = value),
                  ),
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                creating ? 'Create Event' : 'Event Detail',
                                key: const ValueKey('event-editor-title'),
                                style: const TextStyle(
                                  color: Color(0xFF173F5D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                'Record facts and personal feelings separately',
                                style: TextStyle(
                                  color: Color(0xFF5E8196),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _EventModeButton(
                          label: 'Inspect Existing',
                          selected: !creating,
                          onTap: () => selectModeDesignScreen(
                            EventEditorModeDesignScreen.inspect,
                          ),
                        ),
                        const SizedBox(width: 5),
                        _EventModeButton(
                          label: 'Create New',
                          selected: creating,
                          onTap: () => selectModeDesignScreen(
                            EventEditorModeDesignScreen.create,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      height: 62,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('event-editor-prompt'),
                              controller: promptController,
                              maxLines: 2,
                              textAlignVertical: TextAlignVertical.top,
                              onTap: requestAppKeyboard,
                              decoration: appInputDecoration(
                                hint:
                                    'Describe the event freely. Include when, who, what happened, and how you felt...',
                                contentPadding: const EdgeInsets.all(10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 125,
                            height: 62,
                            child: AppButton(
                              label: 'Analyze',
                              animateScale: false,
                              busy: analyzing,
                              leading: const Icon(Icons.auto_awesome_rounded),
                              onPressed: analyzeDesignScreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const ValueKey('event-title-field'),
                            controller: titleController,
                            onTap: requestAppKeyboard,
                            decoration: appInputDecoration(
                              label: 'Event Title',
                              hint: 'Short description of the event',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const ValueKey('event-date-field'),
                            controller: dateTimeController,
                            onTap: requestAppKeyboard,
                            decoration: appInputDecoration(
                              label: 'Date and Time',
                              hint: 'Example: 12 Sep 2026, 3:30 PM',
                              suffix: const Icon(Icons.calendar_month_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            key: const ValueKey('event-people-field'),
                            controller: peopleController,
                            onTap: requestAppKeyboard,
                            decoration: appInputDecoration(
                              label: 'Involved People',
                              hint: 'Use pseudonyms',
                              suffix: const Icon(Icons.people_alt_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const ValueKey('event-story-field'),
                              controller: storyController,
                              expands: true,
                              minLines: null,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              onTap: requestAppKeyboard,
                              decoration: appInputDecoration(
                                label: 'Detailed Story',
                                hint:
                                    'Describe observable actions, words, sequence, and outcome',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              key: const ValueKey('event-feeling-field'),
                              controller: feelingController,
                              expands: true,
                              minLines: null,
                              maxLines: null,
                              textAlignVertical: TextAlignVertical.top,
                              onTap: requestAppKeyboard,
                              decoration: appInputDecoration(
                                label: 'Your Personal Feeling',
                                hint:
                                    'Describe emotions, concerns, and uncertainty',
                              ),
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
                            status ?? '',
                            style: const TextStyle(
                              color: Color(0xFF337FA8),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 155,
                          child: FirstLaunchBottomAction(
                            child: AppButton(
                              label: creating ? 'Create Event' : 'Save Changes',
                              onPressed: () => setState(
                                () => status = creating
                                    ? 'Event preview ready to create'
                                    : 'Event changes are ready',
                              ),
                            ),
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
    );
  }
}

class _EventModeButton extends StatelessWidget {
  const _EventModeButton({
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
      color: selected ? const Color(0xFFDDF5FF) : Colors.white,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? const Color(0xFF806DE2)
                  : const Color(0xFF9EDCF5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF356A84),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _EventImpactPanel extends StatelessWidget {
  const _EventImpactPanel({
    required this.creating,
    required this.title,
    required this.dateTime,
    required this.politicalImpact,
    required this.personalStress,
    required this.urgency,
    required this.evidenceConfidence,
    required this.onPoliticalImpactChanged,
    required this.onPersonalStressChanged,
    required this.onUrgencyChanged,
    required this.onEvidenceConfidenceChanged,
  });

  final bool creating;
  final String title;
  final String dateTime;
  final double politicalImpact;
  final double personalStress;
  final double urgency;
  final double evidenceConfidence;
  final ValueChanged<double> onPoliticalImpactChanged;
  final ValueChanged<double> onPersonalStressChanged;
  final ValueChanged<double> onUrgencyChanged;
  final ValueChanged<double> onEvidenceConfidenceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Icon(
          creating ? Icons.add_task_rounded : Icons.event_note_rounded,
          color: const Color(0xFF3299D0),
          size: 48,
        ),
        const SizedBox(height: 5),
        Text(
          title.isEmpty ? 'New workplace event' : title,
          maxLines: 2,
          style: const TextStyle(
            color: Color(0xFF174765),
            fontSize: 20,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          dateTime.isEmpty ? 'Date and time not entered' : dateTime,
          style: const TextStyle(
            color: Color(0xFF56819A),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        _EventMetric(
          label: 'Political Impact',
          caption: 'Effect on power, reputation, resources, or decisions',
          value: politicalImpact,
          onChanged: onPoliticalImpactChanged,
        ),
        _EventMetric(
          label: 'Personal Stress',
          caption: 'Your reported emotional strain',
          value: personalStress,
          onChanged: onPersonalStressChanged,
        ),
        _EventMetric(
          label: 'Urgency',
          caption: 'How soon this event needs attention',
          value: urgency,
          onChanged: onUrgencyChanged,
        ),
        _EventMetric(
          label: 'Evidence Confidence',
          caption: 'Support from records, witnesses, or direct observation',
          value: evidenceConfidence,
          onChanged: onEvidenceConfidenceChanged,
        ),
      ],
    );
  }
}

class _EventMetric extends StatelessWidget {
  const _EventMetric({
    required this.label,
    required this.caption,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String caption;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF318DB6),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}',
                style: const TextStyle(
                  color: Color(0xFF725ED2),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Text(
            caption,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFF66899C),
              fontSize: 6.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 17,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
                activeTrackColor: const Color(0xFF806DE2),
                inactiveTrackColor: const Color(0xFFA9DFF4),
                thumbColor: Colors.white,
              ),
              child: Slider(value: value, onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}
