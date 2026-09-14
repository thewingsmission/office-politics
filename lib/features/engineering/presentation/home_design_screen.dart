import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_avatar.dart';
import 'design_back_button.dart';
import 'people_network_design_screen.dart';

class HomeDesignScreen extends StatefulWidget {
  const HomeDesignScreen({super.key});

  @override
  State<HomeDesignScreen> createState() => _HomeDesignScreenState();
}

class _HomeDesignScreenState extends State<HomeDesignScreen>
    with TickerProviderStateMixin {
  late final AnimationController panelAnimationDesignScreen;
  late final AnimationController officeMotionDesignScreen;
  late final Timer personaRotationTimerDesignScreen;
  final math.Random personaRandomDesignScreen = math.Random();

  Offset userPositionDesignScreen = const Offset(0.52, 0.56);
  Offset mapPanOffsetDesignScreen = Offset.zero;
  Offset? lastMapDragPointDesignScreen;
  bool movingUserDesignScreen = false;
  int selectedPersonDesignScreen = 0;

  @override
  void initState() {
    super.initState();
    panelAnimationDesignScreen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    officeMotionDesignScreen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    selectedPersonDesignScreen = personaRandomDesignScreen.nextInt(
      officePeopleDesignScreen.length,
    );
    personaRotationTimerDesignScreen = Timer.periodic(
      const Duration(seconds: 5),
      (_) => rotatePersonaDesignScreen(),
    );
  }

  @override
  void dispose() {
    personaRotationTimerDesignScreen.cancel();
    panelAnimationDesignScreen.dispose();
    officeMotionDesignScreen.dispose();
    super.dispose();
  }

  void rotatePersonaDesignScreen() {
    if (!mounted || officePeopleDesignScreen.length < 2) return;
    var next = personaRandomDesignScreen.nextInt(
      officePeopleDesignScreen.length - 1,
    );
    if (next >= selectedPersonDesignScreen) next++;
    setState(() => selectedPersonDesignScreen = next);
  }

  void beginOfficeMoveDesignScreen(Offset localPosition) {
    movingUserDesignScreen = true;
    lastMapDragPointDesignScreen = localPosition;
    panelAnimationDesignScreen.forward();
  }

  void updateUserPositionDesignScreen(Offset localPosition, Size screenSize) {
    final previous = lastMapDragPointDesignScreen;
    if (previous == null) return;
    final delta = localPosition - previous;
    final horizontalLimit = screenSize.width * 0.14;
    final verticalLimit = screenSize.height * 0.12;
    setState(() {
      lastMapDragPointDesignScreen = localPosition;
      mapPanOffsetDesignScreen = Offset(
        (mapPanOffsetDesignScreen.dx + delta.dx).clamp(
          -horizontalLimit,
          horizontalLimit,
        ),
        (mapPanOffsetDesignScreen.dy + delta.dy).clamp(
          -verticalLimit,
          verticalLimit,
        ),
      );
    });
  }

  void finishOfficeMoveDesignScreen() {
    if (!movingUserDesignScreen) return;
    movingUserDesignScreen = false;
    lastMapDragPointDesignScreen = null;
    panelAnimationDesignScreen.reverse();
  }

  void showPersonaDesignScreen(int index) {
    final person = officePeopleDesignScreen[index];
    setState(() => selectedPersonDesignScreen = index);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          key: const ValueKey('home-persona-popup'),
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 380),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3CB9E7), Color(0xFF778FE8)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: CustomPaint(
                        painter: DesignAvatarPainter(person.avatar),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name,
                            style: const TextStyle(
                              color: Color(0xFF244F63),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${person.role} · ${person.team}',
                            style: const TextStyle(
                              color: Color(0xFF688998),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF4A788D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _PersonaSummaryRow(
                          icon: Icons.psychology_alt_outlined,
                          label: 'Quick persona',
                          value: person.persona,
                        ),
                        const SizedBox(height: 8),
                        _PersonaSummaryRow(
                          icon: Icons.handshake_outlined,
                          label: 'Relationship with you',
                          value: person.relationship,
                        ),
                        const SizedBox(height: 8),
                        _PersonaSummaryRow(
                          icon: Icons.history_rounded,
                          label: 'Major linked event',
                          value: person.majorEvent,
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(
                              Icons.fact_check_outlined,
                              color: Color(0xFF338DAD),
                              size: 15,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Summary based on 4 linked events · 72% confidence',
                                style: TextStyle(
                                  color: Color(0xFF668998),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Close',
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: AppButton(
                        label: 'Open Full Profile',
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          context.go('/design/office-character-panel');
                        },
                      ),
                    ),
                  ],
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              key: const ValueKey('home-infinite-office-floor'),
              painter: _InfiniteOfficeFloorPainter(
                offset: mapPanOffsetDesignScreen,
                safePadding: MediaQuery.paddingOf(context),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                final leftWidth = math.min(232.0, size.width * 0.25);
                final rightWidth = math.min(188.0, size.width * 0.20);
                final isCompact = size.width < 780;
                final officeCanvasPadding = Offset(
                  size.width * 0.20,
                  size.height * 0.20,
                );

                return Listener(
                  key: const ValueKey('home-office-interaction'),
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (event) {
                    final point = event.localPosition;
                    final isOfficeArea =
                        point.dx > leftWidth &&
                        point.dx < size.width - rightWidth &&
                        point.dy > 42 &&
                        point.dy < size.height - 64;
                    if (!isOfficeArea) return;
                    beginOfficeMoveDesignScreen(point);
                  },
                  onPointerMove: (event) {
                    if (!movingUserDesignScreen) return;
                    updateUserPositionDesignScreen(event.localPosition, size);
                  },
                  onPointerUp: (_) => finishOfficeMoveDesignScreen(),
                  onPointerCancel: (_) => finishOfficeMoveDesignScreen(),
                  child: Stack(
                    children: [
                      Positioned(
                        key: const ValueKey('home-office-canvas'),
                        left:
                            -officeCanvasPadding.dx +
                            mapPanOffsetDesignScreen.dx,
                        top:
                            -officeCanvasPadding.dy +
                            mapPanOffsetDesignScreen.dy,
                        width: size.width + officeCanvasPadding.dx * 2,
                        height: size.height + officeCanvasPadding.dy * 2,
                        child: AnimatedBuilder(
                          animation: officeMotionDesignScreen,
                          builder: (context, _) => _IsometricOffice(
                            motion: officeMotionDesignScreen.value,
                            userPosition: userPositionDesignScreen,
                            canvasPadding: officeCanvasPadding,
                            onPersonSelected: showPersonaDesignScreen,
                          ),
                        ),
                      ),
                      Positioned(
                        key: const ValueKey('home-left-panel'),
                        left: 12,
                        top: 43,
                        bottom: 66,
                        width: leftWidth,
                        child: AnimatedBuilder(
                          animation: panelAnimationDesignScreen,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(
                              -(leftWidth + 20) *
                                  panelAnimationDesignScreen.value,
                              0,
                            ),
                            child: child,
                          ),
                          child: _UserPoliticsPanel(compact: isCompact),
                        ),
                      ),
                      Positioned(
                        key: const ValueKey('home-right-panel'),
                        right: 12,
                        top: 43,
                        bottom: 66,
                        width: rightWidth,
                        child: AnimatedBuilder(
                          animation: panelAnimationDesignScreen,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(
                              (rightWidth + 20) *
                                  panelAnimationDesignScreen.value,
                              0,
                            ),
                            child: child,
                          ),
                          child: _TacticalPanel(
                            outerKey: const ValueKey(
                              'home-persona-panel-outline',
                            ),
                            outlineColor:
                                officePeopleDesignScreen[selectedPersonDesignScreen]
                                    .shirtColor,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 800),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: _RelationshipPanel(
                                key: ValueKey(
                                  'home-persona-slide-${officePeopleDesignScreen[selectedPersonDesignScreen].name}',
                                ),
                                compact: isCompact,
                                person:
                                    officePeopleDesignScreen[selectedPersonDesignScreen],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        key: const ValueKey('home-top-panel'),
                        left: 12,
                        right: 12,
                        top: 3,
                        height: 36,
                        child: AnimatedBuilder(
                          animation: panelAnimationDesignScreen,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(
                              0,
                              -50 * panelAnimationDesignScreen.value,
                            ),
                            child: child,
                          ),
                          child: Align(
                            key: const ValueKey('home-top-control'),
                            alignment: Alignment.centerLeft,
                            child: DesignBackButton(
                              onPressed: () => context.go('/engineering'),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 0,
                        height: 48,
                        child: AnimatedBuilder(
                          animation: panelAnimationDesignScreen,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(
                              0,
                              66 * panelAnimationDesignScreen.value,
                            ),
                            child: child,
                          ),
                          child: const _BottomNavigation(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonaSummaryRow extends StatelessWidget {
  const _PersonaSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F4FF),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF278EB2), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF487286),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF2C566A),
                    fontSize: 10,
                    height: 1.3,
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

class _InfiniteOfficeFloorPainter extends CustomPainter {
  const _InfiniteOfficeFloorPainter({
    required this.offset,
    required this.safePadding,
  });

  final Offset offset;
  final EdgeInsets safePadding;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEEF9FF),
    );

    final viewportWidth = size.width - safePadding.horizontal;
    final viewportHeight = size.height - safePadding.vertical;
    final origin = Offset(
      safePadding.left + viewportWidth * 0.5 + offset.dx,
      safePadding.top - viewportHeight * 0.1665 + offset.dy,
    );
    final alongX = Offset(viewportWidth * 0.06435, viewportHeight * 0.06665);
    final alongY = Offset(-alongX.dx, alongX.dy);
    final step = math.max(1.0, math.min(alongX.distance, alongY.distance));
    final lineCount = ((size.width + size.height) / step).ceil() + 10;
    final extension = lineCount * 2.0;
    final gridPaint = Paint()
      ..color = const Color(0x403299D0)
      ..strokeWidth = 1;

    for (var index = -lineCount; index <= lineCount; index++) {
      final lineOffset = index.toDouble();
      canvas
        ..drawLine(
          origin + alongX * lineOffset - alongY * extension,
          origin + alongX * lineOffset + alongY * extension,
          gridPaint,
        )
        ..drawLine(
          origin + alongY * lineOffset - alongX * extension,
          origin + alongY * lineOffset + alongX * extension,
          gridPaint,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _InfiniteOfficeFloorPainter oldDelegate) =>
      oldDelegate.offset != offset || oldDelegate.safePadding != safePadding;
}

class _TacticalPanel extends StatelessWidget {
  const _TacticalPanel({required this.child, this.outlineColor, this.outerKey});

  final Widget child;
  final Color? outlineColor;
  final Key? outerKey;

  @override
  Widget build(BuildContext context) {
    final outline = outlineColor;
    return AnimatedContainer(
      key: outerKey,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: outline == null
              ? const [Color(0xFF3CB9E7), Color(0xFF778FE8)]
              : [Color.lerp(Colors.white, outline, 0.48)!, outline],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (outline ?? const Color(0xFF3299D0)).withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFAFFFFFF),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: outline?.withValues(alpha: 0.32) ?? const Color(0xFFCFECFA),
          ),
        ),
        child: child,
      ),
    );
  }
}

class _UserPoliticsPanel extends StatelessWidget {
  const _UserPoliticsPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _TacticalPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeading(
            icon: Icons.military_tech_outlined,
            label: 'YOUR LEVEL & METRICS',
          ),
          SizedBox(height: compact ? 6 : 9),
          const Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: Color(0xFFBDE7F2),
                child: Icon(
                  Icons.person_rounded,
                  color: Color(0xFF277E9F),
                  size: 28,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEVEL 7 · STRATEGIST',
                      style: TextStyle(
                        color: Color(0xFF27566B),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '1,240 / 1,500 progress',
                      style: TextStyle(
                        color: Color(0xFF668A9B),
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('POLITICS INTENSITY', style: _panelLabelStyle),
          const SizedBox(height: 4),
          const _PoliticsGauge(value: 0.68, label: '68% · ELEVATED'),
          const SizedBox(height: 9),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: const [
                _UserMetricTile(
                  label: 'Influence',
                  value: 0.61,
                  color: Color(0xFF2C94B9),
                ),
                SizedBox(height: 4),
                _UserMetricTile(
                  label: 'Support Network',
                  value: 0.54,
                  color: Color(0xFF45A58E),
                ),
                SizedBox(height: 4),
                _UserMetricTile(
                  label: 'Credibility',
                  value: 0.76,
                  color: Color(0xFF657FC2),
                ),
                SizedBox(height: 4),
                _UserMetricTile(
                  label: 'Exposure Risk',
                  value: 0.68,
                  color: Color(0xFFE47B6F),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PoliticsGauge extends StatelessWidget {
  const _PoliticsGauge({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: const Color(0xFFDDF5FF),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFE77E72)),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCD665E),
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Text(
          'Based on 8 recorded events · 72% confidence',
          style: TextStyle(
            color: Color(0xFF7895A3),
            fontSize: 7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _UserMetricTile extends StatelessWidget {
  const _UserMetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF587A8A),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(value * 100).round()}',
                style: TextStyle(
                  color: color,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.72),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF258DB4), size: 14),
        const SizedBox(width: 5),
        Expanded(child: Text(label, style: _panelLabelStyle)),
      ],
    );
  }
}

class _RelationshipPanel extends StatelessWidget {
  const _RelationshipPanel({
    super.key,
    required this.compact,
    required this.person,
  });

  final bool compact;
  final NetworkPersonDesignScreen person;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _PanelHeading(icon: Icons.slideshow_rounded, label: 'PERSONA'),
        SizedBox(height: compact ? 4 : 8),
        SizedBox(
          width: compact ? 34 : 50,
          height: compact ? 34 : 50,
          child: CustomPaint(painter: DesignAvatarPainter(person.avatar)),
        ),
        SizedBox(height: compact ? 2 : 5),
        Text(
          '${person.name} · ${person.role}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF2D586C),
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 3 : 6),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 7,
            vertical: compact ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: person.color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: person.color.withValues(alpha: 0.35)),
          ),
          child: Text(
            person.persona,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: person.color,
              fontSize: 7,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: compact ? 2 : 6),
        if (!compact) const Text('RELATIONSHIP RADAR', style: _panelLabelStyle),
        Expanded(
          child: CustomPaint(
            key: const ValueKey('home-persona-hexagon-chart'),
            painter: PersonaHexagonPainterDesignScreen(
              values: person.personaMetrics,
              color: person.shirtColor,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 5),
        _Meter(label: 'Influence', value: person.influence),
        _Meter(label: 'Trust', value: person.trust),
        _Meter(label: 'Political risk', value: person.risk),
      ],
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF94A4B7),
                fontSize: 7,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: const Color(0xFFDDF5FF),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF36A7BD)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatefulWidget {
  const _BottomNavigation();

  @override
  State<_BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<_BottomNavigation> {
  int? pressedIndex;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.groups_2_rounded,
        'People',
        () => context.go('/design/people-network'),
      ),
      (
        Icons.timeline_rounded,
        'Events',
        () => context.go('/design/event-timeline'),
      ),
      (Icons.map_rounded, 'Map', () => context.go('/design/office-map-list')),
      (
        Icons.psychology_alt_rounded,
        'Advice',
        () => context.go('/design/advice-input'),
      ),
      (
        Icons.sports_esports_rounded,
        'Arcade',
        () => context.go('/design/arcade'),
      ),
      (
        Icons.account_circle_rounded,
        'Profile',
        () => context.go('/design/account'),
      ),
      (Icons.more_horiz_rounded, 'More', () {}),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        const adviceExtraWidth = 18.0;
        final normalWidth = math.min(
          104.0,
          (constraints.maxWidth - gap * 6 - adviceExtraWidth) / 7,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final entry in items.indexed) ...[
              if (entry.$1 > 0) const SizedBox(width: gap),
              SizedBox(
                width:
                    normalWidth +
                    (entry.$2.$2 == 'Advice' ? adviceExtraWidth : 0),
                child: AnimatedScale(
                  key: ValueKey('home-nav-scale-${entry.$2.$2.toLowerCase()}'),
                  scale: pressedIndex == null
                      ? 1
                      : pressedIndex == entry.$1
                      ? entry.$2.$2 == 'Advice'
                            ? 1.10
                            : 1.12
                      : 0.88,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: _NavItem(
                    entry.$2.$1,
                    entry.$2.$2,
                    onTap: entry.$2.$3,
                    onPressedChanged: (pressed) {
                      if (!mounted) return;
                      setState(() {
                        pressedIndex = pressed ? entry.$1 : null;
                      });
                    },
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _NavItem extends StatefulWidget {
  const _NavItem(
    this.icon,
    this.label, {
    required this.onTap,
    required this.onPressedChanged,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ValueChanged<bool> onPressedChanged;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    const outline = LinearGradient(
      colors: [Color(0xFF3DB9EE), Color(0xFF719CF4), Color(0xFFA386F5)],
    );
    return SizedBox(
      height: 38,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey('home-nav-${widget.label.toLowerCase()}'),
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            setState(() => pressed = value);
            widget.onPressedChanged(value);
          },
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              const Positioned.fill(
                top: 4,
                left: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: outline,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
              Positioned.fill(
                right: 4,
                bottom: 4,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    gradient: outline,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: pressed ? const Color(0xFFD2F2FF) : Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: const Color(0xFF276F9E),
                          size: 15,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: const Color(0xFF276F9E),
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ],
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

class _IsometricOffice extends StatelessWidget {
  const _IsometricOffice({
    required this.motion,
    required this.userPosition,
    required this.canvasPadding,
    required this.onPersonSelected,
  });

  final double motion;
  final Offset userPosition;
  final Offset canvasPadding;
  final ValueChanged<int> onPersonSelected;

  Offset _project(Offset point, Size size) {
    final viewport = Size(
      size.width - canvasPadding.dx * 2,
      size.height - canvasPadding.dy * 2,
    );
    return canvasPadding +
        Offset(
          viewport.width * 0.50 + (point.dx - point.dy) * viewport.width * 0.39,
          viewport.height * 0.09 +
              (point.dx + point.dy) * viewport.height * 0.405,
        );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final userPoint = _project(userPosition, size);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _OfficeMapPainter(
                  userPosition: userPosition,
                  canvasPadding: canvasPadding,
                ),
              ),
            ),
            for (final entry in officePeopleDesignScreen.indexed)
              Positioned(
                left:
                    _project(entry.$2.position, size).dx -
                    35 +
                    math.sin((motion + entry.$2.phase) * math.pi * 2) * 3,
                top:
                    _project(entry.$2.position, size).dy -
                    50 +
                    math.cos((motion + entry.$2.phase) * math.pi * 2) * 2,
                child: NetworkMovingPersonDesignScreen(
                  person: entry.$2,
                  motion: motion,
                  selected: false,
                  connectionSelected: false,
                  headInnerGlowScale: 1.15,
                  headOuterGlowScale: 1.25,
                  headOuterGlowOpacity: 0.55,
                  bodyInnerGlowScale: 1.15,
                  bodyOuterGlowScale: 1.25,
                  bodyOuterGlowOpacity: 0.55,
                  onPressStart: () {},
                  onPressEnd: () {},
                  onTap: () => onPersonSelected(entry.$1),
                  onDragStart: (_) {},
                  onDragUpdate: (_) {},
                  onDragEnd: () {},
                ),
              ),
            Positioned(
              left: userPoint.dx - 35,
              top: userPoint.dy - 50,
              child: NetworkMovingPersonDesignScreen(
                person: peopleNetworkPeopleDesignScreen.first,
                motion: motion,
                selected: false,
                connectionSelected: false,
                headInnerGlowScale: 1.15,
                headOuterGlowScale: 1.25,
                headOuterGlowOpacity: 0.55,
                bodyInnerGlowScale: 1.15,
                bodyOuterGlowScale: 1.25,
                bodyOuterGlowOpacity: 0.55,
                onPressStart: () {},
                onPressEnd: () {},
                onTap: () {},
                onDragStart: (_) {},
                onDragUpdate: (_) {},
                onDragEnd: () {},
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfficeMapPainter extends CustomPainter {
  const _OfficeMapPainter({
    required this.userPosition,
    required this.canvasPadding,
  });

  final Offset userPosition;
  final Offset canvasPadding;

  Offset project(Offset point, Size size) {
    final viewport = Size(
      size.width - canvasPadding.dx * 2,
      size.height - canvasPadding.dy * 2,
    );
    return canvasPadding +
        Offset(
          viewport.width * 0.50 + (point.dx - point.dy) * viewport.width * 0.39,
          viewport.height * 0.09 +
              (point.dx + point.dy) * viewport.height * 0.405,
        );
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawWallShape(
      canvas,
      size,
      Offset.zero,
      const Offset(1, 0),
      height: 18,
      thickness: 5,
    );
    _drawWallShape(
      canvas,
      size,
      Offset.zero,
      const Offset(0, 1),
      height: 18,
      thickness: 5,
    );
    _drawWallShape(
      canvas,
      size,
      const Offset(1, 0),
      const Offset(1, 1),
      height: 8,
      thickness: 5,
    );
    _drawWallShape(
      canvas,
      size,
      const Offset(0, 1),
      const Offset(1, 1),
      height: 8,
      thickness: 5,
    );

    for (final room in <Rect>[
      const Rect.fromLTWH(0.04, 0.04, 0.38, 0.36),
      const Rect.fromLTWH(0.58, 0.05, 0.37, 0.34),
      const Rect.fromLTWH(0.05, 0.56, 0.34, 0.38),
      const Rect.fromLTWH(0.58, 0.57, 0.36, 0.36),
    ]) {
      _drawWallShape(
        canvas,
        size,
        room.topLeft,
        room.topRight,
        height: 10,
        thickness: 3,
      );
      _drawWallShape(
        canvas,
        size,
        room.topLeft,
        room.bottomLeft,
        height: 10,
        thickness: 3,
      );
      _drawWallShape(
        canvas,
        size,
        room.topRight,
        room.bottomRight,
        height: 6,
        thickness: 3,
      );
      _drawWallShape(
        canvas,
        size,
        room.bottomLeft,
        room.bottomRight,
        height: 6,
        thickness: 3,
      );
    }

    for (final segment in <(Offset, Offset)>[
      (const Offset(0.42, 0.04), const Offset(0.42, 0.40)),
      (const Offset(0.58, 0.05), const Offset(0.58, 0.39)),
      (const Offset(0.39, 0.56), const Offset(0.39, 0.94)),
      (const Offset(0.58, 0.57), const Offset(0.58, 0.93)),
      (const Offset(0.42, 0.40), const Offset(0.58, 0.40)),
    ]) {
      _drawWallShape(
        canvas,
        size,
        segment.$1,
        segment.$2,
        height: 9,
        thickness: 3,
      );
    }

    for (final desk in <Offset>[
      const Offset(0.18, 0.18),
      const Offset(0.68, 0.17),
      const Offset(0.18, 0.68),
      const Offset(0.67, 0.68),
      const Offset(0.45, 0.47),
    ]) {
      final center = project(desk, size);
      final deskPath = Path()
        ..moveTo(center.dx, center.dy - 9)
        ..lineTo(center.dx + 22, center.dy)
        ..lineTo(center.dx, center.dy + 9)
        ..lineTo(center.dx - 22, center.dy)
        ..close();
      canvas.drawPath(deskPath, Paint()..color = const Color(0xFFC9E9F8));
      canvas.drawPath(
        deskPath,
        Paint()
          ..color = const Color(0xFF778FE8)
          ..style = PaintingStyle.stroke,
      );

      final chair = center + const Offset(0, 15);
      canvas
        ..drawCircle(chair, 6, Paint()..color = const Color(0xFF806DE2))
        ..drawCircle(chair, 3, Paint()..color = const Color(0xFFEAE5FF))
        ..drawLine(
          center + const Offset(-7, -2),
          center + const Offset(7, 3),
          Paint()
            ..color = const Color(0xFF3299D0)
            ..strokeWidth = 3,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _OfficeMapPainter oldDelegate) {
    return oldDelegate.userPosition != userPosition ||
        oldDelegate.canvasPadding != canvasPadding;
  }

  void _drawWallShape(
    Canvas canvas,
    Size size,
    Offset start,
    Offset end, {
    required double height,
    required double thickness,
  }) {
    final baseStart = project(start, size);
    final baseEnd = project(end, size);
    final direction = baseEnd - baseStart;
    final length = direction.distance;
    if (length == 0) return;

    final normal =
        Offset(-direction.dy / length, direction.dx / length) * thickness;
    final rise = Offset(0, -height);

    final frontFace = Path()
      ..moveTo(baseStart.dx, baseStart.dy)
      ..lineTo(baseEnd.dx, baseEnd.dy)
      ..lineTo((baseEnd + rise).dx, (baseEnd + rise).dy)
      ..lineTo((baseStart + rise).dx, (baseStart + rise).dy)
      ..close();
    canvas.drawPath(frontFace, Paint()..color = const Color(0xFF65A9D6));

    final topFace = Path()
      ..moveTo((baseStart + rise).dx, (baseStart + rise).dy)
      ..lineTo((baseEnd + rise).dx, (baseEnd + rise).dy)
      ..lineTo((baseEnd + rise + normal).dx, (baseEnd + rise + normal).dy)
      ..lineTo((baseStart + rise + normal).dx, (baseStart + rise + normal).dy)
      ..close();
    canvas.drawPath(topFace, Paint()..color = const Color(0xFFEAE5FF));

    final endCap = Path()
      ..moveTo(baseEnd.dx, baseEnd.dy)
      ..lineTo((baseEnd + rise).dx, (baseEnd + rise).dy)
      ..lineTo((baseEnd + rise + normal).dx, (baseEnd + rise + normal).dy)
      ..lineTo((baseEnd + normal).dx, (baseEnd + normal).dy)
      ..close();
    canvas.drawPath(endCap, Paint()..color = const Color(0xFF778FE8));
  }
}

final officePeopleDesignScreen = peopleNetworkPeopleDesignScreen
    .skip(1)
    .toList(growable: false);

const _panelLabelStyle = TextStyle(
  color: Color(0xFF365F72),
  fontSize: 8,
  fontWeight: FontWeight.w900,
  letterSpacing: 0.25,
);
