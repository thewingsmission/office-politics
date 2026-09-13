import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_button.dart';
import 'arcade_game_design_screen.dart';
import 'first_launch_hero_panel.dart';

class LeaderboardDesignScreen extends StatefulWidget {
  const LeaderboardDesignScreen({super.key});

  @override
  State<LeaderboardDesignScreen> createState() =>
      _LeaderboardDesignScreenState();
}

class _LeaderboardDesignScreenState extends State<LeaderboardDesignScreen> {
  late ArcadeGameDesignType selectedGameDesignScreen;

  @override
  void initState() {
    super.initState();
    final games = ArcadeGameDesignType.values;
    selectedGameDesignScreen = games[Random().nextInt(games.length)];
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
                  child: _LeaderboardPeriods(
                    key: ValueKey(
                      'leaderboard-periods-${selectedGameDesignScreen.name}',
                    ),
                    game: selectedGameDesignScreen,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 7,
                child: _GameLeaderboardChooser(
                  selectedGame: selectedGameDesignScreen,
                  onSelected: (game) {
                    setState(() => selectedGameDesignScreen = game);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardPeriods extends StatelessWidget {
  const _LeaderboardPeriods({super.key, required this.game});

  final ArcadeGameDesignType game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          game.title,
          style: const TextStyle(
            color: Color(0xFF174765),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Text(
          'Three Leaderboards',
          style: TextStyle(
            color: Color(0xFF4381A3),
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            key: const ValueKey('leaderboard-period-scroll'),
            padding: const EdgeInsets.only(right: 4, bottom: 5),
            itemCount: leaderboardPeriodsDesignScreen.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _PeriodLeaderboardCard(
              game: game,
              period: leaderboardPeriodsDesignScreen[index],
              periodIndex: index,
            ),
          ),
        ),
      ],
    );
  }
}

class _PeriodLeaderboardCard extends StatelessWidget {
  const _PeriodLeaderboardCard({
    required this.game,
    required this.period,
    required this.periodIndex,
  });

  final ArcadeGameDesignType game;
  final String period;
  final int periodIndex;

  @override
  Widget build(BuildContext context) {
    final gameIndex = ArcadeGameDesignType.values.indexOf(game);
    final highScore = 18640 - gameIndex * 870 - periodIndex * 1640;
    final rows = [
      ('NovaFox', highScore),
      ('BlueOrbit', highScore - 1260),
      ('PaperTiger', highScore - 2480),
      ('You', highScore - 3960),
      ('DeskNinja', highScore - 4510),
    ];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF9EDCF5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                periodIndex == 0
                    ? Icons.today_rounded
                    : periodIndex == 1
                    ? Icons.date_range_rounded
                    : Icons.calendar_month_rounded,
                color: const Color(0xFF3299D0),
                size: 17,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$period Leaderboard',
                  style: const TextStyle(
                    color: Color(0xFF245672),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                'TOP 5',
                style: TextStyle(
                  color: Color(0xFF6A8CA0),
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final row in rows.indexed)
            Container(
              key: row.$2.$1 == 'You'
                  ? ValueKey('leaderboard-you-${period.toLowerCase()}')
                  : null,
              margin: const EdgeInsets.only(bottom: 3),
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: row.$2.$1 == 'You'
                    ? const Color(0xFFEAE5FF)
                    : const Color(0xFFE7F4FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text(
                      '${row.$1 + 1}',
                      style: const TextStyle(
                        color: Color(0xFF3299D0),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.$2.$1,
                      style: const TextStyle(
                        color: Color(0xFF345F77),
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    row.$2.$2.toString(),
                    style: const TextStyle(
                      color: Color(0xFF245672),
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
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

class _GameLeaderboardChooser extends StatelessWidget {
  const _GameLeaderboardChooser({
    required this.selectedGame,
    required this.onSelected,
  });

  final ArcadeGameDesignType selectedGame;
  final ValueChanged<ArcadeGameDesignType> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                'Design preview starts with a randomly selected game each time this screen opens',
                style: TextStyle(
                  color: Color(0xFF5E8196),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 2.25,
            ),
            itemCount: ArcadeGameDesignType.values.length,
            itemBuilder: (context, index) {
              final game = ArcadeGameDesignType.values[index];
              return AppButton(
                key: ValueKey('leaderboard-game-${game.name}'),
                label: game.title,
                leading: Icon(game.icon),
                selected: game == selectedGame,
                onPressed: () => onSelected(game),
              );
            },
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FirstLaunchBottomAction(
            child: SizedBox(
              width: 155,
              child: AppButton(
                label: 'Play This Game',
                leading: const Icon(Icons.play_arrow_rounded),
                onPressed: () => context.go(
                  '/design/${gameRouteIdDesignScreen(selectedGame)}',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const leaderboardPeriodsDesignScreen = ['Daily', 'Weekly', 'Monthly'];

String gameRouteIdDesignScreen(ArcadeGameDesignType game) => switch (game) {
  ArcadeGameDesignType.slapDesk => 'slap-desk',
  ArcadeGameDesignType.creditChase => 'credit-chase',
  ArcadeGameDesignType.rumourFlip => 'rumour-flip',
  ArcadeGameDesignType.fivePmGhost => 'five-pm-ghost',
};
