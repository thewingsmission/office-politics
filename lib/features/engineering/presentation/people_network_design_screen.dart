import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_avatar.dart';
import 'first_launch_hero_panel.dart';
import 'relationship_quality_bar.dart';

class PeopleNetworkDesignScreen extends StatefulWidget {
  const PeopleNetworkDesignScreen({super.key});

  @override
  State<PeopleNetworkDesignScreen> createState() =>
      _PeopleNetworkDesignScreenState();
}

class _PeopleNetworkDesignScreenState extends State<PeopleNetworkDesignScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey sceneKeyDesignScreen = GlobalKey();
  final List<GlobalKey> actorKeysDesignScreen = List<GlobalKey>.generate(
    peopleNetworkPeopleDesignScreen.length,
    (_) => GlobalKey(),
  );
  late final AnimationController motionDesignScreen;

  Size sceneSizeDesignScreen = Size.zero;
  int? selectedPersonDesignScreen;
  _RelationshipSelection? selectedRelationshipDesignScreen;
  int? dragSourceDesignScreen;
  int? pressedPersonDesignScreen;
  int? hoverTargetDesignScreen;
  Offset? dragPointDesignScreen;
  Offset? hoverAnchorDesignScreen;
  bool relationshipTargetReadyDesignScreen = false;
  Timer? targetHoldTimerDesignScreen;
  double outerGlowScaleDesignScreen = 1.25;
  double outerGlowOpacityDesignScreen = 0.55;

  @override
  void initState() {
    super.initState();
    motionDesignScreen = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    targetHoldTimerDesignScreen?.cancel();
    motionDesignScreen.dispose();
    super.dispose();
  }

  Offset localPositionDesignScreen(Offset globalPosition) {
    final renderBox =
        sceneKeyDesignScreen.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.globalToLocal(globalPosition) ?? Offset.zero;
  }

  void selectPersonDesignScreen(int index) {
    targetHoldTimerDesignScreen?.cancel();
    setState(() {
      selectedPersonDesignScreen = index;
      selectedRelationshipDesignScreen = null;
      dragSourceDesignScreen = null;
      hoverTargetDesignScreen = null;
      dragPointDesignScreen = null;
    });
  }

  void clearSelectionDesignScreen() {
    setState(() {
      selectedPersonDesignScreen = null;
      selectedRelationshipDesignScreen = null;
    });
  }

  void startRelationshipDragDesignScreen(int source, Offset globalPosition) {
    targetHoldTimerDesignScreen?.cancel();
    setState(() {
      dragSourceDesignScreen = source;
      dragPointDesignScreen = localPositionDesignScreen(globalPosition);
      hoverTargetDesignScreen = null;
      hoverAnchorDesignScreen = null;
      relationshipTargetReadyDesignScreen = false;
    });
  }

  void beginPersonPressDesignScreen(int index) {
    setState(() => pressedPersonDesignScreen = index);
  }

  void endPersonPressDesignScreen(int index) {
    if (pressedPersonDesignScreen != index) return;
    setState(() => pressedPersonDesignScreen = null);
  }

  int? relationshipTargetAtDesignScreen(Offset globalPosition) {
    for (var index = 0; index < actorKeysDesignScreen.length; index++) {
      if (index == dragSourceDesignScreen) continue;
      final actorBox =
          actorKeysDesignScreen[index].currentContext?.findRenderObject()
              as RenderBox?;
      if (actorBox == null) continue;
      final actorRect = actorBox.localToGlobal(Offset.zero) & actorBox.size;
      if (actorRect.inflate(4).contains(globalPosition)) {
        return index;
      }
    }
    return null;
  }

  void updateRelationshipDragDesignScreen(Offset globalPosition) {
    if (dragSourceDesignScreen == null || sceneSizeDesignScreen.isEmpty) return;
    final local = localPositionDesignScreen(globalPosition);
    final target = relationshipTargetAtDesignScreen(globalPosition);
    final movedInsideTarget =
        hoverAnchorDesignScreen != null &&
        (hoverAnchorDesignScreen! - local).distance > 4;
    if (target != hoverTargetDesignScreen || movedInsideTarget) {
      targetHoldTimerDesignScreen?.cancel();
      hoverTargetDesignScreen = target;
      hoverAnchorDesignScreen = target == null ? null : local;
      relationshipTargetReadyDesignScreen = false;
      if (target != null) {
        targetHoldTimerDesignScreen = Timer(
          const Duration(milliseconds: 300),
          () {
            if (!mounted || hoverTargetDesignScreen != target) return;
            setState(() => relationshipTargetReadyDesignScreen = true);
          },
        );
      }
    }
    setState(() => dragPointDesignScreen = local);
  }

  void completeRelationshipDesignScreen(int target) {
    final source = dragSourceDesignScreen;
    if (!mounted || source == null || source == target) return;
    setState(() {
      selectedRelationshipDesignScreen = _RelationshipSelection(source, target);
      selectedPersonDesignScreen = null;
      dragSourceDesignScreen = null;
      pressedPersonDesignScreen = null;
      hoverTargetDesignScreen = null;
      hoverAnchorDesignScreen = null;
      relationshipTargetReadyDesignScreen = false;
      dragPointDesignScreen = null;
    });
  }

  void endRelationshipDragDesignScreen(Offset globalPosition) {
    targetHoldTimerDesignScreen?.cancel();
    final target = relationshipTargetAtDesignScreen(globalPosition);
    if (dragSourceDesignScreen == null) return;
    if (target != null &&
        target == hoverTargetDesignScreen &&
        relationshipTargetReadyDesignScreen) {
      completeRelationshipDesignScreen(target);
      return;
    }
    setState(() {
      dragSourceDesignScreen = null;
      pressedPersonDesignScreen = null;
      hoverTargetDesignScreen = null;
      hoverAnchorDesignScreen = null;
      relationshipTargetReadyDesignScreen = false;
      dragPointDesignScreen = null;
    });
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
                  onBack: () => context.go('/engineering'),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: selectedRelationshipDesignScreen != null
                        ? _RelationshipPanel(
                            key: ValueKey(selectedRelationshipDesignScreen),
                            selection: selectedRelationshipDesignScreen!,
                          )
                        : selectedPersonDesignScreen != null
                        ? _PersonaPanel(
                            key: ValueKey(selectedPersonDesignScreen),
                            person:
                                peopleNetworkPeopleDesignScreen[selectedPersonDesignScreen!],
                          )
                        : const _PeopleNetworkGuide(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'People & Relationships',
                                  style: TextStyle(
                                    color: Color(0xFF173F5D),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Tap a person for their persona • Hold, drag, hold over another person, then release to view their relationship',
                                  style: TextStyle(
                                    color: Color(0xFF5E8196),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _GlowTunePanel(
                            scale: outerGlowScaleDesignScreen,
                            opacity: outerGlowOpacityDesignScreen,
                            onScaleChanged: (value) => setState(
                              () => outerGlowScaleDesignScreen = value,
                            ),
                            onOpacityChanged: (value) => setState(
                              () => outerGlowOpacityDesignScreen = value,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          sceneSizeDesignScreen = constraints.biggest;
                          return AnimatedBuilder(
                            animation: motionDesignScreen,
                            builder: (context, _) {
                              final positions =
                                  collisionSafePeoplePositionsDesignScreen(
                                    constraints.biggest,
                                    motionDesignScreen.value,
                                  );
                              return GestureDetector(
                                key: sceneKeyDesignScreen,
                                behavior: HitTestBehavior.opaque,
                                onTap: clearSelectionDesignScreen,
                                child: Container(
                                  key: const ValueKey('people-network-scene'),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF8FF),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF65C5ED),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.hardEdge,
                                    children: [
                                      const Positioned.fill(
                                        child: CustomPaint(
                                          painter: _SceneFloorPainter(),
                                        ),
                                      ),
                                      if (dragSourceDesignScreen != null &&
                                          dragPointDesignScreen != null)
                                        Positioned.fill(
                                          child: CustomPaint(
                                            key: ValueKey(
                                              'people-network-relationship-drag-${hoverTargetDesignScreen ?? 'none'}',
                                            ),
                                            painter: _RelationshipDragPainter(
                                              from:
                                                  positions[dragSourceDesignScreen!],
                                              to: dragPointDesignScreen!,
                                              ready:
                                                  relationshipTargetReadyDesignScreen,
                                              pulse: motionDesignScreen.value,
                                            ),
                                          ),
                                        ),
                                      for (
                                        var index = 0;
                                        index <
                                            peopleNetworkPeopleDesignScreen
                                                .length;
                                        index++
                                      )
                                        Positioned(
                                          left: positions[index].dx - 35,
                                          top: positions[index].dy - 50,
                                          child: KeyedSubtree(
                                            key: ValueKey(
                                              'people-network-person-$index',
                                            ),
                                            child: _MovingPerson(
                                              key: actorKeysDesignScreen[index],
                                              person:
                                                  peopleNetworkPeopleDesignScreen[index],
                                              motion: motionDesignScreen.value,
                                              selected:
                                                  selectedPersonDesignScreen ==
                                                      index ||
                                                  hoverTargetDesignScreen ==
                                                      index,
                                              connectionSelected:
                                                  pressedPersonDesignScreen ==
                                                      index ||
                                                  dragSourceDesignScreen ==
                                                      index,
                                              outerGlowScale:
                                                  outerGlowScaleDesignScreen,
                                              outerGlowOpacity:
                                                  outerGlowOpacityDesignScreen,
                                              onPressStart: () =>
                                                  beginPersonPressDesignScreen(
                                                    index,
                                                  ),
                                              onPressEnd: () =>
                                                  endPersonPressDesignScreen(
                                                    index,
                                                  ),
                                              onTap: () =>
                                                  selectPersonDesignScreen(
                                                    index,
                                                  ),
                                              onDragStart: (position) =>
                                                  startRelationshipDragDesignScreen(
                                                    index,
                                                    position,
                                                  ),
                                              onDragUpdate:
                                                  updateRelationshipDragDesignScreen,
                                              onDragEnd:
                                                  endRelationshipDragDesignScreen,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 49,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FirstLaunchBottomAction(
                          child: selectedPersonDesignScreen != null
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 165,
                                      child: AppButton(
                                        label: 'View Full Profile',
                                        leading: const Icon(
                                          Icons.account_box_outlined,
                                        ),
                                        onPressed: () {
                                          final name =
                                              peopleNetworkPeopleDesignScreen[selectedPersonDesignScreen!]
                                                  .name;
                                          context.go(
                                            '/design/character-profile?person=${Uri.encodeQueryComponent(name)}',
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 165,
                                      child: AppButton(
                                        label: 'Modify Persona',
                                        onPressed: () => context.go(
                                          '/design/character-editor?mode=modify',
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: 165,
                                  child: AppButton(
                                    label:
                                        selectedRelationshipDesignScreen != null
                                        ? 'Modify Relationship'
                                        : 'Create Colleague',
                                    leading:
                                        selectedRelationshipDesignScreen == null
                                        ? const Icon(
                                            Icons.person_add_alt_1_rounded,
                                          )
                                        : null,
                                    onPressed: () {
                                      final relationship =
                                          selectedRelationshipDesignScreen;
                                      if (relationship == null) {
                                        context.go(
                                          '/design/character-editor?mode=create',
                                        );
                                        return;
                                      }
                                      final source =
                                          peopleNetworkPeopleDesignScreen[relationship
                                                  .source]
                                              .name;
                                      final target =
                                          peopleNetworkPeopleDesignScreen[relationship
                                                  .target]
                                              .name;
                                      final pairCase =
                                          source == 'You' || target == 'You'
                                          ? 'modify-self-other'
                                          : 'modify-colleagues';
                                      context.go(
                                        '/design/relationship-editor?case=$pairCase',
                                      );
                                    },
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

class _GlowTunePanel extends StatelessWidget {
  const _GlowTunePanel({
    required this.scale,
    required this.opacity,
    required this.onScaleChanged,
    required this.onOpacityChanged,
  });

  final double scale;
  final double opacity;
  final ValueChanged<double> onScaleChanged;
  final ValueChanged<double> onOpacityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('people-network-glow-tune'),
      width: 176,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: Column(
        children: [
          _GlowTuneRow(
            label: 'Outer Size',
            value: '${scale.toStringAsFixed(2)}×',
            onDecrease: () => onScaleChanged((scale - 0.05).clamp(1.05, 1.8)),
            onIncrease: () => onScaleChanged((scale + 0.05).clamp(1.05, 1.8)),
          ),
          _GlowTuneRow(
            label: 'Outer Opacity',
            value: '${(opacity * 100).round()}%',
            onDecrease: () => onOpacityChanged((opacity - 0.05).clamp(0.1, 1)),
            onIncrease: () => onOpacityChanged((opacity + 0.05).clamp(0.1, 1)),
          ),
        ],
      ),
    );
  }
}

class _GlowTuneRow extends StatelessWidget {
  const _GlowTuneRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final String value;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 19,
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label  $value',
              style: const TextStyle(
                color: Color(0xFF356A84),
                fontSize: 6.8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _GlowTuneButton(icon: Icons.remove_rounded, onPressed: onDecrease),
          const SizedBox(width: 3),
          _GlowTuneButton(icon: Icons.add_rounded, onPressed: onIncrease),
        ],
      ),
    );
  }
}

class _GlowTuneButton extends StatelessWidget {
  const _GlowTuneButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 17,
        height: 15,
        decoration: BoxDecoration(
          color: const Color(0xFFE7F4FF),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: const Color(0xFF65C5ED)),
        ),
        child: Icon(icon, size: 10, color: const Color(0xFF277BAA)),
      ),
    );
  }
}

class _PeopleNetworkGuide extends StatelessWidget {
  const _PeopleNetworkGuide();

  @override
  Widget build(BuildContext context) {
    return const Column(
      key: ValueKey('people-network-guide'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Icon(Icons.diversity_3_rounded, color: Color(0xFF3299D0), size: 55),
        SizedBox(height: 8),
        Text(
          'Your Workplace\nNetwork',
          style: TextStyle(
            color: Color(0xFF174765),
            fontSize: 24,
            height: 1.06,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Tap a character to review the information recorded about them. To inspect a relationship, hold one character for 0.3 seconds, drag onto another, keep still for 0.3 seconds, then release on that character.',
          style: TextStyle(
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

class _PersonaPanel extends StatelessWidget {
  const _PersonaPanel({super.key, required this.person});

  final _NetworkPerson person;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('people-network-persona'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          person.name,
          style: const TextStyle(
            color: Color(0xFF174765),
            fontSize: 22,
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
        const SizedBox(height: 7),
        Row(
          children: [
            SizedBox(
              width: 98,
              height: 112,
              child: _PersonaAvatar(person: person),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 118,
                child: CustomPaint(
                  key: const ValueKey('people-network-hexagon-chart'),
                  painter: _PersonaHexagonPainter(
                    values: person.personaMetrics,
                    color: person.shirtColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (final item in person.personaEntries)
                  _PanelEntry(label: item.$1, value: item.$2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonaAvatar extends StatelessWidget {
  const _PersonaAvatar({required this.person});

  final _NetworkPerson person;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: CustomPaint(
        key: ValueKey('people-network-avatar-${person.name}'),
        painter: DesignAvatarPainter(person.avatar),
      ),
    );
  }
}

class _PersonaHexagonPainter extends CustomPainter {
  const _PersonaHexagonPainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const labels = [
      'Influence',
      'Trust',
      'Access',
      'Stability',
      'Alignment',
      'Risk',
    ];
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.41;
    final gridPaint = Paint()
      ..color = const Color(0xFF9EDCF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (final scale in [0.34, 0.67, 1.0]) {
      canvas.drawPath(_hexagonPath(center, radius * scale), gridPaint);
    }
    for (var index = 0; index < 6; index++) {
      final point = _hexPoint(center, radius, index);
      canvas.drawLine(center, point, gridPaint);
    }

    final dataPath = Path();
    for (var index = 0; index < 6; index++) {
      final value = values[index % values.length].clamp(0.15, 1.0);
      final point = _hexPoint(center, radius * value, index);
      if (index == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color.withValues(alpha: 0.24)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    for (var index = 0; index < 6; index++) {
      final point = _hexPoint(center, radius + 10, index);
      final painter = TextPainter(
        text: TextSpan(
          text: labels[index],
          style: const TextStyle(
            color: Color(0xFF5C8196),
            fontSize: 6,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(
        canvas,
        point - Offset(painter.width / 2, painter.height / 2),
      );
    }
  }

  Path _hexagonPath(Offset center, double radius) {
    final path = Path();
    for (var index = 0; index < 6; index++) {
      final point = _hexPoint(center, radius, index);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  Offset _hexPoint(Offset center, double radius, int index) {
    final angle = -pi / 2 + index * pi / 3;
    return center + Offset(cos(angle), sin(angle)) * radius;
  }

  @override
  bool shouldRepaint(covariant _PersonaHexagonPainter oldDelegate) =>
      values != oldDelegate.values || color != oldDelegate.color;
}

class _RelationshipPanel extends StatelessWidget {
  const _RelationshipPanel({super.key, required this.selection});

  final _RelationshipSelection selection;

  @override
  Widget build(BuildContext context) {
    final source = peopleNetworkPeopleDesignScreen[selection.source];
    final target = peopleNetworkPeopleDesignScreen[selection.target];
    final relation = relationshipForDesignScreen(source.name, target.name);
    return SingleChildScrollView(
      key: const ValueKey('people-network-relationship'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RelationshipAvatar(person: source),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 9),
                child: Icon(
                  Icons.sync_alt_rounded,
                  color: Color(0xFF3299D0),
                  size: 25,
                ),
              ),
              _RelationshipAvatar(person: target),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            '${source.name} ↔ ${target.name}',
            style: const TextStyle(
              color: Color(0xFF174765),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          RelationshipQualityBar(
            score: relation.$4,
            keyPrefix: 'people-network-relationship',
          ),
          const SizedBox(height: 9),
          _PanelEntry(label: 'How They Work Together', value: relation.$1),
          _PanelEntry(label: 'Major Event', value: relation.$2),
          _PanelEntry(label: 'Current Dynamic', value: relation.$3),
        ],
      ),
    );
  }
}

class _RelationshipAvatar extends StatelessWidget {
  const _RelationshipAvatar({required this.person});

  final _NetworkPerson person;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          SizedBox(
            key: ValueKey('people-network-relationship-avatar-${person.name}'),
            width: 66,
            height: 66,
            child: CustomPaint(painter: DesignAvatarPainter(person.avatar)),
          ),
          Text(
            person.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF245672),
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelEntry extends StatelessWidget {
  const _PanelEntry({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFF9EDCF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF318DB6),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF345F77),
                fontSize: 9,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovingPerson extends StatelessWidget {
  const _MovingPerson({
    super.key,
    required this.person,
    required this.motion,
    required this.selected,
    required this.connectionSelected,
    required this.outerGlowScale,
    required this.outerGlowOpacity,
    required this.onPressStart,
    required this.onPressEnd,
    required this.onTap,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final _NetworkPerson person;
  final double motion;
  final bool selected;
  final bool connectionSelected;
  final double outerGlowScale;
  final double outerGlowOpacity;
  final VoidCallback onPressStart;
  final VoidCallback onPressEnd;
  final VoidCallback onTap;
  final ValueChanged<Offset> onDragStart;
  final ValueChanged<Offset> onDragUpdate;
  final ValueChanged<Offset> onDragEnd;

  @override
  Widget build(BuildContext context) {
    final stride = sin(motion * pi * 8 + person.phase);
    final idle = sin(motion * pi * 4 + person.phase);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      tween: Tween(end: connectionSelected || selected ? 1 : 0),
      builder: (context, glow, _) => Container(
        key: ValueKey('people-network-person-glow-${person.name}'),
        child: Listener(
          onPointerDown: (_) => onPressStart(),
          onPointerUp: (_) => onPressEnd(),
          onPointerCancel: (_) => onPressEnd(),
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              TapGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                    TapGestureRecognizer.new,
                    (recognizer) => recognizer.onTap = onTap,
                  ),
              LongPressGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                    LongPressGestureRecognizer
                  >(
                    () => LongPressGestureRecognizer(
                      duration: const Duration(milliseconds: 300),
                    ),
                    (recognizer) {
                      recognizer.onLongPressStart = (details) =>
                          onDragStart(details.globalPosition);
                      recognizer.onLongPressMoveUpdate = (details) =>
                          onDragUpdate(details.globalPosition);
                      recognizer.onLongPressEnd = (details) =>
                          onDragEnd(details.globalPosition);
                    },
                  ),
            },
            child: SizedBox(
              width: 70,
              height: 100,
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 68),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF8777E9)
                            : const Color(0xFF8BCFEA),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF245672),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(0, idle.abs() * -2),
                      child: _FrontFacingBody(
                        person: person,
                        stride: stride,
                        idle: idle,
                        glow: glow,
                        outerGlowScale: outerGlowScale,
                        outerGlowOpacity: outerGlowOpacity,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrontFacingBody extends StatelessWidget {
  const _FrontFacingBody({
    required this.person,
    required this.stride,
    required this.idle,
    required this.glow,
    required this.outerGlowScale,
    required this.outerGlowOpacity,
  });

  final _NetworkPerson person;
  final double stride;
  final double idle;
  final double glow;
  final double outerGlowScale;
  final double outerGlowOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            key: ValueKey(
              'people-network-silhouette-glow-${person.name}-${glow > 0 ? 'active' : 'inactive'}',
            ),
            painter: _PersonSilhouetteGlowPainter(
              color: person.shirtColor,
              intensity: glow,
              outerScale: outerGlowScale,
              outerOpacity: outerGlowOpacity,
            ),
          ),
        ),
        Positioned(
          top: 67,
          left: 25,
          child: Transform.rotate(
            angle: stride * 0.2,
            alignment: Alignment.topCenter,
            child: const _Limb(color: Color(0xFF335C75), height: 18),
          ),
        ),
        Positioned(
          top: 67,
          right: 25,
          child: Transform.rotate(
            angle: -stride * 0.2,
            alignment: Alignment.topCenter,
            child: const _Limb(color: Color(0xFF335C75), height: 18),
          ),
        ),
        Positioned(
          top: 39,
          child: Container(
            width: 34,
            height: 32,
            decoration: BoxDecoration(
              color: person.shirtColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
          ),
        ),
        Positioned(
          top: 42,
          left: 14,
          child: Transform.rotate(
            angle: -stride * 0.22,
            alignment: Alignment.topCenter,
            child: _Limb(color: person.skinColor, height: 25),
          ),
        ),
        Positioned(
          top: 42,
          right: 14,
          child: Transform.rotate(
            angle: stride * 0.22,
            alignment: Alignment.topCenter,
            child: _Limb(color: person.skinColor, height: 25),
          ),
        ),
        Positioned(
          top: 0,
          child: Transform.rotate(
            angle: idle * 0.035,
            child: SizedBox(
              key: ValueKey('people-network-walking-avatar-${person.name}'),
              width: 46,
              height: 52,
              child: CustomPaint(
                painter: DesignAvatarHeadPainter(person.avatar),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PersonSilhouetteGlowPainter extends CustomPainter {
  const _PersonSilhouetteGlowPainter({
    required this.color,
    required this.intensity,
    required this.outerScale,
    required this.outerOpacity,
  });

  final Color color;
  final double intensity;
  final double outerScale;
  final double outerOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;
    final centerX = size.width / 2;
    final paleColor = Color.lerp(color, Colors.white, 0.48)!;
    _drawGlowCircle(
      canvas,
      center: Offset(centerX, 25),
      shapeRadius: 23,
      paleColor: paleColor,
    );
    _drawBodyGlow(canvas, center: Offset(centerX, 57), paleColor: paleColor);
  }

  void _drawGlowCircle(
    Canvas canvas, {
    required Offset center,
    required double shapeRadius,
    required Color paleColor,
  }) {
    final innerRadius = shapeRadius * 1.15;
    final outerRadius = innerRadius * outerScale;
    final area = Rect.fromCircle(center: center, radius: outerRadius);
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            paleColor.withValues(alpha: outerOpacity * intensity),
            paleColor.withValues(alpha: outerOpacity * intensity),
            paleColor.withValues(alpha: 0),
          ],
          stops: [0, innerRadius / outerRadius, 1],
        ).createShader(area),
    );
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = color.withValues(alpha: 0.5 * intensity),
    );
  }

  void _drawBodyGlow(
    Canvas canvas, {
    required Offset center,
    required Color paleColor,
  }) {
    const bodyWidth = 34.0;
    const bodyHeight = 32.0;
    const bodyRadius = 14.0;
    const innerScale = 1.15;
    final outerBodyScale = innerScale * outerScale;

    for (var layer = 0; layer <= 14; layer++) {
      final progress = layer / 14;
      final layerScale =
          outerBodyScale - (outerBodyScale - innerScale) * progress;
      final layerRect = Rect.fromCenter(
        center: center,
        width: bodyWidth * layerScale,
        height: bodyHeight * layerScale,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          layerRect,
          Radius.circular(bodyRadius * layerScale),
        ),
        Paint()
          ..color = paleColor.withValues(
            alpha: outerOpacity * intensity * pow(progress, 1.7).toDouble(),
          ),
      );
    }

    final innerRect = Rect.fromCenter(
      center: center,
      width: bodyWidth * innerScale,
      height: bodyHeight * innerScale,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        innerRect,
        const Radius.circular(bodyRadius * innerScale),
      ),
      Paint()..color = color.withValues(alpha: 0.5 * intensity),
    );
  }

  @override
  bool shouldRepaint(covariant _PersonSilhouetteGlowPainter oldDelegate) =>
      color != oldDelegate.color ||
      intensity != oldDelegate.intensity ||
      outerScale != oldDelegate.outerScale ||
      outerOpacity != oldDelegate.outerOpacity;
}

class _Limb extends StatelessWidget {
  const _Limb({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SceneFloorPainter extends CustomPainter {
  const _SceneFloorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFBCE7F8)
      ..strokeWidth = 1;
    for (var x = 20.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (var y = 20.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RelationshipDragPainter extends CustomPainter {
  const _RelationshipDragPainter({
    required this.from,
    required this.to,
    required this.ready,
    required this.pulse,
  });

  final Offset from;
  final Offset to;
  final bool ready;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (ready) {
      final pulseStrength = 0.5 + sin(pulse * pi * 4) * 0.5;
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = const Color(
            0xFF65C5ED,
          ).withValues(alpha: 0.22 + pulseStrength * 0.34)
          ..strokeWidth = 4 + pulseStrength * 2
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            2 + pulseStrength * 2,
          ),
      );
    }
    canvas.drawLine(
      from,
      to,
      Paint()
        ..color = ready ? const Color(0xFF238BC5) : const Color(0xFFA9DFF4)
        ..strokeWidth = ready ? 2.5 : 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RelationshipDragPainter oldDelegate) =>
      from != oldDelegate.from ||
      to != oldDelegate.to ||
      ready != oldDelegate.ready ||
      pulse != oldDelegate.pulse;
}

List<Offset> collisionSafePeoplePositionsDesignScreen(
  Size size,
  double motion,
) {
  final positions = <Offset>[];
  for (var index = 0; index < peopleNetworkPeopleDesignScreen.length; index++) {
    final person = peopleNetworkPeopleDesignScreen[index];
    final angle = motion * 2 * pi + person.phase;
    positions.add(
      Offset(
        person.position.dx * size.width + cos(angle) * 10,
        person.position.dy * size.height + sin(angle) * 7,
      ),
    );
  }

  const collisionDistance = 86.0;
  for (var pass = 0; pass < 4; pass++) {
    for (var first = 0; first < positions.length; first++) {
      for (var second = first + 1; second < positions.length; second++) {
        var delta = positions[second] - positions[first];
        var distance = delta.distance;
        if (distance >= collisionDistance) continue;
        if (distance < 0.01) {
          delta = const Offset(1, 0);
          distance = 1;
        }
        final correction =
            delta / distance * ((collisionDistance - distance) / 2);
        positions[first] -= correction;
        positions[second] += correction;
      }
    }
  }

  for (var index = 0; index < positions.length; index++) {
    var position = Offset(
      positions[index].dx.clamp(40.0, max(40.0, size.width - 40)),
      positions[index].dy.clamp(52.0, max(52.0, size.height - 52)),
    );
    if (position.dx > size.width - 220 && position.dy > size.height - 110) {
      position = Offset(position.dx, max(52.0, size.height - 110));
    }
    positions[index] = position;
  }
  return positions;
}

class _RelationshipSelection {
  const _RelationshipSelection(this.source, this.target);

  final int source;
  final int target;

  @override
  bool operator ==(Object other) =>
      other is _RelationshipSelection &&
      source == other.source &&
      target == other.target;

  @override
  int get hashCode => Object.hash(source, target);
}

class _NetworkPerson {
  const _NetworkPerson({
    required this.name,
    required this.role,
    required this.personaEntries,
    required this.personaMetrics,
    required this.position,
    required this.phase,
    required this.fallbackAvatar,
  });

  final String name;
  final String role;
  final List<(String, String)> personaEntries;
  final List<double> personaMetrics;
  final Offset position;
  final double phase;
  final DesignAvatarData fallbackAvatar;

  DesignAvatarData get avatar => switch (name) {
    'You' => DesignAvatarDraft.self,
    'Alex' => DesignAvatarDraft.firstColleague,
    _ => fallbackAvatar,
  };

  Color get skinColor => avatar.skinColor;
  Color get shirtColor => avatar.outfitColor;
}

const peopleNetworkPeopleDesignScreen = <_NetworkPerson>[
  _NetworkPerson(
    name: 'You',
    role: 'Product Analyst',
    personaEntries: [
      ('Responsibilities', 'Analysis and cross-team coordination'),
      ('Tenure', 'Two years in this role'),
      ('Goals', 'Protect credibility and deliver the current project'),
      ('Limits', 'Limited decision authority; depends on other teams'),
    ],
    personaMetrics: [0.45, 0.72, 0.5, 0.68, 0.8, 0.34],
    position: Offset(0.17, 0.33),
    phase: 0.2,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFF3BE96),
      hairColor: Color(0xFF263D4D),
      outfitColor: Color(0xFF3299D0),
      face: 0,
      hair: 0,
      eyes: 0,
      mouth: 0,
    ),
  ),
  _NetworkPerson(
    name: 'Alex',
    role: 'Project Manager',
    personaEntries: [
      ('Relation to You', 'Frequent collaborator in a different team'),
      ('Observed Style', 'Direct, deadline-focused, and documents decisions'),
      ('Major Events', 'Disagreement over ownership of a missed deadline'),
      ('Current Relationship', 'Tense but workable; cooperation continues'),
    ],
    personaMetrics: [0.68, 0.38, 0.72, 0.42, 0.48, 0.66],
    position: Offset(0.42, 0.67),
    phase: 1.5,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFD99568),
      hairColor: Color(0xFF6A4435),
      outfitColor: Color(0xFF685BC7),
      face: 2,
      hair: 1,
      eyes: 1,
      mouth: 1,
    ),
  ),
  _NetworkPerson(
    name: 'Maya',
    role: 'Operations Lead',
    personaEntries: [
      ('Relation to You', 'Provides operational approval'),
      ('Observed Style', 'Calm in meetings and cautious about commitments'),
      ('Major Events', 'Supported your revised delivery plan'),
      ('Current Relationship', 'Constructive with moderate trust'),
    ],
    personaMetrics: [0.76, 0.65, 0.82, 0.74, 0.7, 0.36],
    position: Offset(0.67, 0.3),
    phase: 2.8,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFAE6E48),
      hairColor: Color(0xFF342B2B),
      outfitColor: Color(0xFF4DA988),
      face: 1,
      hair: 5,
      eyes: 2,
      mouth: 0,
    ),
  ),
  _NetworkPerson(
    name: 'Jordan',
    role: 'Finance Partner',
    personaEntries: [
      ('Relation to You', 'Reviews budgets affecting your work'),
      ('Observed Style', 'Evidence-focused and formal'),
      ('Major Events', 'Questioned the latest cost estimate'),
      ('Current Relationship', 'Neutral and still developing'),
    ],
    personaMetrics: [0.62, 0.5, 0.7, 0.78, 0.55, 0.4],
    position: Offset(0.84, 0.67),
    phase: 4.2,
    fallbackAvatar: DesignAvatarData(
      skinColor: Color(0xFFFBD0AF),
      hairColor: Color(0xFF87563A),
      outfitColor: Color(0xFFD39B42),
      face: 3,
      hair: 1,
      eyes: 0,
      mouth: 2,
      accessory: 1,
    ),
  ),
];

(String, String, String, double) relationshipForDesignScreen(
  String source,
  String target,
) {
  final names = {source, target};
  if (names.contains('You') && names.contains('Alex')) {
    return (
      'Frequent collaborators who jointly deliver the same project',
      'Disagreed over ownership of a missed deadline; the director was copied',
      'Tense but workable, with formal communication and limited trust',
      0.34,
    );
  }
  if (names.contains('Maya') && names.contains('Jordan')) {
    return (
      'Operations and Finance coordinate approvals',
      'They negotiated the latest cost-reduction target',
      'Professional cooperation with occasional priority conflict',
      0.64,
    );
  }
  return (
    'Cross-functional colleagues with periodic work dependency',
    'Both attended the latest planning discussion',
    'Neutral relationship; evidence is still limited',
    0.5,
  );
}
