import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/workspace_suggestion_service.dart';
import 'design_avatar.dart';
import 'first_launch_hero_panel.dart';
import 'relationship_quality_bar.dart';

enum RelationshipEditorModeDesignScreen {
  createSelfColleague,
  modifySelfColleague,
  createColleaguePair,
  modifyColleaguePair,
}

class RelationshipEditorDesignScreen extends StatefulWidget {
  const RelationshipEditorDesignScreen({
    super.key,
    this.initialMode = RelationshipEditorModeDesignScreen.modifySelfColleague,
    this.suggestionService = const WorkspaceSuggestionService(),
  });

  final RelationshipEditorModeDesignScreen initialMode;
  final WorkspaceSuggestionService suggestionService;

  @override
  State<RelationshipEditorDesignScreen> createState() =>
      _RelationshipEditorDesignScreenState();
}

class _RelationshipEditorDesignScreenState
    extends State<RelationshipEditorDesignScreen> {
  final promptController = TextEditingController();
  final fields = List.generate(4, (_) => _RelationshipFieldValue());

  late RelationshipEditorModeDesignScreen mode = widget.initialMode;
  double relationshipScore = 0.5;
  bool scoreSelected = false;
  bool analyzing = false;
  String? status;

  _RelationshipPair get pair => _relationshipPairForModeDesignScreen(mode);
  bool get creating =>
      mode == RelationshipEditorModeDesignScreen.createSelfColleague ||
      mode == RelationshipEditorModeDesignScreen.createColleaguePair;

  @override
  void initState() {
    super.initState();
    loadModeDesignScreen();
  }

  @override
  void dispose() {
    promptController.dispose();
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }

  void loadModeDesignScreen() {
    final fixture = _relationshipFixtureForModeDesignScreen(mode);
    for (var index = 0; index < fields.length; index++) {
      fields[index].set(fixture.fields[index].$1, fixture.fields[index].$2);
    }
    relationshipScore = fixture.score;
    scoreSelected = fixture.hasScore;
    promptController.clear();
    status = null;
  }

  void selectModeDesignScreen(RelationshipEditorModeDesignScreen nextMode) {
    setState(() {
      mode = nextMode;
      loadModeDesignScreen();
    });
  }

  Future<void> analyzeDesignScreen() async {
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
        section: WorkspaceSetupSection.relationship,
        prompt: prompt,
      );
      if (!mounted) return;
      for (var index = 0; index < fields.length; index++) {
        final resultIndex = index < 3 ? index : index + 1;
        fields[index].set(
          result.fields[resultIndex].title,
          result.fields[resultIndex].description,
        );
      }
      if (result.fields[3].title.isNotEmpty) {
        relationshipScore = relationshipScoreForLabelDesignScreen(
          result.fields[3].title,
        );
        scoreSelected = true;
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
          () => status =
              'The politics consultant could not analyze this relationship.',
        );
      }
    } finally {
      if (mounted) setState(() => analyzing = false);
    }
  }

  Future<void> editFieldDesignScreen(int index) async {
    final edit = await showDialog<_RelationshipFieldEdit>(
      context: context,
      builder: (context) => _RelationshipFieldDialog(
        definition: relationshipEditorFieldsDesignScreen[index],
        title: fields[index].title.text,
        description: fields[index].description.text,
      ),
    );
    if (edit != null && mounted) {
      setState(() => fields[index].set(edit.title, edit.description));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: _RelationshipPairPanel(pair: pair),
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
                                creating
                                    ? 'Create Relationship'
                                    : 'Modify Relationship',
                                key: const ValueKey(
                                  'relationship-editor-title',
                                ),
                                style: const TextStyle(
                                  color: Color(0xFF173F5D),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${pair.first.name} and ${pair.second.name} · Record shared work, events, and current dynamic',
                                style: const TextStyle(
                                  color: Color(0xFF5E8196),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _RelationshipModeTune(
                          mode: mode,
                          onChanged: selectModeDesignScreen,
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
                              key: const ValueKey('relationship-editor-prompt'),
                              controller: promptController,
                              maxLines: 2,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: appInputDecoration(
                                hint:
                                    'Describe how these two people work together and what has happened...',
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
                              onPressed: analyzeDesignScreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                              ? relationshipLabelForScoreDesignScreen(
                                  relationshipScore,
                                )
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
                      keyPrefix: 'relationship-editor',
                      onChanged: (value) => setState(() {
                        relationshipScore = value;
                        scoreSelected = true;
                      }),
                    ),
                    const SizedBox(height: 10),
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
                        itemCount: relationshipEditorFieldsDesignScreen.length,
                        itemBuilder: (context, index) => _RelationshipFieldCard(
                          key: ValueKey('relationship-editor-field-$index'),
                          definition:
                              relationshipEditorFieldsDesignScreen[index],
                          value: fields[index].title.text,
                          onTap: () => editFieldDesignScreen(index),
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
                        SizedBox(
                          width: 185,
                          child: FirstLaunchBottomAction(
                            child: AppButton(
                              label: creating
                                  ? 'Create Relationship'
                                  : 'Save Relationship',
                              onPressed: () => setState(
                                () => status = creating
                                    ? 'Relationship preview ready to create'
                                    : 'Relationship changes are ready',
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

class _RelationshipModeTune extends StatelessWidget {
  const _RelationshipModeTune({required this.mode, required this.onChanged});

  final RelationshipEditorModeDesignScreen mode;
  final ValueChanged<RelationshipEditorModeDesignScreen> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('relationship-editor-mode-tune'),
      width: 235,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 4.5,
        mainAxisSpacing: 3,
        crossAxisSpacing: 4,
        children: [
          _ModeButton(
            label: 'Create Self + Other',
            selected:
                mode == RelationshipEditorModeDesignScreen.createSelfColleague,
            onTap: () => onChanged(
              RelationshipEditorModeDesignScreen.createSelfColleague,
            ),
          ),
          _ModeButton(
            label: 'Modify Self + Other',
            selected:
                mode == RelationshipEditorModeDesignScreen.modifySelfColleague,
            onTap: () => onChanged(
              RelationshipEditorModeDesignScreen.modifySelfColleague,
            ),
          ),
          _ModeButton(
            label: 'Create Two Colleagues',
            selected:
                mode == RelationshipEditorModeDesignScreen.createColleaguePair,
            onTap: () => onChanged(
              RelationshipEditorModeDesignScreen.createColleaguePair,
            ),
          ),
          _ModeButton(
            label: 'Modify Two Colleagues',
            selected:
                mode == RelationshipEditorModeDesignScreen.modifyColleaguePair,
            onTap: () => onChanged(
              RelationshipEditorModeDesignScreen.modifyColleaguePair,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
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
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? const Color(0xFF806DE2)
                  : const Color(0xFF9EDCF5),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF356A84),
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RelationshipPairPanel extends StatelessWidget {
  const _RelationshipPairPanel({required this.pair});

  final _RelationshipPair pair;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('relationship-editor-pair-panel'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PairAvatar(person: pair.first),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7),
                child: Icon(
                  Icons.sync_alt_rounded,
                  size: 24,
                  color: Color(0xFF3299D0),
                ),
              ),
              _PairAvatar(person: pair.second),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${pair.first.name} ↔ ${pair.second.name}',
            style: const TextStyle(
              color: Color(0xFF174765),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          _PairPersona(person: pair.first),
          const SizedBox(height: 7),
          _PairPersona(person: pair.second),
        ],
      ),
    );
  }
}

class _PairAvatar extends StatelessWidget {
  const _PairAvatar({required this.person});

  final _RelationshipPerson person;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      child: Column(
        children: [
          SizedBox(
            key: ValueKey('relationship-avatar-${person.name}'),
            width: 78,
            height: 82,
            child: CustomPaint(painter: DesignAvatarPainter(person.avatar)),
          ),
          Text(
            person.name,
            style: const TextStyle(
              color: Color(0xFF245672),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PairPersona extends StatelessWidget {
  const _PairPersona({required this.person});

  final _RelationshipPerson person;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${person.name} · ${person.role}',
            style: const TextStyle(
              color: Color(0xFF318DB6),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            person.persona,
            style: const TextStyle(
              color: Color(0xFF345F77),
              fontSize: 8,
              height: 1.25,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipFieldCard extends StatelessWidget {
  const _RelationshipFieldCard({
    super.key,
    required this.definition,
    required this.value,
    required this.onTap,
  });

  final _RelationshipFieldDefinition definition;
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
                    size: 11,
                    color: const Color(0xFF3494BE),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      definition.label,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF318DB6),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 17,
                    color: Color(0xFF4F90AF),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value.isEmpty ? definition.hint : value,
                      maxLines: 1,
                      style: TextStyle(
                        color: value.isEmpty
                            ? const Color(0xFF87A5B6)
                            : const Color(0xFF255873),
                        fontSize: value.isEmpty ? 8.5 : 10,
                        fontWeight: value.isEmpty
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

class _RelationshipFieldDialog extends StatefulWidget {
  const _RelationshipFieldDialog({
    required this.definition,
    required this.title,
    required this.description,
  });

  final _RelationshipFieldDefinition definition;
  final String title;
  final String description;

  @override
  State<_RelationshipFieldDialog> createState() =>
      _RelationshipFieldDialogState();
}

class _RelationshipFieldDialogState extends State<_RelationshipFieldDialog> {
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
                controller: titleController,
                decoration: appInputDecoration(
                  label: 'Brief Heading',
                  hint: widget.definition.hint,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: TextField(
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
                        _RelationshipFieldEdit(
                          titleController.text.trim(),
                          descriptionController.text.trim(),
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

class _RelationshipFieldValue {
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

class _RelationshipFieldEdit {
  const _RelationshipFieldEdit(this.title, this.description);

  final String title;
  final String description;
}

class _RelationshipFieldDefinition {
  const _RelationshipFieldDefinition({
    required this.label,
    required this.hint,
    required this.example,
    required this.icon,
  });

  final String label;
  final String hint;
  final String example;
  final IconData icon;
}

class _RelationshipPerson {
  const _RelationshipPerson({
    required this.name,
    required this.role,
    required this.persona,
    required this.fallbackAvatar,
  });

  final String name;
  final String role;
  final String persona;
  final DesignAvatarData fallbackAvatar;

  DesignAvatarData get avatar => switch (name) {
    'You' => DesignAvatarDraft.self,
    'Alex' => DesignAvatarDraft.firstColleague,
    _ => fallbackAvatar,
  };
}

class _RelationshipPair {
  const _RelationshipPair(this.first, this.second);

  final _RelationshipPerson first;
  final _RelationshipPerson second;
}

class _RelationshipFixture {
  const _RelationshipFixture({
    required this.fields,
    required this.score,
    required this.hasScore,
  });

  final List<(String, String)> fields;
  final double score;
  final bool hasScore;
}

const relationshipEditorFieldsDesignScreen = [
  _RelationshipFieldDefinition(
    label: 'How They Work Together',
    hint: 'Example: Frequent collaborators',
    example:
        '• Work Connection\n  ◦ Peers in different teams\n• Dependency\n  ◦ Share responsibility for one project',
    icon: Icons.link_rounded,
  ),
  _RelationshipFieldDefinition(
    label: 'Major Events',
    hint: 'Example: Disagreement over ownership',
    example:
        '• Event\n  ◦ Disputed ownership of a missed deadline\n• Timing\n  ◦ Happened last month',
    icon: Icons.event_note_outlined,
  ),
  _RelationshipFieldDefinition(
    label: 'Current Dynamic',
    hint: 'Example: Tense but workable',
    example:
        '• Cooperation\n  ◦ Required work continues\n• Trust\n  ◦ Current trust appears limited',
    icon: Icons.handshake_outlined,
  ),
  _RelationshipFieldDefinition(
    label: 'Other Information',
    hint: 'Example: Written confirmation helps',
    example:
        '• Practical Context\n  ◦ Important decisions are confirmed in writing',
    icon: Icons.notes_rounded,
  ),
];

const youRelationshipPersonDesignScreen = _RelationshipPerson(
  name: 'You',
  role: 'Product Analyst',
  persona: 'Analytical, careful, and focused on documented evidence',
  fallbackAvatar: DesignAvatarData(
    skinColor: Color(0xFFF3BE96),
    hairColor: Color(0xFF263D4D),
    outfitColor: Color(0xFF3299D0),
  ),
);

const alexRelationshipPersonDesignScreen = _RelationshipPerson(
  name: 'Alex',
  role: 'Project Manager',
  persona: 'Direct, deadline-focused, and connected to senior leaders',
  fallbackAvatar: DesignAvatarData(
    skinColor: Color(0xFFF0B78D),
    hairColor: Color(0xFF4E362E),
    outfitColor: Color(0xFFE77D68),
  ),
);

const mayaRelationshipPersonDesignScreen = _RelationshipPerson(
  name: 'Maya',
  role: 'Operations Lead',
  persona: 'Calm, practical, and skilled at building agreement privately',
  fallbackAvatar: DesignAvatarData(
    skinColor: Color(0xFF8D5134),
    hairColor: Color(0xFF2B211D),
    outfitColor: Color(0xFF55A987),
    hair: 5,
  ),
);

const jordanRelationshipPersonDesignScreen = _RelationshipPerson(
  name: 'Jordan',
  role: 'Finance Partner',
  persona: 'Reserved, evidence-led, and focused on budget discipline',
  fallbackAvatar: DesignAvatarData(
    skinColor: Color(0xFFE7B18C),
    hairColor: Color(0xFFB9A58C),
    outfitColor: Color(0xFFE6A04F),
    accessory: 1,
  ),
);

const newRelationshipPersonDesignScreen = _RelationshipPerson(
  name: 'New Colleague',
  role: 'Not recorded yet',
  persona: 'Persona will be created from the information entered here',
  fallbackAvatar: DesignAvatarData(
    skinColor: Color(0xFFD9A47F),
    hairColor: Color(0xFF5C4337),
    outfitColor: Color(0xFF806DE2),
  ),
);

_RelationshipPair _relationshipPairForModeDesignScreen(
  RelationshipEditorModeDesignScreen mode,
) {
  return switch (mode) {
    RelationshipEditorModeDesignScreen.createSelfColleague =>
      const _RelationshipPair(
        youRelationshipPersonDesignScreen,
        newRelationshipPersonDesignScreen,
      ),
    RelationshipEditorModeDesignScreen.modifySelfColleague =>
      const _RelationshipPair(
        youRelationshipPersonDesignScreen,
        alexRelationshipPersonDesignScreen,
      ),
    RelationshipEditorModeDesignScreen.createColleaguePair =>
      const _RelationshipPair(
        mayaRelationshipPersonDesignScreen,
        newRelationshipPersonDesignScreen,
      ),
    RelationshipEditorModeDesignScreen.modifyColleaguePair =>
      const _RelationshipPair(
        mayaRelationshipPersonDesignScreen,
        jordanRelationshipPersonDesignScreen,
      ),
  };
}

_RelationshipFixture _relationshipFixtureForModeDesignScreen(
  RelationshipEditorModeDesignScreen mode,
) {
  if (mode == RelationshipEditorModeDesignScreen.modifySelfColleague) {
    return const _RelationshipFixture(
      fields: [
        (
          'Frequent collaborators',
          '• Work Connection\n  ◦ Peers in different teams\n• Dependency\n  ◦ Share one project',
        ),
        (
          'Deadline disagreement',
          '• Escalation\n  ◦ Disputed ownership of a missed deadline',
        ),
        (
          'Tense but workable',
          '• Cooperation\n  ◦ Required work continues\n• Trust\n  ◦ Trust appears limited',
        ),
        (
          'Written confirmation helps',
          '• Practical Context\n  ◦ Important decisions are confirmed in writing',
        ),
      ],
      score: 0.25,
      hasScore: true,
    );
  }
  if (mode == RelationshipEditorModeDesignScreen.modifyColleaguePair) {
    return const _RelationshipFixture(
      fields: [
        (
          'Approval partners',
          '• Work Connection\n  ◦ Operations and Finance coordinate approvals',
        ),
        (
          'Cost target negotiation',
          '• Recent Event\n  ◦ Negotiated the latest cost-reduction target',
        ),
        (
          'Professional cooperation',
          '• Cooperation\n  ◦ Work together with occasional priority conflict',
        ),
        ('Limited evidence', '• Unknown\n  ◦ Informal trust is not yet clear'),
      ],
      score: 0.75,
      hasScore: true,
    );
  }
  return const _RelationshipFixture(
    fields: [('', ''), ('', ''), ('', ''), ('', '')],
    score: 0.5,
    hasScore: false,
  );
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
