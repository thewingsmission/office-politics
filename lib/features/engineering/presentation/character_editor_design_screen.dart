import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/workspace_suggestion_service.dart';
import 'first_launch_hero_panel.dart';
import 'relationship_quality_bar.dart';

class CharacterEditorDesignScreen extends StatefulWidget {
  const CharacterEditorDesignScreen({
    super.key,
    this.creating = false,
    this.initialRelationshipStep = false,
    this.suggestionService = const WorkspaceSuggestionService(),
  });

  final bool creating;
  final bool initialRelationshipStep;
  final WorkspaceSuggestionService suggestionService;

  @override
  State<CharacterEditorDesignScreen> createState() =>
      _CharacterEditorDesignScreenState();
}

class _CharacterEditorDesignScreenState
    extends State<CharacterEditorDesignScreen> {
  final promptController = TextEditingController();
  final colleagueFields = List.generate(6, (_) => _CharacterFieldValue());
  final relationshipFields = List.generate(4, (_) => _CharacterFieldValue());

  int step = 0;
  double relationshipScore = 0.5;
  bool scoreSelected = false;
  bool analyzing = false;
  String? status;

  List<_CharacterFieldValue> get activeFields =>
      step == 0 ? colleagueFields : relationshipFields;

  @override
  void initState() {
    super.initState();
    step = widget.initialRelationshipStep ? 1 : 0;
    if (!widget.creating) {
      const colleagueValues = [
        ('Alex', ''),
        (
          'Project Manager',
          '• Main Responsibilities\n  ◦ Coordinate plans and deadlines\n  ◦ Report progress to stakeholders',
        ),
        ('Male', ''),
        ('35–44', ''),
        (
          'Direct and deadline-focused',
          '• Communication\n  ◦ Communicates directly\n• Delivery\n  ◦ Focuses strongly on deadlines',
        ),
        (
          'Strong executive access',
          '• Informal Influence\n  ◦ Regularly briefs a senior executive',
        ),
      ];
      const relationshipValues = [
        (
          'Frequent collaborator',
          '• Work Connection\n  ◦ Peers in different teams\n  ◦ Share responsibility for the same project',
        ),
        (
          'Deadline disagreement',
          '• Escalation\n  ◦ Disputed ownership of a missed deadline\n  ◦ The director was copied by email',
        ),
        (
          'Tense but workable',
          '• Cooperation\n  ◦ Required work continues\n• Trust\n  ◦ Current trust appears limited',
        ),
        (
          'Written confirmation helps',
          '• Practical Context\n  ◦ Important decisions are confirmed in writing',
        ),
      ];
      for (var index = 0; index < colleagueFields.length; index++) {
        colleagueFields[index].set(
          colleagueValues[index].$1,
          colleagueValues[index].$2,
        );
      }
      for (var index = 0; index < relationshipFields.length; index++) {
        relationshipFields[index].set(
          relationshipValues[index].$1,
          relationshipValues[index].$2,
        );
      }
      relationshipScore = 0.25;
      scoreSelected = true;
    }
  }

  @override
  void dispose() {
    promptController.dispose();
    for (final field in [...colleagueFields, ...relationshipFields]) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> analyze() async {
    final prompt = promptController.text.trim();
    if (prompt.length < 10 || analyzing) {
      setState(() => status = 'Add a little more detail before analyzing.');
      return;
    }
    setState(() {
      analyzing = true;
      status = null;
    });
    try {
      final result = await widget.suggestionService.suggest(
        section: step == 0
            ? WorkspaceSetupSection.colleague
            : WorkspaceSetupSection.relationship,
        prompt: prompt,
      );
      if (!mounted) return;
      if (step == 0) {
        for (var index = 0; index < colleagueFields.length; index++) {
          colleagueFields[index].set(
            result.fields[index].title,
            result.fields[index].description,
          );
        }
      } else {
        for (var index = 0; index < relationshipFields.length; index++) {
          final resultIndex = index < 3 ? index : index + 1;
          relationshipFields[index].set(
            result.fields[resultIndex].title,
            result.fields[resultIndex].description,
          );
        }
        final scoreTitle = result.fields[3].title;
        if (scoreTitle.isNotEmpty) {
          relationshipScore = _scoreForLabel(scoreTitle);
          scoreSelected = true;
        }
      }
      promptController.clear();
      setState(() {
        status = result.isLive
            ? 'Politics consultant analysis ready'
            : 'Preview analysis ready';
      });
    } on Object {
      if (mounted) {
        setState(
          () => status = 'The politics consultant could not analyze this text.',
        );
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  Future<void> editField(int index) async {
    final definition = (step == 0
        ? colleagueDefinitions
        : relationshipDefinitions)[index];
    final field = activeFields[index];
    final edit = await showDialog<_CharacterFieldEdit>(
      context: context,
      builder: (context) => _CharacterFieldDialog(
        definition: definition,
        title: field.title.text,
        description: field.description.text,
      ),
    );
    if (edit != null && mounted) {
      setState(() => field.set(edit.title, edit.description));
    }
  }

  void goForward() {
    if (step == 0) {
      setState(() {
        step = 1;
        status = null;
        promptController.clear();
      });
      return;
    }
    final name = colleagueFields.first.title.text.trim().isEmpty
        ? (widget.creating ? 'New Colleague' : 'Alex')
        : colleagueFields.first.title.text.trim();
    context.go(
      '/design/face-lab?mode=${widget.creating ? 'colleague-create' : 'colleague-modify'}&name=${Uri.encodeQueryComponent(name)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final definitions = step == 0
        ? colleagueDefinitions
        : relationshipDefinitions;
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: FirstLaunchHeroPanel(
                  onBack: () => context.go('/design/people-network'),
                  child: _CharacterEditorHero(
                    creating: widget.creating,
                    step: step,
                    name: colleagueFields.first.title.text.trim(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step == 0
                          ? '${widget.creating ? 'Create' : 'Modify'} Colleague · Details'
                          : '${widget.creating ? 'Create' : 'Modify'} Colleague · Relationship With You',
                      key: ValueKey('character-editor-step-$step'),
                      style: const TextStyle(
                        color: Color(0xFF173F5D),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step == 0
                          ? 'Include pseudonym, role and duties, sex, age, observed style, and other important details.'
                          : 'Include how you work together, major events, current dynamic, relationship score, and other context.',
                      style: const TextStyle(
                        color: Color(0xFF5E8196),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      height: 62,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: ValueKey('character-editor-prompt-$step'),
                              controller: promptController,
                              maxLines: 2,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: appInputDecoration(
                                hint: step == 0
                                    ? 'Describe this colleague in your own words...'
                                    : 'Describe your work history and current dynamic...',
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
                              busy: analyzing,
                              animateScale: false,
                              leading: const Icon(Icons.auto_awesome_rounded),
                              onPressed: analyze,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (step == 1) ...[
                      const SizedBox(height: 9),
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
                          Text(
                            scoreSelected
                                ? _labelForScore(relationshipScore)
                                : 'Drag to choose',
                            style: const TextStyle(
                              color: Color(0xFF345F77),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      RelationshipQualityBar(
                        score: relationshipScore,
                        keyPrefix: 'character-editor-relationship',
                        onChanged: (value) => setState(() {
                          relationshipScore = value;
                          scoreSelected = true;
                        }),
                      ),
                      const SizedBox(height: 9),
                    ] else
                      const SizedBox(height: 7),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const ClampingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 7,
                              mainAxisExtent: 57,
                            ),
                        itemCount: definitions.length,
                        itemBuilder: (context, index) => _CharacterFieldCard(
                          key: ValueKey('character-editor-field-$step-$index'),
                          definition: definitions[index],
                          value: activeFields[index].title.text,
                          onTap: () => editField(index),
                        ),
                      ),
                    ),
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
                        FirstLaunchBottomAction(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 135,
                                child: AppButton(
                                  label: 'Back',
                                  onPressed: step == 0
                                      ? () =>
                                            context.go('/design/people-network')
                                      : () => setState(() => step = 0),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 165,
                                child: AppButton(
                                  label: step == 0
                                      ? 'Next'
                                      : widget.creating
                                      ? 'Create Face'
                                      : 'Modify Face',
                                  onPressed: goForward,
                                ),
                              ),
                            ],
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

class _CharacterEditorHero extends StatelessWidget {
  const _CharacterEditorHero({
    required this.creating,
    required this.step,
    required this.name,
  });

  final bool creating;
  final int step;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Icon(
          step == 0 ? Icons.manage_accounts_rounded : Icons.hub_rounded,
          color: const Color(0xFF3299D0),
          size: 55,
        ),
        const SizedBox(height: 9),
        Text(
          creating
              ? 'Create a new\ncolleague'
              : 'Update ${name.isEmpty ? 'Alex' : name}',
          style: const TextStyle(
            color: Color(0xFF174765),
            fontSize: 24,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step == 0
              ? 'Record this person separately from your relationship with them.'
              : 'Now record the shared events and current dynamic between you.',
          style: const TextStyle(
            color: Color(0xFF56819A),
            fontSize: 9,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CharacterFieldCard extends StatelessWidget {
  const _CharacterFieldCard({
    super.key,
    required this.definition,
    required this.value,
    required this.onTap,
  });

  final _CharacterFieldDefinition definition;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 8, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF3CA9DD), width: 2),
          ),
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
                  Text(
                    definition.label,
                    style: const TextStyle(
                      color: Color(0xFF318DB6),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF4F90AF),
                    size: 17,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value.trim().isEmpty ? definition.hint : value,
                      maxLines: 1,
                      style: TextStyle(
                        color: value.trim().isEmpty
                            ? const Color(0xFF87A5B6)
                            : const Color(0xFF255873),
                        fontSize: value.trim().isEmpty ? 8.5 : 10,
                        fontWeight: value.trim().isEmpty
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
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

class _CharacterFieldDialog extends StatefulWidget {
  const _CharacterFieldDialog({
    required this.definition,
    required this.title,
    required this.description,
  });

  final _CharacterFieldDefinition definition;
  final String title;
  final String description;

  @override
  State<_CharacterFieldDialog> createState() => _CharacterFieldDialogState();
}

class _CharacterFieldDialogState extends State<_CharacterFieldDialog> {
  late final titleController = TextEditingController(text: widget.title);
  late final descriptionController = TextEditingController(
    text: widget.description,
  );

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
              TextField(
                key: const ValueKey('character-editor-title'),
                controller: titleController,
                decoration: appInputDecoration(
                  label: widget.definition.factOnly
                      ? 'Answer'
                      : 'Brief Heading',
                  hint: widget.definition.hint,
                ),
              ),
              const SizedBox(height: 10),
              if (widget.definition.factOnly)
                const Spacer()
              else
                Expanded(
                  child: TextField(
                    key: const ValueKey('character-editor-description'),
                    controller: descriptionController,
                    expands: true,
                    minLines: null,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: appInputDecoration(
                      label: 'Full Description',
                      hint: widget.definition.example,
                    ),
                  ),
                ),
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
                        _CharacterFieldEdit(
                          titleController.text.trim(),
                          widget.definition.factOnly
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

class _CharacterFieldValue {
  final title = TextEditingController();
  final description = TextEditingController();

  void set(String titleValue, String descriptionValue) {
    title.text = titleValue;
    description.text = descriptionValue;
  }

  void dispose() {
    title.dispose();
    description.dispose();
  }
}

class _CharacterFieldEdit {
  const _CharacterFieldEdit(this.title, this.description);

  final String title;
  final String description;
}

class _CharacterFieldDefinition {
  const _CharacterFieldDefinition({
    required this.label,
    required this.hint,
    required this.example,
    required this.icon,
    this.factOnly = false,
  });

  final String label;
  final String hint;
  final String example;
  final IconData icon;
  final bool factOnly;
}

const colleagueDefinitions = [
  _CharacterFieldDefinition(
    label: 'Pseudonym',
    hint: 'Example: Alex',
    example: 'Use an invented name',
    icon: Icons.person_outline_rounded,
    factOnly: true,
  ),
  _CharacterFieldDefinition(
    label: 'Role',
    hint: 'Example: Project Manager',
    example:
        '• Position\n  ◦ Project Manager\n• Main Responsibilities\n  ◦ Coordinate plans and deadlines',
    icon: Icons.work_outline_rounded,
  ),
  _CharacterFieldDefinition(
    label: 'Sex',
    hint: 'Example: Male',
    example: 'Female, male, intersex, or prefer not to say',
    icon: Icons.wc_rounded,
    factOnly: true,
  ),
  _CharacterFieldDefinition(
    label: 'Age',
    hint: 'Example: 41 or 40–49',
    example: 'Exact or approximate age',
    icon: Icons.calendar_today_outlined,
    factOnly: true,
  ),
  _CharacterFieldDefinition(
    label: 'Observed Style',
    hint: 'Example: Direct and deadline-focused',
    example:
        '• Communication\n  ◦ Communicates directly\n• Evidence\n  ◦ Observed in recent meetings',
    icon: Icons.visibility_outlined,
  ),
  _CharacterFieldDefinition(
    label: 'Other Information',
    hint: 'Example: Strong executive access',
    example: '• Informal Influence\n  ◦ Regularly briefs a senior executive',
    icon: Icons.notes_rounded,
  ),
];

const relationshipDefinitions = [
  _CharacterFieldDefinition(
    label: 'How You Work Together',
    hint: 'Example: Frequent collaborator',
    example:
        '• Work Connection\n  ◦ Peers in different teams\n• Dependency\n  ◦ Share responsibility for one project',
    icon: Icons.link_rounded,
  ),
  _CharacterFieldDefinition(
    label: 'Major Events',
    hint: 'Example: Disagreement over ownership',
    example:
        '• Event\n  ◦ Disputed ownership of a missed deadline\n• Timing\n  ◦ Happened last month',
    icon: Icons.event_note_outlined,
  ),
  _CharacterFieldDefinition(
    label: 'Current Dynamic',
    hint: 'Example: Tense but workable',
    example:
        '• Cooperation\n  ◦ Required work continues\n• Trust\n  ◦ Current trust appears limited',
    icon: Icons.handshake_outlined,
  ),
  _CharacterFieldDefinition(
    label: 'Other Information',
    hint: 'Example: Written confirmation helps',
    example:
        '• Practical Context\n  ◦ Important decisions are confirmed in writing',
    icon: Icons.notes_rounded,
  ),
];

double _scoreForLabel(String label) {
  return switch (label.trim().toLowerCase()) {
    'very bad' => 0,
    'bad' => 0.25,
    'good' => 0.75,
    'very good' => 1,
    _ => 0.5,
  };
}

String _labelForScore(double score) {
  if (score <= 0.125) return 'Very Bad';
  if (score <= 0.375) return 'Bad';
  if (score <= 0.625) return 'Neutral';
  if (score <= 0.875) return 'Good';
  return 'Very Good';
}
