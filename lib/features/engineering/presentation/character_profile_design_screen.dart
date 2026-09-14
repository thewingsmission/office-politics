import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_avatar.dart';
import 'first_launch_hero_panel.dart';

class CharacterProfileDesignScreen extends StatefulWidget {
  const CharacterProfileDesignScreen({super.key, this.initialPerson});

  final String? initialPerson;

  @override
  State<CharacterProfileDesignScreen> createState() =>
      _CharacterProfileDesignScreenState();
}

class _CharacterProfileDesignScreenState
    extends State<CharacterProfileDesignScreen> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    final initialPerson = widget.initialPerson;
    selectedIndex = initialPerson == null
        ? math.Random().nextInt(profilePeopleDesignScreen.length)
        : profilePeopleDesignScreen.indexWhere(
            (person) => person.name == initialPerson,
          );
    if (selectedIndex < 0) selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final person = profilePeopleDesignScreen[selectedIndex];
    return Scaffold(
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
                    child: FirstLaunchHeroPanel(
                      onBack: () => context.go('/design/people-network'),
                      child: _ProfilePersonaPanel(person: person),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Character Profile',
                          style: TextStyle(
                            color: Color(0xFF173F5D),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Personal information, relationships, and recent events',
                          style: TextStyle(
                            color: Color(0xFF5E8196),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Expanded(
                          child: _ProfileInformationPanel(person: person),
                        ),
                        if (!person.isSelf) ...[
                          const SizedBox(height: 5),
                          SizedBox(
                            height: 49,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: 185,
                                child: FirstLaunchBottomAction(
                                  child: AppButton(
                                    label: 'Modify Relationship',
                                    leading: const Icon(Icons.hub_rounded),
                                    onPressed: () => context.go(
                                      '/design/relationship-setup?mode=modify',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _ProfileScenarioSelector(
              selectedIndex: selectedIndex,
              onSelected: (index) => setState(() => selectedIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileScenarioSelector extends StatelessWidget {
  const _ProfileScenarioSelector({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      key: const ValueKey('character-profile-selector'),
      initialValue: selectedIndex,
      tooltip: 'Temporary character preview',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final entry in profilePeopleDesignScreen.indexed)
          PopupMenuItem<int>(
            key: ValueKey('character-profile-person-${entry.$1}'),
            value: entry.$1,
            child: Row(
              children: [
                Icon(
                  entry.$2.isSelf ? Icons.person_rounded : Icons.badge_outlined,
                  size: 17,
                  color: entry.$2.avatar.outfitColor,
                ),
                const SizedBox(width: 8),
                Text(entry.$2.name),
              ],
            ),
          ),
      ],
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFF65C5ED), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x223299D0), blurRadius: 8)],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: Color(0xFF318DB6)),
            SizedBox(width: 5),
            Text(
              'Character',
              style: TextStyle(
                color: Color(0xFF245672),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 3),
            Icon(
              Icons.arrow_drop_down_rounded,
              size: 17,
              color: Color(0xFF318DB6),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePersonaPanel extends StatelessWidget {
  const _ProfilePersonaPanel({required this.person});

  final _ProfilePerson person;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: ValueKey('character-profile-persona-${person.name}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              width: 125,
              height: 135,
              child: CustomPaint(
                key: ValueKey('character-profile-avatar-${person.name}'),
                painter: DesignAvatarPainter(person.avatar),
              ),
            ),
          ),
          Text(
            person.name,
            style: const TextStyle(
              color: Color(0xFF174765),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            person.role,
            style: const TextStyle(
              color: Color(0xFF4381A3),
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'PERSONA',
            style: TextStyle(
              color: Color(0xFF318DB6),
              fontSize: 8,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              for (final trait in person.traits)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF9EDCF5)),
                  ),
                  child: Text(
                    trait,
                    style: const TextStyle(
                      color: Color(0xFF356A84),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          _ProfileMetric(
            label: 'Influence',
            value: person.influence,
            color: const Color(0xFF3299D0),
          ),
          _ProfileMetric(
            label: 'Political Risk',
            value: person.risk,
            color: const Color(0xFF806DE2),
          ),
          Text(
            'Assessment confidence: ${person.confidence}%',
            style: const TextStyle(
              color: Color(0xFF66899C),
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 78,
            child: _HistoryTrendChart(
              title: 'PERSON METRIC HISTORY',
              primaryLabel: 'Influence',
              primaryValues: person.influenceHistory,
              secondaryLabel: 'Political Risk',
              secondaryValues: person.riskHistory,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF356A84),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.75),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInformationPanel extends StatelessWidget {
  const _ProfileInformationPanel({required this.person});

  final _ProfilePerson person;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('character-profile-information-${person.name}'),
      children: [
        Expanded(
          flex: 4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ProfileAreaCard(
                  key: const ValueKey('character-profile-personal-info'),
                  title: 'Personal Information',
                  icon: Icons.assignment_ind_outlined,
                  child: _InformationList(entries: person.information),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: person.isSelf
                    ? const _SelfRelationshipsPanel()
                    : _ProfileAreaCard(
                        key: const ValueKey(
                          'character-profile-self-relationship',
                        ),
                        title: 'Relationship With You',
                        icon: Icons.hub_rounded,
                        child: Column(
                          children: [
                            Expanded(
                              child: _InformationList(
                                entries: person.relationship,
                              ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              height: 55,
                              child: _HistoryTrendChart(
                                title: 'RELATIONSHIP SCORE HISTORY',
                                primaryLabel: 'Score',
                                primaryValues: person.relationshipHistory,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          flex: 3,
          child: _ProfileAreaCard(
            key: const ValueKey('character-profile-recent-events'),
            title: person.isSelf
                ? 'Recent Events Involving You'
                : 'Recent Events Involving ${person.name}',
            icon: Icons.event_note_rounded,
            child: _InformationList(
              entries: [
                for (final event in person.events)
                  ('${event.$1} · ${event.$2}', event.$3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileAreaCard extends StatelessWidget {
  const _ProfileAreaCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF3299D0)),
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    maxLines: 1,
                    softWrap: false,
                    style: const TextStyle(
                      color: Color(0xFF245672),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _InformationList extends StatelessWidget {
  const _InformationList({required this.entries});

  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) =>
          _InformationEntry(label: entries[index].$1, value: entries[index].$2),
    );
  }
}

class _SelfRelationshipsPanel extends StatelessWidget {
  const _SelfRelationshipsPanel();

  @override
  Widget build(BuildContext context) {
    return _ProfileAreaCard(
      key: const ValueKey('character-profile-ranked-relationships'),
      title: 'Colleague Relationships',
      icon: Icons.people_alt_outlined,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: selfRelationshipsDesignScreen.length,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final relationship = selfRelationshipsDesignScreen[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${index + 1}. ${relationship.$1}',
                      style: const TextStyle(
                        color: Color(0xFF245672),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    relationship.$2,
                    style: const TextStyle(
                      color: Color(0xFF725ED2),
                      fontSize: 7.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: relationship.$3,
                  minHeight: 5,
                  backgroundColor: const Color(0xFFDDF5FF),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF806DE2)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HistoryTrendChart extends StatelessWidget {
  const _HistoryTrendChart({
    required this.title,
    required this.primaryLabel,
    required this.primaryValues,
    this.secondaryLabel,
    this.secondaryValues,
  });

  final String title;
  final String primaryLabel;
  final List<double> primaryValues;
  final String? secondaryLabel;
  final List<double>? secondaryValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('profile-trend-${title.toLowerCase()}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF318DB6),
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.35,
          ),
        ),
        const SizedBox(height: 3),
        Expanded(
          child: CustomPaint(
            painter: _HistoryTrendPainter(
              primaryValues: primaryValues,
              secondaryValues: secondaryValues,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _TrendLegend(color: const Color(0xFF3299D0), label: primaryLabel),
            if (secondaryLabel != null) ...[
              const SizedBox(width: 8),
              _TrendLegend(
                color: const Color(0xFF806DE2),
                label: secondaryLabel!,
              ),
            ],
            const Spacer(),
            const Text(
              'Oldest → Latest',
              style: TextStyle(
                color: Color(0xFF7795A5),
                fontSize: 6.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF66899C),
            fontSize: 6.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HistoryTrendPainter extends CustomPainter {
  const _HistoryTrendPainter({
    required this.primaryValues,
    this.secondaryValues,
  });

  final List<double> primaryValues;
  final List<double>? secondaryValues;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    final gridPaint = Paint()
      ..color = const Color(0xFFD5ECF7)
      ..strokeWidth = 1;
    for (final fraction in [0.0, 0.5, 1.0]) {
      final y = chartRect.bottom - chartRect.height * fraction;
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }
    _drawSeries(canvas, chartRect, primaryValues, const Color(0xFF3299D0));
    final secondary = secondaryValues;
    if (secondary != null) {
      _drawSeries(canvas, chartRect, secondary, const Color(0xFF806DE2));
    }
  }

  void _drawSeries(Canvas canvas, Rect rect, List<double> values, Color color) {
    if (values.isEmpty) return;
    final path = Path();
    for (var index = 0; index < values.length; index++) {
      final x = values.length == 1
          ? rect.center.dx
          : rect.left + rect.width * index / (values.length - 1);
      final y = rect.bottom - rect.height * values[index].clamp(0.0, 1.0);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = color);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HistoryTrendPainter oldDelegate) =>
      oldDelegate.primaryValues != primaryValues ||
      oldDelegate.secondaryValues != secondaryValues;
}

class _InformationEntry extends StatelessWidget {
  const _InformationEntry({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF318DB6),
            fontSize: 7.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF345F77),
            fontSize: 8.5,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ProfilePerson {
  const _ProfilePerson({
    required this.name,
    required this.role,
    required this.isSelf,
    required this.fallbackAvatar,
    required this.traits,
    required this.influence,
    required this.risk,
    required this.confidence,
    required this.information,
    required this.relationship,
    required this.events,
  });

  final String name;
  final String role;
  final bool isSelf;
  final DesignAvatarData fallbackAvatar;
  final List<String> traits;
  final double influence;
  final double risk;
  final int confidence;
  final List<(String, String)> information;
  final List<(String, String)> relationship;
  final List<(String, String, String)> events;

  DesignAvatarData get avatar => switch (name) {
    'You' => DesignAvatarDraft.self,
    'Alex' => DesignAvatarDraft.firstColleague,
    _ => fallbackAvatar,
  };

  List<double> get influenceHistory => switch (name) {
    'You' => const [0.36, 0.41, 0.44, 0.48],
    'Alex' => const [0.56, 0.61, 0.72, 0.68],
    'Maya' => const [0.62, 0.67, 0.70, 0.74],
    _ => const [0.49, 0.52, 0.55, 0.57],
  };

  List<double> get riskHistory => switch (name) {
    'You' => const [0.28, 0.31, 0.42, 0.35],
    'Alex' => const [0.38, 0.46, 0.70, 0.62],
    'Maya' => const [0.34, 0.30, 0.31, 0.28],
    _ => const [0.31, 0.38, 0.45, 0.42],
  };

  List<double> get relationshipHistory => switch (name) {
    'Alex' => const [0.58, 0.50, 0.25, 0.31],
    'Maya' => const [0.55, 0.62, 0.72, 0.78],
    'Jordan' => const [0.46, 0.50, 0.48, 0.52],
    _ => const [0.5],
  };
}

const selfRelationshipsDesignScreen = <(String, String, double)>[
  ('Maya', 'Good · 78', 0.78),
  ('Jordan', 'Neutral · 52', 0.52),
  ('Alex', 'Bad · 31', 0.31),
];

const profilePeopleDesignScreen = <_ProfilePerson>[
  _ProfilePerson(
    name: 'You',
    role: 'Product Analyst',
    isSelf: true,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFF3BE96),
      hairColor: Color(0xFF263D4D),
      outfitColor: Color(0xFF3299D0),
    ),
    traits: ['Analytical', 'Careful', 'Cross-team'],
    influence: 0.48,
    risk: 0.35,
    confidence: 72,
    information: [
      (
        'Role',
        'Product Analyst · analyzes product data and coordinates findings',
      ),
      ('Sex', 'Female'),
      ('Age', '25–34'),
      ('Tenure', 'Two years'),
      ('Goals', 'Protect credibility and remain eligible for promotion'),
      ('Other Information', 'New to senior planning meetings'),
    ],
    relationship: [],
    events: [
      (
        '12 Sep',
        'Planning Meeting',
        'Presented customer evidence supporting the revised launch plan',
      ),
      (
        '04 Sep',
        'Email Escalation',
        'Clarified ownership after Alex copied the director',
      ),
    ],
  ),
  _ProfilePerson(
    name: 'Alex',
    role: 'Project Manager',
    isSelf: false,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFF0B78D),
      hairColor: Color(0xFF4E362E),
      outfitColor: Color(0xFFE77D68),
    ),
    traits: ['Direct', 'Deadline-focused', 'Visible'],
    influence: 0.68,
    risk: 0.62,
    confidence: 78,
    information: [
      ('Pseudonym', 'Alex'),
      (
        'Role',
        'Project Manager · coordinates plans, deadlines, and status reporting',
      ),
      ('Sex', 'Male'),
      ('Age', '35–44'),
      (
        'Observed Style',
        'Directly challenges unclear deadlines and confirms decisions by email',
      ),
      ('Other Information', 'Regularly briefs a senior executive'),
    ],
    relationship: [
      (
        'How You Work Together',
        'Frequent collaborators delivering the same project',
      ),
      ('Major Events', 'Disagreed over ownership of a missed deadline'),
      ('Current Dynamic', 'Tense but workable; communication is formal'),
      ('Relationship Score', 'Bad'),
    ],
    events: [
      (
        '10 Sep',
        'Deadline Review',
        'Questioned task ownership during the delivery review',
      ),
      (
        '04 Sep',
        'Email Escalation',
        'Copied the director while discussing the missed deadline',
      ),
      ('27 Aug', 'Project Planning', 'Agreed to a shared milestone plan'),
    ],
  ),
  _ProfilePerson(
    name: 'Maya',
    role: 'Operations Lead',
    isSelf: false,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFF8D5134),
      hairColor: Color(0xFF2B211D),
      outfitColor: Color(0xFF55A987),
      hair: 5,
    ),
    traits: ['Calm', 'Practical', 'Well-connected'],
    influence: 0.74,
    risk: 0.28,
    confidence: 64,
    information: [
      ('Pseudonym', 'Maya'),
      ('Role', 'Operations Lead · coordinates service delivery'),
      ('Sex', 'Female'),
      ('Age', '40–49'),
      ('Observed Style', 'Builds agreement privately before formal meetings'),
      ('Other Information', 'Has strong access to operational directors'),
    ],
    relationship: [
      ('How You Work Together', 'Occasional cross-functional collaborator'),
      ('Major Events', 'Supported your evidence during a planning review'),
      ('Current Dynamic', 'Cooperative with limited direct contact'),
      ('Relationship Score', 'Good'),
    ],
    events: [
      ('08 Sep', 'Planning Review', 'Supported the proposed delivery sequence'),
      (
        '20 Aug',
        'Operations Update',
        'Shared early warning about capacity constraints',
      ),
    ],
  ),
  _ProfilePerson(
    name: 'Jordan',
    role: 'Finance Partner',
    isSelf: false,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFE7B18C),
      hairColor: Color(0xFFB9A58C),
      outfitColor: Color(0xFFE6A04F),
      accessory: 1,
    ),
    traits: ['Reserved', 'Evidence-led', 'Budget-focused'],
    influence: 0.57,
    risk: 0.42,
    confidence: 59,
    information: [
      ('Pseudonym', 'Jordan'),
      ('Role', 'Finance Partner · reviews budgets and financial assumptions'),
      ('Sex', 'Male'),
      ('Age', '45'),
      (
        'Observed Style',
        'Asks for written evidence before supporting requests',
      ),
      ('Other Information', 'Advises several department heads'),
    ],
    relationship: [
      (
        'How You Work Together',
        'Reviews financial assumptions for your projects',
      ),
      ('Major Events', 'Requested revisions to your latest business case'),
      ('Current Dynamic', 'Neutral and professional'),
      ('Relationship Score', 'Neutral'),
    ],
    events: [
      (
        '06 Sep',
        'Budget Review',
        'Requested stronger evidence for projected benefits',
      ),
      ('14 Aug', 'Business Case', 'Approved the revised cost assumptions'),
    ],
  ),
];
