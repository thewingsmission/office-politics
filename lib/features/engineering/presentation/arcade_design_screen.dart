import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'arcade_game_design_screen.dart';
import 'first_launch_hero_panel.dart';

class ArcadeDesignScreen extends StatelessWidget {
  const ArcadeDesignScreen({super.key});

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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacer(),
                      Icon(
                        Icons.sports_esports_rounded,
                        color: Color(0xFF3299D0),
                        size: 55,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Office Arcade',
                        style: TextStyle(
                          color: Color(0xFF174765),
                          fontSize: 24,
                          height: 1.06,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose a fictional mini game for a short skill challenge. Arcade actions are never workplace advice.',
                        style: TextStyle(
                          color: Color(0xFF56819A),
                          fontSize: 9,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose a game',
                            style: TextStyle(
                              color: Color(0xFF173F5D),
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Tap one of the four games to open its playable design preview',
                            style: TextStyle(
                              color: Color(0xFF5E8196),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const rowSpacing = 12.0;
                          final buttonHeight =
                              (constraints.maxHeight - rowSpacing) / 2;
                          return GridView.builder(
                            key: const ValueKey('arcade-game-grid'),
                            clipBehavior: Clip.none,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: rowSpacing,
                                  mainAxisExtent: buttonHeight,
                                ),
                            itemCount: ArcadeGameDesignType.values.length,
                            itemBuilder: (context, index) {
                              final game = ArcadeGameDesignType.values[index];
                              return _ArcadeGameButton(
                                game: game,
                                onPressed: () => context.go(
                                  '/design/${gameRouteIdForArcadeDesignScreen(game)}',
                                ),
                              );
                            },
                          );
                        },
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

class _ArcadeGameButton extends StatefulWidget {
  const _ArcadeGameButton({required this.game, required this.onPressed});

  final ArcadeGameDesignType game;
  final VoidCallback onPressed;

  @override
  State<_ArcadeGameButton> createState() => _ArcadeGameButtonState();
}

class _ArcadeGameButtonState extends State<_ArcadeGameButton> {
  bool pressedDesignScreen = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressedDesignScreen ? 1 : 5 / 6,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      child: Stack(
        key: ValueKey('arcade-game-button-${widget.game.name}'),
        children: [
          Positioned.fill(
            top: 6,
            left: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
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
                    Color(0xFF3DB9EE),
                    Color(0xFF719CF4),
                    Color(0xFFA386F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Material(
                color: pressedDesignScreen
                    ? const Color(0xFFD2F2FF)
                    : Colors.white,
                animationDuration: const Duration(milliseconds: 220),
                borderRadius: BorderRadius.circular(15),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: widget.onPressed,
                  onHighlightChanged: (pressed) {
                    setState(() => pressedDesignScreen = pressed);
                  },
                  overlayColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Container(
                          key: ValueKey(
                            'arcade-image-placeholder-${widget.game.name}',
                          ),
                          margin: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F4FF),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: CustomPaint(
                            painter: _ArcadePlaceholderPainter(
                              game: widget.game,
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(2, 7, 8, 7),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.game.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF245672),
                                  fontSize: 12,
                                  height: 1.05,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Text(
                                    'PLAY',
                                    style: TextStyle(
                                      color: Color(0xFF3299D0),
                                      fontSize: 7,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Color(0xFF3299D0),
                                    size: 11,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcadePlaceholderPainter extends CustomPainter {
  const _ArcadePlaceholderPainter({required this.game});

  final ArcadeGameDesignType game;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final blue = Paint()..color = const Color(0xFF3299D0);
    final purple = Paint()..color = const Color(0xFF778FE8);
    final pale = Paint()..color = const Color(0x55FFFFFF);

    switch (game) {
      case ArcadeGameDesignType.slapDesk:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center + const Offset(0, 13),
              width: size.width * 0.68,
              height: 18,
            ),
            const Radius.circular(5),
          ),
          purple,
        );
        canvas.drawCircle(center - const Offset(0, 8), 13, blue);
        canvas.drawCircle(
          center + const Offset(19, -13),
          8,
          Paint()..color = const Color(0xFFF0BE9A),
        );
      case ArcadeGameDesignType.creditChase:
        for (final offset in [
          const Offset(-22, 8),
          const Offset(0, -10),
          const Offset(23, 10),
        ]) {
          canvas.drawCircle(center + offset, 9, purple);
          _paintText(canvas, '★', center + offset, 10, Colors.white);
        }
        canvas.drawPath(
          Path()
            ..moveTo(center.dx - 30, center.dy + 24)
            ..quadraticBezierTo(
              center.dx,
              center.dy,
              center.dx + 31,
              center.dy + 23,
            ),
          blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      case ArcadeGameDesignType.rumourFlip:
        canvas.drawCircle(center - const Offset(19, 3), 18, purple);
        _paintText(canvas, '?', center - const Offset(19, 3), 16, Colors.white);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center + const Offset(23, 2),
              width: 33,
              height: 28,
            ),
            const Radius.circular(8),
          ),
          pale,
        );
        canvas.drawLine(
          center - const Offset(1, 3),
          center + const Offset(8, 1),
          blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      case ArcadeGameDesignType.fivePmGhost:
        final cone = Path()
          ..moveTo(center.dx - 18, center.dy)
          ..lineTo(center.dx + 31, center.dy - 27)
          ..lineTo(center.dx + 31, center.dy + 27)
          ..close();
        canvas.drawPath(cone, Paint()..color = const Color(0x55FFB45F));
        canvas.drawCircle(center - const Offset(18, 0), 14, purple);
        _paintText(canvas, '5', center - const Offset(18, 0), 12, Colors.white);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center + const Offset(32, -18),
              width: 20,
              height: 25,
            ),
            const Radius.circular(4),
          ),
          blue,
        );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ArcadePlaceholderPainter oldDelegate) =>
      game != oldDelegate.game;
}

String gameRouteIdForArcadeDesignScreen(ArcadeGameDesignType game) =>
    switch (game) {
      ArcadeGameDesignType.slapDesk => 'slap-desk',
      ArcadeGameDesignType.creditChase => 'credit-chase',
      ArcadeGameDesignType.rumourFlip => 'rumour-flip',
      ArcadeGameDesignType.fivePmGhost => 'five-pm-ghost',
    };
