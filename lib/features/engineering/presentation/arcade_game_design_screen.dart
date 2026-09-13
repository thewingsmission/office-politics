import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'first_launch_hero_panel.dart';

enum ArcadeGameDesignType { slapDesk, creditChase, rumourFlip, fivePmGhost }

extension ArcadeGameDesignTypePresentation on ArcadeGameDesignType {
  String get title => switch (this) {
    ArcadeGameDesignType.slapDesk => 'Slap Desk',
    ArcadeGameDesignType.creditChase => 'Credit Chase',
    ArcadeGameDesignType.rumourFlip => 'Rumour Flip',
    ArcadeGameDesignType.fivePmGhost => '5pm Ghost',
  };

  String get objective => switch (this) {
    ArcadeGameDesignType.slapDesk =>
      'Tap only the highlighted fictional target. Wrong taps break the combo.',
    ArcadeGameDesignType.creditChase =>
      'Drag your player into moving credit tokens before time runs out.',
    ArcadeGameDesignType.rumourFlip =>
      'Drag the rumour bubble into the honest-subtext target.',
    ArcadeGameDesignType.fivePmGhost =>
      'Drag to the exit while avoiding wandering meeting ghosts.',
  };

  String get control => switch (this) {
    ArcadeGameDesignType.slapDesk => 'CONTROL · TAP',
    ArcadeGameDesignType.creditChase => 'CONTROL · DRAG',
    ArcadeGameDesignType.rumourFlip => 'CONTROL · DRAG AND RELEASE',
    ArcadeGameDesignType.fivePmGhost => 'CONTROL · DRAG',
  };

  IconData get icon => switch (this) {
    ArcadeGameDesignType.slapDesk => Icons.back_hand_rounded,
    ArcadeGameDesignType.creditChase => Icons.stars_rounded,
    ArcadeGameDesignType.rumourFlip => Icons.flip_camera_android_rounded,
    ArcadeGameDesignType.fivePmGhost => Icons.visibility_rounded,
  };
}

class ArcadeGameDesignScreen extends StatefulWidget {
  const ArcadeGameDesignScreen({super.key, required this.game});

  final ArcadeGameDesignType game;

  @override
  State<ArcadeGameDesignScreen> createState() => _ArcadeGameDesignScreenState();
}

class _ArcadeGameDesignScreenState extends State<ArcadeGameDesignScreen> {
  final Random randomDesignScreen = Random();
  Timer? timerDesignScreen;
  Size arenaSizeDesignScreen = Size.zero;

  bool runningDesignScreen = false;
  bool gameplayActiveDesignScreen = false;
  double remainingDesignScreen = 30;
  double phaseDesignScreen = 0;
  int scoreDesignScreen = 0;
  int comboDesignScreen = 0;
  int livesDesignScreen = 3;
  int targetDesignScreen = 0;
  Offset playerDesignScreen = const Offset(0.16, 0.58);
  Offset bubbleDesignScreen = const Offset(0.20, 0.62);
  String statusDesignScreen = 'Press Start Run';

  final List<Offset> actorBasesDesignScreen = const [
    Offset(0.18, 0.28),
    Offset(0.43, 0.30),
    Offset(0.70, 0.25),
    Offset(0.30, 0.70),
    Offset(0.67, 0.68),
  ];

  @override
  void dispose() {
    timerDesignScreen?.cancel();
    super.dispose();
  }

