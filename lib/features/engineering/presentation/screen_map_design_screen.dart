import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_back_button.dart';

class ScreenMapDesignScreen extends StatefulWidget {
  const ScreenMapDesignScreen({super.key});

  @override
  State<ScreenMapDesignScreen> createState() => _ScreenMapDesignScreenState();
}

class _ScreenMapDesignScreenState extends State<ScreenMapDesignScreen> {
  String selectedJourneyDesignScreen = 'overview';

  @override
  Widget build(BuildContext context) {
    final selected = screenMapJourneysDesignScreen
        .where((journey) => journey.id == selectedJourneyDesignScreen)
        .firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _ScreenMapHeader(onBack: () => context.go('/engineering')),
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ListView.separated(
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        itemCount: screenMapJourneysDesignScreen.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final id = index == 0
                              ? 'overview'
                              : screenMapJourneysDesignScreen[index - 1].id;
                          final label = index == 0
                              ? 'Overview'
                              : screenMapJourneysDesignScreen[index - 1].label;
                          return AppButton(
                            label: label,
                            selected: id == selectedJourneyDesignScreen,
                            onPressed: () {
                              setState(() => selectedJourneyDesignScreen = id);
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: selectedJourneyDesignScreen == 'overview'
                          ? _OverviewMap(
                              onJourneySelected: (id) {
                                setState(
                                  () => selectedJourneyDesignScreen = id,
                                );
                              },
                            )
                          : _JourneyMap(journey: selected!),
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

class _ScreenMapHeader extends StatelessWidget {
  const _ScreenMapHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          DesignBackButton(onPressed: onBack),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Office Politics Screen Map',
                  style: TextStyle(
                    color: Color(0xFF173F5D),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Five permanent doors lead to task-specific screens.',
                  style: TextStyle(
                    color: Color(0xFF66879A),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const _MapStat(label: '50 SCREENS'),
          const SizedBox(width: 7),
          const _MapStat(label: '7 JOURNEYS'),
          const SizedBox(width: 7),
          const _MapStat(label: '1 HOME HUB'),
        ],
      ),
    );
  }
}

class _MapStat extends StatelessWidget {
  const _MapStat({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFDFF3FC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF287EAB),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OverviewMap extends StatelessWidget {
  const _OverviewMap({required this.onJourneySelected});

  final ValueChanged<String> onJourneySelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            _PathLabel(text: 'FIRST LAUNCH'),
            SizedBox(width: 8),
            Expanded(
              child: _LinearScreenPath(
                screens: [
                  'Splash',
                  'Language',
                  'Privacy',
                  'Name',
                  'Auth',
                  'Workspace Setup',
                  'Workplace',
                  'Yourself',
                  'Colleague',
                  'Relationship Setup',
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 230,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2B9FD3),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Column(
            children: [
              Icon(Icons.home_rounded, color: Colors.white, size: 20),
              Text(
                'HOME',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Read-only tactical office overview',
                style: TextStyle(
                  color: Color(0xFFDDF6FF),
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: _HubConnectionPainter()),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 42,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final destination
                        in screenMapDestinationsDesignScreen) ...[
                      if (destination !=
                          screenMapDestinationsDesignScreen.first)
                        const SizedBox(width: 9),
                      Expanded(
                        child: _DestinationNode(
                          destination: destination,
                          onTap: () => onJourneySelected(destination.journeyId),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: 4,
                child: Text(
                  'Only these destinations need stable navigation. Editors, OCR, results, roleplay, and game states open temporarily from their parent task.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF68889A),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PathLabel extends StatelessWidget {
  const _PathLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF3188B0),
        fontSize: 8,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _LinearScreenPath extends StatelessWidget {
  const _LinearScreenPath({required this.screens});

  final List<String> screens;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < screens.length; index++) ...[
          Flexible(child: _ScreenChip(label: screens[index])),
          if (index < screens.length - 1)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF7EADBF),
                size: 13,
              ),
            ),
        ],
      ],
    );
  }
}

class _DestinationNode extends StatelessWidget {
  const _DestinationNode({required this.destination, required this.onTap});

  final _ScreenMapDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 82,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB8D9E8), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(destination.icon, color: const Color(0xFF2C92BD), size: 19),
              const SizedBox(height: 3),
              Text(
                destination.label,
                style: const TextStyle(
                  color: Color(0xFF28566D),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  destination.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF708D9C),
                    fontSize: 7,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
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

class _HubConnectionPainter extends CustomPainter {
  const _HubConnectionPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8DBCCC)
      ..strokeWidth = 2;
    final hub = Offset(size.width / 2, 0);
    final railY = 25.0;
    canvas.drawLine(hub, Offset(hub.dx, railY), paint);
    canvas.drawLine(
      Offset(size.width * 0.10, railY),
      Offset(size.width * 0.90, railY),
      paint,
    );
    for (var index = 0; index < 5; index++) {
      final x = size.width * ((index + 0.5) / 5);
      canvas.drawLine(Offset(x, railY), Offset(x, 42), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _JourneyMap extends StatelessWidget {
  const _JourneyMap({required this.journey});

  final _ScreenMapJourney journey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${journey.label} journey',
                    style: const TextStyle(
                      color: Color(0xFF244F67),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    journey.entry,
                    style: const TextStyle(
                      color: Color(0xFF718E9D),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            _MapStat(label: '${journey.screenCount} DEDICATED SCREENS'),
          ],
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: journey.stages.length,
            separatorBuilder: (context, index) => const SizedBox(
              width: 28,
              child: Icon(
                Icons.arrow_forward_rounded,
                color: Color(0xFF79AFC3),
                size: 18,
              ),
            ),
            itemBuilder: (context, index) {
              return _JourneyStageCard(
                index: index + 1,
                stage: journey.stages[index],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'OUTCOME  ',
              style: TextStyle(
                color: Color(0xFF3288AF),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: Text(
                journey.outcome,
                style: const TextStyle(
                  color: Color(0xFF557789),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _JourneyStageCard extends StatelessWidget {
  const _JourneyStageCard({required this.index, required this.stage});

  final int index;
  final _ScreenMapStage stage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${stage.title.toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFF2B8CB5),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          for (
            var screenIndex = 0;
            screenIndex < stage.screens.length;
            screenIndex++
          ) ...[
            _ScreenChip(label: stage.screens[screenIndex]),
            if (screenIndex < stage.screens.length - 1)
              const SizedBox(height: 5),
          ],
          const Spacer(),
          Text(
            stage.note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF718E9C),
              fontSize: 8,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreenChip extends StatelessWidget {
  const _ScreenChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBEDBE7)),
      ),
      child: Text(
        label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF345F74),
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScreenMapDestination {
  const _ScreenMapDestination(
    this.label,
    this.description,
    this.journeyId,
    this.icon,
  );

  final String label;
  final String description;
  final String journeyId;
  final IconData icon;
}

class _ScreenMapStage {
  const _ScreenMapStage(this.title, this.screens, this.note);

  final String title;
  final List<String> screens;
  final String note;
}

class _ScreenMapJourney {
  const _ScreenMapJourney({
    required this.id,
    required this.label,
    required this.screenCount,
    required this.entry,
    required this.outcome,
    required this.stages,
  });

  final String id;
  final String label;
  final int screenCount;
  final String entry;
  final String outcome;
  final List<_ScreenMapStage> stages;
}

const screenMapDestinationsDesignScreen = <_ScreenMapDestination>[
  _ScreenMapDestination(
    'People',
    'Colleagues, personas, and relationships',
    'people',
    Icons.groups_2_rounded,
  ),
  _ScreenMapDestination(
    'Events',
    'Timeline, event details, feelings, and impact',
    'events',
    Icons.timeline_rounded,
  ),
  _ScreenMapDestination(
    'Advice',
    'Coach, reply testing, and roleplay',
    'coach',
    Icons.psychology_alt_rounded,
  ),
  _ScreenMapDestination(
    'Map',
    'Isometric office and person shortcuts',
    'office',
    Icons.map_rounded,
  ),
  _ScreenMapDestination(
    'Arcade',
    'Fictional games, contests, and rewards',
    'arcade',
    Icons.sports_esports_rounded,
  ),
  _ScreenMapDestination(
    'Profile',
    'Account, settings, data, and support',
    'settings',
    Icons.account_circle_rounded,
  ),
];

const screenMapJourneysDesignScreen = <_ScreenMapJourney>[
  _ScreenMapJourney(
    id: 'entry',
    label: 'First launch',
    screenCount: 14,
    entry: 'App opened',
    outcome: 'User reaches Home with a configured workspace.',
    stages: [
      _ScreenMapStage('Start', ['Splash'], 'Load local state.'),
      _ScreenMapStage('Onboarding', [
        'Language Setup',
        'Privacy Notice',
        'Name Setup',
        'Auth',
      ], 'Shown only when required.'),
      _ScreenMapStage(
        'Workspace Setup · 5 screens',
        [
          'Workspace Setup',
          'Workplace',
          'Yourself',
          'Colleague',
          'Relationship Setup',
        ],
        'Each reusable form is maintained as one screen and can serve first-launch or later editing.',
      ),
      _ScreenMapStage('Avatars', [
        'Face Lab',
      ], 'Create avatars for the user and first colleague.'),
      _ScreenMapStage('Hub', ['Home'], 'Permanent destination after setup.'),
      _ScreenMapStage('Account branch', [
        'Account',
        'Paywall',
      ], 'Profile and locked Coach access.'),
    ],
  ),
  _ScreenMapJourney(
    id: 'people',
    label: 'People & relationships',
    screenCount: 9,
    entry: 'Home → colleague or People',
    outcome: 'Reusable people and pairwise relationship records.',
    stages: [
      _ScreenMapStage(
        'Reusable context',
        ['Workplace', 'Yourself', 'Colleague', 'Relationship Setup'],
        'The same forms serve first launch, create, and modify scenarios.',
      ),
      _ScreenMapStage(
        'People & relationships',
        [
          'People Network',
          'Colleague',
          'Face Lab',
          'Character Profile',
          'Relationship Setup',
        ],
        'Explore personas and relationships, then open focused editors.',
      ),
    ],
  ),
  _ScreenMapJourney(
    id: 'events',
    label: 'Events',
    screenCount: 3,
    entry: 'Home → Events',
    outcome: 'Chronological event, feeling, impact, and evidence records.',
    stages: [
      _ScreenMapStage('Timeline', [
        'Event Timeline',
      ], 'Browse events chronologically and open individual records.'),
      _ScreenMapStage(
        'Inspect or create',
        ['Event Editor'],
        'Record date, time, people, detailed story, and personal feeling.',
      ),
      _ScreenMapStage('Evidence', [
        'Artifact Viewer',
      ], 'Review linked source material and provenance.'),
    ],
  ),
  _ScreenMapJourney(
    id: 'coach',
    label: 'Coach',
    screenCount: 9,
    entry: 'Home → Advice',
    outcome: 'Advice, tested replies, practice, and recorded outcomes.',
    stages: [
      _ScreenMapStage('Ask', [
        'Advice Input',
      ], 'Question, goal, people, events, editable OCR, and voice.'),
      _ScreenMapStage('Analysis', [
        'Advice Result',
      ], 'Evidence, scenarios, options, and confidence.'),
      _ScreenMapStage('Reply branch', [
        'Reply Simulator Input',
        'Reply Simulator Result',
        'Prediction Outcome',
      ], 'Compare replies and record reality.'),
      _ScreenMapStage('Practice branch', [
        'Roleplay Setup',
        'Roleplay Session',
        'Roleplay Feedback',
      ], 'Practice safely and receive feedback.'),
      _ScreenMapStage('Archive', [
        'Advice History',
      ], 'Reopen advice, scripts, and outcomes.'),
    ],
  ),
  _ScreenMapJourney(
    id: 'office',
    label: 'Office & knowledge',
    screenCount: 9,
    entry: 'Home → Map, colleague, outlook, motto, or scenario',
    outcome: 'A maintained office model and supporting knowledge.',
    stages: [
      _ScreenMapStage('Build map', [
        'Office Map List',
        'Office Map Editor',
      ], 'Build with the same isometric camera as Home.'),
      _ScreenMapStage('Person shortcut', [
        'Persona Popup',
        'Office Character Panel',
        'Character Profile',
      ], 'Tap a colleague, then open the full record.'),
      _ScreenMapStage('Business', [
        'Industry Profile',
        'Business Outlook',
      ], 'Review cited macro pressures.'),
      _ScreenMapStage('Mottos', [
        'Motto Feed',
        'Motto Library',
      ], 'Browse referenced perspective.'),
      _ScreenMapStage('Scenarios', [
        'Scenario Library',
        'Scenario Detail',
      ], 'Explore sourced workplace patterns.'),
    ],
  ),
  _ScreenMapJourney(
    id: 'arcade',
    label: 'Arcade',
    screenCount: 9,
    entry: 'Home → Arcade',
    outcome: 'A completed run, score, contest result, or earned pass.',
    stages: [
      _ScreenMapStage(
        'Choose',
        ['Arcade'],
        'Choose a fictional game; each game contains its own instructions.',
      ),
      _ScreenMapStage('Play one', [
        'Slap Desk',
        'Credit Chase',
        'Rumour Flip',
        '5pm Ghost',
      ], 'Only one game is entered per run.'),
      _ScreenMapStage('During run', [
        'Rewarded Ad Offer',
      ], 'Pause and resume appear in a popup inside each game.'),
      _ScreenMapStage('Finish', [
        'Leaderboard',
      ], 'Each game shows its result popup before ranking.'),
      _ScreenMapStage('Competition', [
        'Contest List',
        'Premium Pass',
      ], 'Contests can unlock Coach access.'),
    ],
  ),
  _ScreenMapJourney(
    id: 'settings',
    label: 'Account & settings',
    screenCount: 4,
    entry: 'Home → profile avatar',
    outcome: 'Updated preferences, data controls, and support.',
    stages: [
      _ScreenMapStage('Account', [
        'Account',
      ], 'Profile and subscription gateway.'),
      _ScreenMapStage('Preferences', [
        'Settings',
      ], 'Language, AI provider, and accessibility.'),
      _ScreenMapStage('Privacy', [
        'Data Controls',
      ], 'Retention, export, deletion, and consent.'),
      _ScreenMapStage('Updates', [
        'Notification Center',
      ], 'Open the relevant destination.'),
      _ScreenMapStage('Support', [
        'Help & Safety',
      ], 'Globally reachable safety information.'),
    ],
  ),
];
