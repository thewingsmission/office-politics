import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import '../domain/design_screen_definition.dart';

double engineeringScrollOffsetDesignScreen = 0;

class EngineeringScreen extends StatefulWidget {
  const EngineeringScreen({super.key});

  @override
  State<EngineeringScreen> createState() => _EngineeringScreenState();
}

class _EngineeringScreenState extends State<EngineeringScreen> {
  late final ScrollController scrollControllerDesignScreen;

  @override
  void initState() {
    super.initState();
    scrollControllerDesignScreen = ScrollController(
      initialScrollOffset: engineeringScrollOffsetDesignScreen,
    )..addListener(saveScrollPositionDesignScreen);
  }

  void saveScrollPositionDesignScreen() {
    engineeringScrollOffsetDesignScreen = scrollControllerDesignScreen.offset;
  }

  @override
  void dispose() {
    if (scrollControllerDesignScreen.hasClients) {
      engineeringScrollOffsetDesignScreen = scrollControllerDesignScreen.offset;
    }
    scrollControllerDesignScreen
      ..removeListener(saveScrollPositionDesignScreen)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: CustomScrollView(
          key: const ValueKey('engineering-screen-scroll'),
          controller: scrollControllerDesignScreen,
          slivers: [
            const SliverToBoxAdapter(child: _EngineeringHeader()),
            for (final group in engineeringGroupsDesignScreen) ...[
              SliverToBoxAdapter(child: _EngineeringGroupHeader(group: group)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 5, 28, 25),
                sliver: SliverGrid.builder(
                  itemCount: group.entries.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190,
                    mainAxisSpacing: 28,
                    crossAxisSpacing: 42,
                    mainAxisExtent: 72,
                  ),
                  itemBuilder: (context, index) {
                    final entry = group.entries[index];
                    final definition = designScreenDefinitionById(
                      entry.screenId,
                    )!;
                    return EngineeringDesignButton(
                      definition: definition,
                      displayName: entry.displayName,
                      onPressed: () {
                        final firstLaunchAvatar =
                            group.title == 'First Launch' &&
                            definition.id == 'face-lab';
                        final mode = entry.mode == null
                            ? firstLaunchAvatar
                                  ? '?mode=first-launch'
                                  : ''
                            : '?mode=${entry.mode}';
                        context.go('/design/${definition.id}$mode');
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EngineeringGroupHeader extends StatelessWidget {
  const _EngineeringGroupHeader({required this.group});

  final _EngineeringGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 10, 30, 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFDDF3FF),
              shape: BoxShape.circle,
            ),
            child: Icon(group.icon, color: const Color(0xFF288FC7), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  style: const TextStyle(
                    color: Color(0xFF214E69),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  group.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B8CA0),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineeringHeader extends StatelessWidget {
  const _EngineeringHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 24, 30, 18),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Office Politics UI Lab',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF113A59),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: AppButton(
              label: 'Screen Map',
              leading: const Icon(Icons.account_tree_rounded),
              visualKey: const ValueKey('engineering-screen-map-button'),
              onPressed: () => context.go('/design/screen-map'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EngineeringGroup {
  const _EngineeringGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screenIds,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> screenIds;

  List<_EngineeringScreenEntry> get entries {
    if (title != 'People & Relationships') {
      return [
        for (final screenId in screenIds)
          _EngineeringScreenEntry(screenId: screenId),
      ];
    }
    return const [
      _EngineeringScreenEntry(screenId: 'people-network'),
      _EngineeringScreenEntry(
        screenId: 'colleague',
        mode: 'create',
        displayName: 'Create Colleague',
      ),
      _EngineeringScreenEntry(
        screenId: 'colleague',
        mode: 'modify',
        displayName: 'Modify Colleague',
      ),
      _EngineeringScreenEntry(screenId: 'face-lab'),
      _EngineeringScreenEntry(screenId: 'character-profile'),
      _EngineeringScreenEntry(
        screenId: 'relationship-setup',
        mode: 'create',
        displayName: 'Create Relationship',
      ),
      _EngineeringScreenEntry(
        screenId: 'relationship-setup',
        mode: 'modify',
        displayName: 'Modify Relationship',
      ),
    ];
  }
}

class _EngineeringScreenEntry {
  const _EngineeringScreenEntry({
    required this.screenId,
    this.mode,
    this.displayName,
  });

  final String screenId;
  final String? mode;
  final String? displayName;
}

const engineeringGroupsDesignScreen = <_EngineeringGroup>[
  _EngineeringGroup(
    title: 'Home Hub',
    subtitle: 'The read-only tactical overview and main navigation hub.',
    icon: Icons.home_rounded,
    screenIds: ['home', 'splash'],
  ),
  _EngineeringGroup(
    title: 'First Launch',
    subtitle: 'One-time setup before the user enters Home.',
    icon: Icons.rocket_launch_outlined,
    screenIds: [
      'language-setup',
      'privacy-notice',
      'name-setup',
      'auth',
      'workspace-setup',
      'workplace',
      'yourself',
      'colleague',
      'relationship-setup',
      'face-lab',
    ],
  ),
  _EngineeringGroup(
    title: 'People & Relationships',
    subtitle: 'Colleagues, personas, faces, and pair relationships.',
    icon: Icons.groups_2_outlined,
    screenIds: [
      'people-network',
      'colleague',
      'face-lab',
      'character-profile',
      'relationship-setup',
    ],
  ),
  _EngineeringGroup(
    title: 'Events',
    subtitle: 'Timeline, event detail, creation, feelings, and evidence.',
    icon: Icons.timeline_rounded,
    screenIds: ['event-timeline', 'event-editor', 'artifact-viewer'],
  ),
  _EngineeringGroup(
    title: 'Coach',
    subtitle: 'Unified advice input, reply simulation, roleplay, and outcomes.',
    icon: Icons.psychology_alt_outlined,
    screenIds: [
      'advice-input',
      'advice-result',
      'reply-simulator-input',
      'reply-simulator-result',
      'prediction-outcome',
      'roleplay-setup',
      'roleplay-session',
      'roleplay-feedback',
      'advice-history',
    ],
  ),
  _EngineeringGroup(
    title: 'Office & Knowledge',
    subtitle:
        'Isometric maps, business context, mottos, and sourced scenarios.',
    icon: Icons.apartment_rounded,
    screenIds: [
      'office-map-list',
      'office-map-editor',
      'office-character-panel',
      'business-outlook',
      'industry-profile',
      'motto-feed',
      'motto-library',
      'scenario-library',
      'scenario-detail',
    ],
  ),
  _EngineeringGroup(
    title: 'Arcade',
    subtitle: 'Fictional games, contests, scores, rewards, and premium passes.',
    icon: Icons.sports_esports_rounded,
    screenIds: [
      'arcade',
      'slap-desk',
      'credit-chase',
      'rumour-flip',
      'five-pm-ghost',
      'contest-list',
      'leaderboard',
      'rewarded-ad-offer',
      'premium-pass',
    ],
  ),
  _EngineeringGroup(
    title: 'Account & Settings',
    subtitle: 'Profile, subscription, preferences, data controls, and support.',
    icon: Icons.settings_outlined,
    screenIds: [
      'account',
      'paywall',
      'settings',
      'data-controls',
      'notification-center',
      'help-safety',
    ],
  ),
];

class EngineeringDesignButton extends StatefulWidget {
  const EngineeringDesignButton({
    super.key,
    required this.definition,
    required this.onPressed,
    this.displayName,
  });

  final DesignScreenDefinition definition;
  final VoidCallback onPressed;
  final String? displayName;

  String get resolvedDisplayName => displayName ?? definition.displayName;

  @override
  State<EngineeringDesignButton> createState() =>
      _EngineeringDesignButtonState();
}

class _EngineeringDesignButtonState extends State<EngineeringDesignButton> {
  bool hovered = false;
  bool pressed = false;

  void showInfoDesignScreen() {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 430),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF39BCEA), Color(0xFF68A8F5), Color(0xFFA184F0)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FCFF),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDDF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.definition.icon,
                        color: const Color(0xFF238DCC),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.resolvedDisplayName,
                        style: const TextStyle(
                          color: Color(0xFF143D5B),
                          fontSize: 18,
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
                const SizedBox(height: 16),
                Text(
                  widget.definition.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF54758B),
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: AnimatedScale(
        // Reserve the full grid cell for the pressed state. The idle card is
        // 5/6 size, so growing to 1.0 is visually 1.2× without crossing into
        // adjacent cards.
        scale: pressed
            ? 1
            : hovered
            ? 0.875
            : 5 / 6,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        child: Stack(
          children: [
            Positioned.fill(
              top: 6,
              left: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3DB9EE),
                      Color(0xFF719CF4),
                      Color(0xFFA386F5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            Positioned.fill(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF39BCEA),
                      Color(0xFF68A8F5),
                      Color(0xFFA184F0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: hovered
                      ? const [
                          BoxShadow(
                            color: Color(0x3D5A9DE6),
                            blurRadius: 9,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x1F497FA8),
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                ),
                child: Material(
                  color: pressed ? const Color(0xFFD2F2FF) : Colors.white,
                  animationDuration: const Duration(milliseconds: 220),
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: widget.onPressed,
                    overlayColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                    onHighlightChanged: (value) {
                      setState(() => pressed = value);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDF2FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  widget.definition.icon,
                                  color: const Color(0xFF238DCC),
                                  size: 13,
                                ),
                              ),
                              const Spacer(),
                              Tooltip(
                                message: 'About this screen',
                                child: Material(
                                  color: const Color(0xFFE2F3FD),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    onTap: showInfoDesignScreen,
                                    customBorder: const CircleBorder(),
                                    child: const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Center(
                                        child: Text(
                                          'i',
                                          style: TextStyle(
                                            color: Color(0xFF278DC8),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.resolvedDisplayName,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    color: Color(0xFF143D5B),
                                    fontSize: 10,
                                    height: 1.05,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