  void startDesignScreen() {
    timerDesignScreen?.cancel();
    setState(() {
      runningDesignScreen = true;
      gameplayActiveDesignScreen = true;
      remainingDesignScreen = 30;
      phaseDesignScreen = 0;
      scoreDesignScreen = 0;
      comboDesignScreen = 0;
      livesDesignScreen = 3;
      targetDesignScreen = randomDesignScreen.nextInt(5);
      playerDesignScreen = const Offset(0.16, 0.58);
      bubbleDesignScreen = const Offset(0.20, 0.62);
      statusDesignScreen = widget.game.objective;
    });
    timerDesignScreen = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => tickDesignScreen(),
    );
  }

  void tickDesignScreen() {
    if (!mounted || !runningDesignScreen) return;
    var showResult = false;
    setState(() {
      remainingDesignScreen = max(0, remainingDesignScreen - 0.08);
      phaseDesignScreen += 0.08;
      if (widget.game == ArcadeGameDesignType.creditChase) {
        collectCreditsDesignScreen();
      } else if (widget.game == ArcadeGameDesignType.fivePmGhost) {
        checkGhostCollisionDesignScreen();
      }
      if (remainingDesignScreen <= 0) {
        runningDesignScreen = false;
        statusDesignScreen = 'Run Complete · Final Score $scoreDesignScreen';
        timerDesignScreen?.cancel();
        showResult = true;
      }
    });
    if (showResult) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) showResultDesignScreen();
      });
    }
  }

  Future<void> pauseDesignScreen() async {
    if (!runningDesignScreen) return;
    setState(() => runningDesignScreen = false);
    final action = await showDialog<_PauseActionDesignScreen>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ArcadeDialogFrame(
        key: const ValueKey('arcade-pause-popup'),
        icon: Icons.pause_circle_rounded,
        title: 'Run Paused',
        message:
            'Your score and remaining time are preserved while this popup is open.',
        actions: [
          AppButton(
            label: 'Resume',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_PauseActionDesignScreen.resume),
          ),
          AppButton(
            label: 'Restart',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_PauseActionDesignScreen.restart),
          ),
          AppButton(
            label: 'Exit to Arcade',
            onPressed: () =>
                Navigator.of(dialogContext).pop(_PauseActionDesignScreen.exit),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _PauseActionDesignScreen.resume:
        setState(() => runningDesignScreen = true);
      case _PauseActionDesignScreen.restart:
        startDesignScreen();
      case _PauseActionDesignScreen.exit:
        timerDesignScreen?.cancel();
        context.go('/design/arcade');
      case null:
        setState(() => runningDesignScreen = true);
    }
  }

  Future<void> showResultDesignScreen() async {
    if (!mounted) return;
    final action = await showDialog<_ResultActionDesignScreen>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _ArcadeDialogFrame(
        key: const ValueKey('arcade-result-popup'),
        icon: Icons.emoji_events_rounded,
        title: 'Run Complete',
        message:
            'Final Score  $scoreDesignScreen\nBest Combo  ×$comboDesignScreen',
        actions: [
          AppButton(
            label: 'Play Again',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_ResultActionDesignScreen.playAgain),
          ),
          AppButton(
            label: 'Leaderboard',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_ResultActionDesignScreen.leaderboard),
          ),
          AppButton(
            label: 'Arcade',
            onPressed: () => Navigator.of(
              dialogContext,
            ).pop(_ResultActionDesignScreen.arcade),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (action) {
      case _ResultActionDesignScreen.playAgain:
        startDesignScreen();
      case _ResultActionDesignScreen.leaderboard:
        context.go('/design/leaderboard');
      case _ResultActionDesignScreen.arcade:
        context.go('/design/arcade');
      case null:
        break;
    }
  }

  List<Offset> movingActorsDesignScreen() {
    return [
      for (final entry in actorBasesDesignScreen.indexed)
        Offset(
          (entry.$2.dx +
                  sin(phaseDesignScreen * (0.7 + entry.$1 * 0.08) + entry.$1) *
                      0.055)
              .clamp(0.08, 0.92),
          (entry.$2.dy +
                  cos(phaseDesignScreen * (0.8 + entry.$1 * 0.06) + entry.$1) *
                      0.045)
              .clamp(0.12, 0.86),
        ),
    ];
  }

  Offset localToNormalizedDesignScreen(Offset local) {
    if (arenaSizeDesignScreen.isEmpty) return Offset.zero;
    return Offset(
      (local.dx / arenaSizeDesignScreen.width).clamp(0.05, 0.95),
      (local.dy / arenaSizeDesignScreen.height).clamp(0.08, 0.92),
    );
  }

  void handleTapDesignScreen(TapDownDetails details) {
    if (!runningDesignScreen || widget.game != ArcadeGameDesignType.slapDesk) {
      return;
    }
    final point = localToNormalizedDesignScreen(details.localPosition);
    final actors = movingActorsDesignScreen();
    var closest = 0;
    var distance = double.infinity;
    for (final entry in actors.indexed) {
      final candidate = (point - entry.$2).distance;
      if (candidate < distance) {
        distance = candidate;
        closest = entry.$1;
      }
    }
    if (distance > 0.12) return;
    setState(() {
      if (closest == targetDesignScreen) {
        comboDesignScreen++;
        scoreDesignScreen += 100 + comboDesignScreen * 20;
        statusDesignScreen = 'Correct Target · Combo ×$comboDesignScreen';
        targetDesignScreen = randomDesignScreen.nextInt(actors.length);
      } else {
        comboDesignScreen = 0;
        scoreDesignScreen = max(0, scoreDesignScreen - 30);
        statusDesignScreen = 'Wrong Desk · Combo Reset';
      }
    });
  }

  void handlePanDesignScreen(Offset local) {
    if (!runningDesignScreen) return;
    final point = localToNormalizedDesignScreen(local);
    setState(() {
      if (widget.game == ArcadeGameDesignType.rumourFlip) {
        bubbleDesignScreen = point;
      } else if (widget.game == ArcadeGameDesignType.creditChase ||
          widget.game == ArcadeGameDesignType.fivePmGhost) {
        playerDesignScreen = point;
        if (widget.game == ArcadeGameDesignType.creditChase) {
          collectCreditsDesignScreen();
        } else {
          checkGhostCollisionDesignScreen();
          if (playerDesignScreen.dx > 0.88 && playerDesignScreen.dy < 0.30) {
            scoreDesignScreen += 500;
            remainingDesignScreen = min(30, remainingDesignScreen + 3);
            playerDesignScreen = const Offset(0.14, 0.78);
            statusDesignScreen = 'Escaped! · +500 and +3 Seconds';
          }
        }
      }
    });
  }

  void completeRumourFlipDesignScreen() {
    if (!runningDesignScreen ||
        widget.game != ArcadeGameDesignType.rumourFlip) {
      return;
    }
    setState(() {
      if ((bubbleDesignScreen - const Offset(0.80, 0.34)).distance < 0.18) {
        comboDesignScreen++;
        scoreDesignScreen += 140 + comboDesignScreen * 25;
        statusDesignScreen = 'Honest Subtext Found · Combo ×$comboDesignScreen';
      } else {
        comboDesignScreen = 0;
        statusDesignScreen = 'Missed the Meaning · Try Again';
      }
      bubbleDesignScreen = const Offset(0.20, 0.62);
    });
  }

  void collectCreditsDesignScreen() {
    final actors = movingActorsDesignScreen();
    for (final entry in actors.indexed) {
      if ((playerDesignScreen - entry.$2).distance < 0.095) {
        scoreDesignScreen += 120;
        comboDesignScreen++;
        statusDesignScreen = 'Credit Reclaimed · ${scoreDesignScreen ~/ 120}';
        final base = actorBasesDesignScreen[entry.$1];
        playerDesignScreen = Offset(
          (base.dx - 0.18).clamp(0.08, 0.88),
          (base.dy + 0.16).clamp(0.12, 0.86),
        );
        return;
      }
    }
  }

  void checkGhostCollisionDesignScreen() {
    for (final ghost in movingActorsDesignScreen().take(3)) {
      if ((playerDesignScreen - ghost).distance < 0.11) {
        livesDesignScreen--;
        comboDesignScreen = 0;
        playerDesignScreen = const Offset(0.14, 0.78);
        statusDesignScreen = livesDesignScreen > 0
            ? 'Meeting Ghost Found You · $livesDesignScreen Lives Left'
            : 'Caught at 5pm · Press Start Run';
        if (livesDesignScreen <= 0) {
          runningDesignScreen = false;
          timerDesignScreen?.cancel();
        }
        return;
      }
      if ((playerDesignScreen - ghost).distance < 0.17) {
        scoreDesignScreen += 2;
        comboDesignScreen++;
        statusDesignScreen = 'Near Miss · Keep Moving';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (gameplayActiveDesignScreen) {
      return _buildFullScreenGameplayDesignScreen(context);
    }
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
                  child: _GameHudDesignScreen(
                    game: widget.game,
                    score: scoreDesignScreen,
                    combo: comboDesignScreen,
                    lives: livesDesignScreen,
                    status: statusDesignScreen,
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
                          child: Text(
                            widget.game.title,
                            style: const TextStyle(
                              color: Color(0xFF173F5D),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _GameStat(
                          label: 'TIME',
                          value: remainingDesignScreen.ceil().toString(),
                        ),
                        const SizedBox(width: 7),
                        _GameStat(
                          label: 'SCORE',
                          value: scoreDesignScreen.toString(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: _buildArenaDesignScreen(fullScreen: false)),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.game.control,
                            style: const TextStyle(
                              color: Color(0xFF4381A3),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (runningDesignScreen) ...[
                          SizedBox(
                            width: 112,
                            child: AppButton(
                              key: const ValueKey('arcade-pause-button'),
                              label: 'Pause',
                              leading: const Icon(Icons.pause_rounded),
                              onPressed: pauseDesignScreen,
                            ),
                          ),
                          const SizedBox(width: 7),
                        ],
                        SizedBox(
                          width: 155,
                          child: AppButton(
                            key: ValueKey('arcade-start-${widget.game.name}'),
                            label: runningDesignScreen
                                ? 'Restart Run'
                                : 'Start Run',
                            leading: Icon(widget.game.icon),
                            onPressed: startDesignScreen,
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

  Widget _buildFullScreenGameplayDesignScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      body: Stack(
        children: [
          Positioned.fill(child: _buildArenaDesignScreen(fullScreen: true)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: const Color(0xFF65C5ED)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.game.icon,
                              color: const Color(0xFF3299D0),
                              size: 20,
                            ),
                            const SizedBox(width: 7),
                            Text(
                              widget.game.title,
                              style: const TextStyle(
                                color: Color(0xFF173F5D),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _GameStat(
                        label: 'TIME',
                        value: remainingDesignScreen.ceil().toString(),
                      ),
                      const SizedBox(width: 7),
                      _GameStat(
                        label: 'SCORE',
                        value: scoreDesignScreen.toString(),
                      ),
                      if (widget.game == ArcadeGameDesignType.fivePmGhost) ...[
                        const SizedBox(width: 7),
                        _GameStat(
                          label: 'LIVES',
                          value: livesDesignScreen.toString(),
                        ),
                      ],
                      const SizedBox(width: 10),
                      if (runningDesignScreen)
                        SizedBox(
                          width: 112,
                          child: AppButton(
                            key: const ValueKey('arcade-pause-button'),
                            label: 'Pause',
                            leading: const Icon(Icons.pause_rounded),
                            onPressed: pauseDesignScreen,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF9EDCF5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.game.control,
                                style: const TextStyle(
                                  color: Color(0xFF4381A3),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                statusDesignScreen,
                                key: const ValueKey('arcade-game-status'),
                                style: const TextStyle(
                                  color: Color(0xFF245672),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 155,
                        child: AppButton(
                          key: ValueKey('arcade-start-${widget.game.name}'),
                          label: 'Restart Run',
                          leading: Icon(widget.game.icon),
                          onPressed: startDesignScreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArenaDesignScreen({required bool fullScreen}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        arenaSizeDesignScreen = constraints.biggest;
        return GestureDetector(
          key: ValueKey('arcade-arena-${widget.game.name}'),
          behavior: HitTestBehavior.opaque,
          onTapDown: handleTapDesignScreen,
          onPanDown: (details) => handlePanDesignScreen(details.localPosition),
          onPanUpdate: (details) =>
              handlePanDesignScreen(details.localPosition),
          onPanEnd: (_) => completeRumourFlipDesignScreen(),
          child: CustomPaint(
            painter: _ArcadeArenaPainter(
              game: widget.game,
              actors: movingActorsDesignScreen(),
              player: playerDesignScreen,
              bubble: bubbleDesignScreen,
              target: targetDesignScreen,
              running: runningDesignScreen,
              phase: phaseDesignScreen,
              fullScreen: fullScreen,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _GameHudDesignScreen extends StatelessWidget {
  const _GameHudDesignScreen({
    required this.game,
    required this.score,
    required this.combo,
    required this.lives,
    required this.status,
  });

  final ArcadeGameDesignType game;
  final int score;
  final int combo;
  final int lives;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Icon(game.icon, color: const Color(0xFF3299D0), size: 48),
        const SizedBox(height: 8),
        Text(
          game.title,
          style: const TextStyle(
            color: Color(0xFF174765),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          game.objective,
          style: const TextStyle(
            color: Color(0xFF56819A),
            fontSize: 10,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _HudPill(label: 'Score', value: '$score'),
            _HudPill(label: 'Combo', value: '×$combo'),
            if (game == ArcadeGameDesignType.fivePmGhost)
              _HudPill(label: 'Lives', value: '$lives'),
          ],
        ),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF9EDCF5)),
          ),
          child: Text(
            status,
            key: const ValueKey('arcade-game-status'),
            style: const TextStyle(
              color: Color(0xFF245672),
              fontSize: 9,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          'Fictional arcade play · Never workplace advice',
          style: TextStyle(
            color: Color(0xFF63869A),
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HudPill extends StatelessWidget {
  const _HudPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF65C5ED)),
      ),
      child: Text(
        '$label  $value',
        style: const TextStyle(
          color: Color(0xFF277BAA),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GameStat extends StatelessWidget {
  const _GameStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF9EDCF5)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF5E8196),
              fontSize: 6,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF245672),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PauseActionDesignScreen { resume, restart, exit }

enum _ResultActionDesignScreen { playAgain, leaderboard, arcade }

class _ArcadeDialogFrame extends StatelessWidget {
  const _ArcadeDialogFrame({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3DB9EE), Color(0xFF719CF4), Color(0xFFA386F5)],
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF3299D0), size: 42),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF174765),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF56819A),
                  fontSize: 10,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final entry in actions.indexed) ...[
                    if (entry.$1 > 0) const SizedBox(width: 8),
                    Expanded(child: entry.$2),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArcadeArenaPainter extends CustomPainter {
  const _ArcadeArenaPainter({
    required this.game,
    required this.actors,
    required this.player,
    required this.bubble,
    required this.target,
    required this.running,
    required this.phase,
    this.fullScreen = false,
  });

  final ArcadeGameDesignType game;
  final List<Offset> actors;
  final Offset player;
  final Offset bubble;
  final int target;
  final bool running;
  final double phase;
  final bool fullScreen;

  Offset point(Offset normalized, Size size) =>
      Offset(normalized.dx * size.width, normalized.dy * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(fullScreen ? 0 : 20),
    );
    canvas
      ..clipRRect(bounds)
      ..drawRRect(bounds, Paint()..color = const Color(0xFFEAF8FF));
    final grid = Paint()
      ..color = const Color(0xFFCAEAF8)
      ..strokeWidth = 1;
    for (var x = 20.0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 20.0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    switch (game) {
      case ArcadeGameDesignType.slapDesk:
        _paintSlapDesk(canvas, size);
      case ArcadeGameDesignType.creditChase:
        _paintCreditChase(canvas, size);
      case ArcadeGameDesignType.rumourFlip:
        _paintRumourFlip(canvas, size);
      case ArcadeGameDesignType.fivePmGhost:
        _paintFivePmGhost(canvas, size);
    }

    if (!fullScreen) {
      canvas.drawRRect(
        bounds,
        Paint()
          ..color = const Color(0xFF65C5ED)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    if (!running) {
      canvas.drawRRect(
        bounds,
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      );
    }
  }

  void _paintSlapDesk(Canvas canvas, Size size) {
    for (final entry in actors.indexed) {
      final center = point(entry.$2, size);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + const Offset(0, 18),
            width: 58,
            height: 28,
          ),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFFBEE5F5),
      );
      _person(canvas, center - const Offset(0, 10), entry.$1);
      if (entry.$1 == target) {
        canvas.drawCircle(
          center - const Offset(0, 10),
          25 + sin(phase * 5).abs() * 3,
          Paint()
            ..color = const Color(0xFF778FE8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
    }
  }

  void _paintCreditChase(Canvas canvas, Size size) {
    for (final entry in actors.indexed) {
      final center = point(entry.$2, size);
      canvas.drawCircle(center, 15, Paint()..color = const Color(0xFFFFD66B));
      _text(canvas, '★', center, 15, const Color(0xFF9A6A00));
    }
    _player(canvas, point(player, size));
  }

  void _paintRumourFlip(Canvas canvas, Size size) {
    final targetCenter = point(const Offset(0.80, 0.34), size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: targetCenter, width: 145, height: 72),
        const Radius.circular(18),
      ),
      Paint()..color = const Color(0xFFDDF5FF),
    );
    _text(canvas, 'HONEST\nSUBTEXT', targetCenter, 12, const Color(0xFF277BAA));
    final bubbleCenter = point(bubble, size);
    canvas.drawCircle(
      bubbleCenter,
      31,
      Paint()..color = const Color(0xFFEAE5FF),
    );
    _text(canvas, 'RUMOUR', bubbleCenter, 9, const Color(0xFF6857B7));
  }

  void _paintFivePmGhost(Canvas canvas, Size size) {
    final exit = Rect.fromLTWH(size.width - 70, 12, 58, 58);
    canvas.drawRRect(
      RRect.fromRectAndRadius(exit, const Radius.circular(10)),
      Paint()..color = const Color(0xFFCCF4E9),
    );
    _text(canvas, 'EXIT', exit.center, 11, const Color(0xFF27836C));
    for (final entry in actors.take(3).indexed) {
      final center = point(entry.$2, size);
      final direction = phase * 0.8 + entry.$1 * 2;
      final cone = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + cos(direction - 0.5) * 90,
          center.dy + sin(direction - 0.5) * 90,
        )
        ..lineTo(
          center.dx + cos(direction + 0.5) * 90,
          center.dy + sin(direction + 0.5) * 90,
        )
        ..close();
      canvas.drawPath(cone, Paint()..color = const Color(0x33FFB45F));
      canvas.drawCircle(center, 19, Paint()..color = const Color(0xFF778FE8));
      _text(canvas, '5', center, 11, Colors.white);
    }
    _player(canvas, point(player, size));
  }

  void _person(Canvas canvas, Offset center, int index) {
    const shirts = [
      Color(0xFF3CB9E7),
      Color(0xFF778FE8),
      Color(0xFF55BDA1),
      Color(0xFFE58B83),
      Color(0xFFF2B45E),
    ];
    canvas
      ..drawCircle(center, 13, Paint()..color = const Color(0xFFF0BE9A))
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + const Offset(0, 20),
            width: 27,
            height: 25,
          ),
          const Radius.circular(9),
        ),
        Paint()..color = shirts[index % shirts.length],
      );
  }

  void _player(Canvas canvas, Offset center) {
    canvas
      ..drawCircle(center, 19, Paint()..color = const Color(0x443CB9E7))
      ..drawCircle(center, 12, Paint()..color = const Color(0xFF3299D0));
    _text(canvas, 'YOU', center, 7, Colors.white);
  }

  void _text(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ArcadeArenaPainter oldDelegate) => true;
}
