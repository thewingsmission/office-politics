import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_avatar.dart';
import 'first_launch_hero_panel.dart';

class CharacterProfileDesignScreen extends StatefulWidget {
  const CharacterProfileDesignScreen({super.key, this.initialPerson = 'You'});

  final String initialPerson;

  @override
  State<CharacterProfileDesignScreen> createState() =>
      _CharacterProfileDesignScreenState();
}

class _CharacterProfileDesignScreenState
    extends State<CharacterProfileDesignScreen> {
  late int selectedIndex = profilePeopleDesignScreen.indexWhere(
    (person) => person.name == widget.initialPerson,
  );

  @override
  void initState() {
    super.initState();
    if (selectedIndex < 0) selectedIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final person = profilePeopleDesignScreen[selectedIndex];
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
                      'Complete recorded information and related events',
                      style: TextStyle(
                        color: Color(0xFF5E8196),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _ProfileInformationPanel(person: person),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            width: 330,
                            child: Row(
                              key: const ValueKey('character-profile-selector'),
                              children: [
                                for (
                                  var index = 0;
                                  index < profilePeopleDesignScreen.length;
                                  index++
                                ) ...[
                                  Expanded(
                                    child: _ProfileSelectorButton(
                                      person: profilePeopleDesignScreen[index],
                                      selected: selectedIndex == index,
                                      onTap: () =>
                                          setState(() => selectedIndex = index),
                                    ),
                                  ),
                                  if (index <
                                      profilePeopleDesignScreen.length - 1)
                                    const SizedBox(width: 8),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 49,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: person.isSelf
                            ? const SizedBox.shrink()
                            : SizedBox(
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileSelectorButton extends StatelessWidget {
  const _ProfileSelectorButton({
    required this.person,
    required this.selected,
    required this.onTap,
  });

  final _ProfilePerson person;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDDF5FF) : Colors.white,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          height: 37,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: selected
                  ? const Color(0xFF806DE2)
                  : const Color(0xFF65C5ED),
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                person.isSelf ? Icons.person_rounded : Icons.badge_outlined,
                size: 14,
                color: selected
                    ? const Color(0xFF725ED2)
                    : const Color(0xFF318DB6),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    person.name,
                    style: const TextStyle(
                      color: Color(0xFF245672),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
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
    return SingleChildScrollView(
      key: ValueKey('character-profile-information-${person.name}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProfileSection(
            title: person.isSelf
                ? 'Your Recorded Information'
                : 'Colleague Information',
            icon: Icons.assignment_ind_outlined,
            entries: person.information,
          ),
          if (!person.isSelf)
            _ProfileSection(
              title: 'Relationship With You',
              icon: Icons.hub_rounded,
              entries: person.relationship,
            ),
          _EventSection(events: person.events),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.icon,
    required this.entries,
  });

  final String title;
  final IconData icon;
  final List<(String, String)> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
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
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF245672),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Wrap(
            spacing: 8,
            runSpacing: 7,
            children: [
              for (final entry in entries)
                SizedBox(
                  width: 225,
                  child: _InformationEntry(label: entry.$1, value: entry.$2),
                ),
            ],
          ),
        ],
      ),
    );
  }
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

class _EventSection extends StatelessWidget {
  const _EventSection({required this.events});

  final List<(String, String, String)> events;

  @override
  Widget build(BuildContext context) {
    return _ProfileSection(
      title: 'Related Events Added During Use',
      icon: Icons.event_note_rounded,
      entries: [
        for (final event in events) ('${event.$1} · ${event.$2}', event.$3),
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
}

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
