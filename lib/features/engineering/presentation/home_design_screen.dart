import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'design_avatar.dart';
import 'design_back_button.dart';

class HomeDesignScreen extends StatefulWidget {
  const HomeDesignScreen({super.key});

  @override
  State<HomeDesignScreen> createState() => _HomeDesignScreenState();
}

class _HomeDesignScreenState extends State<HomeDesignScreen>
    with TickerProviderStateMixin {
  late final AnimationController panelAnimationDesignScreen;
  late final AnimationController officeMotionDesignScreen;

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
  }

  @override
  void dispose() {
    panelAnimationDesignScreen.dispose();
    officeMotionDesignScreen.dispose();
    super.dispose();
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
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: person.color.withValues(alpha: 0.18),
                      child: Icon(
                        Icons.person_rounded,
                        color: person.color,
                        size: 34,
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final leftWidth = math.min(232.0, size.width * 0.25);
            final rightWidth = math.min(188.0, size.width * 0.20);
            final isCompact = size.width < 780;

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
                  const Positioned.fill(child: _TacticalBackground()),
                  Positioned(
                    left:
                        (size.width - size.width * 1.65) / 2 +
                        mapPanOffsetDesignScreen.dx,
                    top:
                        (size.height - size.height * 1.55) / 2 +
                        mapPanOffsetDesignScreen.dy,
                    width: size.width * 1.65,
                    height: size.height * 1.55,
                    child: AnimatedBuilder(
                      animation: officeMotionDesignScreen,
                      builder: (context, _) => _IsometricOffice(
                        motion: officeMotionDesignScreen.value,
                        userPosition: userPositionDesignScreen,
                        selectedPerson: selectedPersonDesignScreen,
                        onPersonSelected: showPersonaDesignScreen,
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
                      child: _TopBar(onBack: () => context.go('/engineering')),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 48,
                    bottom: 66,
                    width: leftWidth,
                    child: AnimatedBuilder(
                      animation: panelAnimationDesignScreen,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          -(leftWidth + 20) * panelAnimationDesignScreen.value,
                          0,
                        ),
                        child: child,
                      ),
                      child: _UserPoliticsPanel(compact: isCompact),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 48,
                    bottom: 66,
                    width: rightWidth,
                    child: AnimatedBuilder(
                      animation: panelAnimationDesignScreen,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          (rightWidth + 20) * panelAnimationDesignScreen.value,
                          0,
                        ),
                        child: child,
                      ),
                      child: _RelationshipPanel(
                        compact: isCompact,
                        person:
                            officePeopleDesignScreen[selectedPersonDesignScreen],
                      ),
                    ),
                  ),
                  if (!isCompact)
                    Positioned(
                      left: size.width * 0.36,
                      right: size.width * 0.31,
                      bottom: 57,
                      height: 68,
                      child: AnimatedBuilder(
                        animation: panelAnimationDesignScreen,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            0,
                            95 * panelAnimationDesignScreen.value,
                          ),
                          child: child,
                        ),
                        child: const _ArcadeLauncher(),
                      ),
                    ),
                  Positioned(
                    left: isCompact ? 70 : size.width * 0.23,
                    right: isCompact ? 70 : size.width * 0.23,
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

class _TacticalBackground extends StatelessWidget {
  const _TacticalBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFDDF5FF), Color(0xFFF4FAFF), Color(0xFFEAE5FF)],
        ),
      ),
      child: CustomPaint(painter: _CircuitPainter()),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DesignBackButton(onPressed: onBack),
        const Expanded(
          child: Text(
            'Office Politics · Tactical Dashboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF274E62),
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE7F4FF),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF65C5ED)),
          ),
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFF3299D0),
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _TacticalPanel extends StatelessWidget {
  const _TacticalPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3CB9E7), Color(0xFF778FE8)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x263299D0),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: const Color(0xFAFFFFFF),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFCFECFA)),
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
            icon: Icons.shield_outlined,
            label: 'YOUR POLITICS SNAPSHOT',
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
                      'YOU · STRATEGIST',
                      style: TextStyle(
                        color: Color(0xFF27566B),
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Product Team · Mid-level',
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
                _UserInfoTile(
                  icon: Icons.visibility_outlined,
                  label: 'Visibility',
                  value: 'High',
                  color: Color(0xFF2C94B9),
                ),
                SizedBox(height: 4),
                _UserInfoTile(
                  icon: Icons.groups_2_outlined,
                  label: 'Ally coverage',
                  value: 'Moderate',
                  color: Color(0xFF45A58E),
                ),
                SizedBox(height: 4),
                _UserInfoTile(
                  icon: Icons.bolt_rounded,
                  label: 'Current pressure',
                  value: 'Q3 report dispute',
                  color: Color(0xFFE47B6F),
                ),
                SizedBox(height: 4),
                _UserInfoTile(
                  icon: Icons.flag_outlined,
                  label: 'Main objective',
                  value: 'Protect credibility',
                  color: Color(0xFF657FC2),
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

class _UserInfoTile extends StatelessWidget {
  const _UserInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
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
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
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
  const _RelationshipPanel({required this.compact, required this.person});

  final bool compact;
  final _PersonData person;

  @override
  Widget build(BuildContext context) {
    return _TacticalPanel(
      child: Column(
        children: [
          const _PanelHeading(
            icon: Icons.hub_outlined,
            label: 'PERSONA & RELATIONSHIP',
          ),
          const SizedBox(height: 8),
          Container(
            width: compact ? 42 : 50,
            height: compact ? 42 : 50,
            decoration: BoxDecoration(
              color: person.color.withValues(alpha: 0.28),
              shape: BoxShape.circle,
              border: Border.all(color: person.color, width: 2),
            ),
            child: Icon(Icons.person_rounded, color: person.color, size: 34),
          ),
          const SizedBox(height: 5),
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
          Text(
            person.team,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF728F9E),
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
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
          ],
          const SizedBox(height: 6),
          const Text('RELATIONSHIP RADAR', style: _panelLabelStyle),
          Expanded(
            child: CustomPaint(
              painter: _RadarPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 5),
          _Meter(label: 'Influence', value: person.influence),
          _Meter(label: 'Trust', value: person.trust),
          _Meter(label: 'Political risk', value: person.risk),
        ],
      ),
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

class _ArcadeLauncher extends StatelessWidget {
  const _ArcadeLauncher();

  @override
  Widget build(BuildContext context) {
    return _TacticalPanel(
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ARCADE QUICK-LAUNCH', style: _panelLabelStyle),
                SizedBox(height: 3),
                Text(
                  'DAILY CHALLENGE · Slap Desk!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF67E8E3),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 98,
            child: AppButton(label: 'PLAY NOW', onPressed: () {}),
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
      (
        Icons.psychology_alt_rounded,
        'Advice',
        () => context.go('/design/advice-input'),
      ),
      (Icons.map_rounded, 'Map', () => context.go('/design/office-map-list')),
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
    ];
    return Row(
      children: [
        for (final entry in items.indexed) ...[
          if (entry.$1 > 0) const SizedBox(width: 5),
          Expanded(
            child: AnimatedScale(
              key: ValueKey('home-nav-scale-${entry.$2.$2.toLowerCase()}'),
              scale: pressedIndex == null
                  ? 1
                  : pressedIndex == entry.$1
                  ? 1.16
                  : 0.84,
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
  }
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: ValueKey('home-nav-${label.toLowerCase()}'),
        onTap: onTap,
        onHighlightChanged: onPressedChanged,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFE7F4FF)],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFF65C5ED), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x183299D0),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF3299D0), size: 15),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF245672),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
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
    required this.selectedPerson,
    required this.onPersonSelected,
  });

  final double motion;
  final Offset userPosition;
  final int selectedPerson;
  final ValueChanged<int> onPersonSelected;

  Offset _project(Offset point, Size size) {
    return Offset(
      size.width * 0.50 + (point.dx - point.dy) * size.width * 0.39,
      size.height * 0.07 + (point.dx + point.dy) * size.height * 0.43,
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
                painter: _OfficeMapPainter(userPosition: userPosition),
              ),
            ),
            for (final entry in officePeopleDesignScreen.indexed)
              Positioned(
                left:
                    _project(entry.$2.position, size).dx -
                    16 +
                    math.sin((motion + entry.$2.phase) * math.pi * 2) * 3,
                top:
                    _project(entry.$2.position, size).dy -
                    18 +
                    math.cos((motion + entry.$2.phase) * math.pi * 2) * 2,
                child: _MapPerson(
                  name: entry.$2.name,
                  color: entry.$2.color,
                  avatar: entry.$2.avatar,
                  motion: motion,
                  selected: entry.$1 == selectedPerson,
                  onTap: () => onPersonSelected(entry.$1),
                ),
              ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 170),
              curve: Curves.easeOut,
              left: userPoint.dx - 18,
              top: userPoint.dy - 21,
              child: _MapPerson(
                name: 'YOU',
                color: Color(0xFF35DCD4),
                avatar: DesignAvatarDraft.self,
                motion: motion,
                isUser: true,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapPerson extends StatelessWidget {
  const _MapPerson({
    required this.name,
    required this.color,
    required this.avatar,
    required this.motion,
    this.isUser = false,
    this.selected = false,
    this.onTap,
  });

  final String name;
  final Color color;
  final DesignAvatarData avatar;
  final double motion;
  final bool isUser;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedScale(
        scale: isUser || selected ? 1.12 : 1,
        duration: const Duration(milliseconds: 220),
        child: SizedBox(
          width: 50,
          height: 73,
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 48),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xEFFFFFFF),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isUser || selected
                        ? const Color(0xFF806DE2)
                        : const Color(0xFF9EDCF5),
                  ),
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF245672),
                    fontSize: 6,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Expanded(
                child: _HomeAvatarBody(
                  avatar: avatar,
                  color: color,
                  motion: motion,
                  highlighted: isUser || selected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAvatarBody extends StatelessWidget {
  const _HomeAvatarBody({
    required this.avatar,
    required this.color,
    required this.motion,
    required this.highlighted,
  });

  final DesignAvatarData avatar;
  final Color color;
  final double motion;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final stride = math.sin(motion * math.pi * 8);
    final idle = math.sin(motion * math.pi * 4);
    return Transform.translate(
      offset: Offset(0, idle.abs() * -1.5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.28),
                    blurRadius: 13,
                    spreadRadius: 3,
                  ),
                ]
              : const [],
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 37,
              left: 13,
              child: Transform.rotate(
                angle: stride * 0.2,
                alignment: Alignment.topCenter,
                child: const _HomeLimb(color: Color(0xFF5E79A7), height: 15),
              ),
            ),
            Positioned(
              top: 37,
              right: 13,
              child: Transform.rotate(
                angle: -stride * 0.2,
                alignment: Alignment.topCenter,
                child: const _HomeLimb(color: Color(0xFF5E79A7), height: 15),
              ),
            ),
            Positioned(
              top: 22,
              child: Container(
                width: 27,
                height: 24,
                decoration: BoxDecoration(
                  color: avatar.outfitColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 25,
              left: 8,
              child: Transform.rotate(
                angle: -stride * 0.2,
                child: _HomeLimb(color: avatar.skinColor, height: 19),
              ),
            ),
            Positioned(
              top: 25,
              right: 8,
              child: Transform.rotate(
                angle: stride * 0.2,
                child: _HomeLimb(color: avatar.skinColor, height: 19),
              ),
            ),
            Positioned(
              top: 0,
              child: Transform.rotate(
                angle: idle * 0.035,
                child: SizedBox(
                  key: ValueKey('home-walking-avatar-${avatar.hashCode}'),
                  width: 34,
                  height: 38,
                  child: CustomPaint(painter: DesignAvatarHeadPainter(avatar)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLimb extends StatelessWidget {
  const _HomeLimb({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _OfficeMapPainter extends CustomPainter {
  const _OfficeMapPainter({required this.userPosition});

  final Offset userPosition;

  Offset project(Offset point, Size size) {
    return Offset(
      size.width * 0.50 + (point.dx - point.dy) * size.width * 0.39,
      size.height * 0.07 + (point.dx + point.dy) * size.height * 0.43,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final top = project(Offset.zero, size);
    final right = project(const Offset(1, 0), size);
    final bottom = project(const Offset(1, 1), size);
    final left = project(const Offset(0, 1), size);
    final floor = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(left.dx, left.dy)
      ..close();

    canvas.drawPath(
      floor.shift(const Offset(0, 10)),
      Paint()..color = const Color(0x33778FE8),
    );
    canvas.drawPath(floor, Paint()..color = const Color(0xFFDDF5FF));
    canvas.drawPath(
      floor,
      Paint()
        ..color = const Color(0xFF9EDCF5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final grid = Paint()
      ..color = const Color(0x403299D0)
      ..strokeWidth = 1;
    for (var i = 1; i < 10; i++) {
      final t = i / 10;
      canvas
        ..drawLine(
          project(Offset(t, 0), size),
          project(Offset(t, 1), size),
          grid,
        )
        ..drawLine(
          project(Offset(0, t), size),
          project(Offset(1, t), size),
          grid,
        );
    }

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
    return oldDelegate.userPosition != userPosition;
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

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.34;
    const sides = 5;
    final line = Paint()
      ..color = const Color(0xFFB3CCD6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var ring = 1; ring <= 3; ring++) {
      final path = Path();
      for (var i = 0; i < sides; i++) {
        final angle = -math.pi / 2 + i * math.pi * 2 / sides;
        final point =
            center +
            Offset(math.cos(angle), math.sin(angle)) * radius * (ring / 3);
        i == 0
            ? path.moveTo(point.dx, point.dy)
            : path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, line);
    }

    const values = [0.78, 0.58, 0.72, 0.43, 0.68];
    final shape = Path();
    for (var i = 0; i < sides; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / sides;
      final point =
          center +
          Offset(math.cos(angle), math.sin(angle)) * radius * values[i];
      i == 0
          ? shape.moveTo(point.dx, point.dy)
          : shape.lineTo(point.dx, point.dy);
    }
    shape.close();
    canvas
      ..drawPath(shape, Paint()..color = const Color(0x6638ACC1))
      ..drawPath(
        shape,
        Paint()
          ..color = const Color(0xFF2E9FB7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x183B9BB8)
      ..strokeWidth = 1;
    for (double x = 18; x < size.width; x += 52) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 16; y < size.height; y += 52) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const officePeopleDesignScreen = <_PersonData>[
  _PersonData(
    'Morgan',
    'Director',
    'Executive Office',
    'Status-conscious · Decisive · Guards authority',
    'Your skip-level manager; formally supportive but expects concise evidence.',
    'Questioned the Q3 figures in a leadership meeting two weeks ago.',
    Offset(0.22, 0.26),
    Color(0xFFC97955),
    0.0,
    0.88,
    0.52,
    0.72,
  ),
  _PersonData(
    'Avery',
    'Product Manager',
    'Product Team',
    'Analytical · Diplomatic · Builds coalitions',
    'Close collaborator with occasional ownership tension.',
    'Backed your delivery plan after you shared the source data.',
    Offset(0.67, 0.25),
    Color(0xFF7567B6),
    0.24,
    0.74,
    0.68,
    0.45,
  ),
  _PersonData(
    'Sam',
    'Senior Designer',
    'Design Team',
    'Creative · Direct · Sensitive to credit',
    'Trusted peer; communication is candid and usually constructive.',
    'Raised concern that design contributions were missing from the launch note.',
    Offset(0.28, 0.69),
    Color(0xFF278EAB),
    0.48,
    0.57,
    0.81,
    0.38,
  ),
  _PersonData(
    'Jordan',
    'Finance Partner',
    'Finance Team',
    'Cautious · Detail-driven · Controls resources',
    'Necessary stakeholder; neutral relationship with limited contact.',
    'Requested a second forecast review before approving project spend.',
    Offset(0.73, 0.67),
    Color(0xFFB77A2F),
    0.72,
    0.83,
    0.43,
    0.66,
  ),
  _PersonData(
    'Taylor',
    'Team Lead',
    'Delivery Team',
    'Ambitious · Social · Competes for visibility',
    'Friendly competitor for senior-leadership visibility.',
    'Presented a shared project result without naming your contribution.',
    Offset(0.50, 0.35),
    Color(0xFFB95670),
    0.88,
    0.69,
    0.49,
    0.78,
  ),
];

class _PersonData {
  const _PersonData(
    this.name,
    this.role,
    this.team,
    this.persona,
    this.relationship,
    this.majorEvent,
    this.position,
    this.color,
    this.phase,
    this.influence,
    this.trust,
    this.risk,
  );

  final String name;
  final String role;
  final String team;
  final String persona;
  final String relationship;
  final String majorEvent;
  final Offset position;
  final Color color;
  final double phase;
  final double influence;
  final double trust;
  final double risk;

  DesignAvatarData get avatar => switch (name) {
    'Morgan' => DesignAvatarDraft.firstColleague,
    'Avery' => const DesignAvatarData(
      skinColor: Color(0xFFAE6E48),
      hairColor: Color(0xFF342B2B),
      outfitColor: Color(0xFF4DA988),
      face: 1,
      hair: 5,
      eyes: 2,
    ),
    'Sam' => const DesignAvatarData(
      skinColor: Color(0xFFF3BE96),
      hairColor: Color(0xFF263D4D),
      outfitColor: Color(0xFF3299D0),
      hair: 3,
      eyes: 1,
      mouth: 1,
    ),
    'Jordan' => const DesignAvatarData(
      skinColor: Color(0xFFFBD0AF),
      hairColor: Color(0xFF87563A),
      outfitColor: Color(0xFFD39B42),
      face: 3,
      hair: 1,
      mouth: 2,
      accessory: 1,
    ),
    _ => const DesignAvatarData(
      skinColor: Color(0xFFF1BFA1),
      hairColor: Color(0xFF4A3041),
      outfitColor: Color(0xFFB95670),
      face: 2,
      hair: 10,
      eyes: 1,
    ),
  };
}

const _panelLabelStyle = TextStyle(
  color: Color(0xFF365F72),
  fontSize: 8,
  fontWeight: FontWeight.w900,
  letterSpacing: 0.25,
);
