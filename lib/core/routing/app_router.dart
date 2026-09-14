import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/session_controller.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/engineering/domain/design_screen_definition.dart';
import '../../features/engineering/presentation/arcade_design_screen.dart';
import '../../features/engineering/presentation/arcade_game_design_screen.dart';
import '../../features/engineering/presentation/advice_input_design_screen.dart';
import '../../features/engineering/presentation/auth_design_screen.dart';
import '../../features/engineering/presentation/character_profile_design_screen.dart';
import '../../features/engineering/presentation/colleague_design_screen.dart';
import '../../features/engineering/presentation/design_preview_design_screen.dart';
import '../../features/engineering/presentation/engineering_screen.dart';
import '../../features/engineering/presentation/event_editor_design_screen.dart';
import '../../features/engineering/presentation/event_timeline_design_screen.dart';
import '../../features/engineering/presentation/face_lab_design_screen.dart';
import '../../features/engineering/presentation/home_design_screen.dart';
import '../../features/engineering/presentation/language_setup_design_screen.dart';
import '../../features/engineering/presentation/leaderboard_design_screen.dart';
import '../../features/engineering/presentation/name_setup_design_screen.dart';
import '../../features/engineering/presentation/office_map_editor_design_screen.dart';
import '../../features/engineering/presentation/people_network_design_screen.dart';
import '../../features/engineering/presentation/privacy_notice_design_screen.dart';
import '../../features/engineering/presentation/relationship_setup_design_screen.dart';
import '../../features/engineering/presentation/screen_map_design_screen.dart';
import '../../features/engineering/presentation/splash_design_screen.dart';
import '../../features/engineering/presentation/workspace_setup_design_screen.dart';
import '../../features/engineering/presentation/workplace_design_screen.dart';
import '../../features/engineering/presentation/yourself_design_screen.dart';
import '../../features/paywall/presentation/paywall_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/engineering',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
      final atEngineering =
          location == '/engineering' || location.startsWith('/design/');
      if (atEngineering) {
        return null;
      }
      final atSplash = location == '/splash';
      final atAuth = location == '/auth';

      if (session.isLoading) {
        return atSplash ? null : '/splash';
      }

      final signedIn = session.value != null;
      if (!signedIn) {
        return atAuth ? null : '/auth';
      }
      if (atAuth || atSplash) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/engineering',
        name: 'engineering',
        builder: (context, state) => const EngineeringScreen(),
      ),
      GoRoute(
        path: '/design/:designScreenId',
        name: 'designPreviewDesignScreen',
        builder: (context, state) {
          final designScreenId = state.pathParameters['designScreenId'] ?? '';
          if (designScreenId == 'splash') {
            return const SplashDesignScreen();
          }
          if (designScreenId == 'home') {
            return const HomeDesignScreen();
          }
          if (designScreenId == 'language-setup') {
            return const LanguageSetupDesignScreen();
          }
          if (designScreenId == 'name-setup') {
            return const NameSetupDesignScreen();
          }
          if (designScreenId == 'privacy-notice') {
            return const PrivacyNoticeDesignScreen();
          }
          if (designScreenId == 'auth') {
            return const AuthDesignScreen();
          }
          if (designScreenId == 'workspace-setup') {
            return const WorkspaceSetupDesignScreen();
          }
          final workspaceScenario = switch (state.uri.queryParameters['mode']) {
            'create' => WorkspaceScenarioDesignScreen.create,
            'modify' => WorkspaceScenarioDesignScreen.modify,
            'create-pair' => WorkspaceScenarioDesignScreen.createPair,
            'modify-pair' => WorkspaceScenarioDesignScreen.modifyPair,
            _ => WorkspaceScenarioDesignScreen.firstLaunch,
          };
          if (designScreenId == 'workplace') {
            return WorkplaceDesignScreen(initialScenario: workspaceScenario);
          }
          if (designScreenId == 'yourself') {
            return YourselfDesignScreen(initialScenario: workspaceScenario);
          }
          if (designScreenId == 'colleague') {
            return ColleagueDesignScreen(initialScenario: workspaceScenario);
          }
          if (designScreenId == 'relationship-setup') {
            return RelationshipSetupDesignScreen(
              initialScenario: workspaceScenario,
            );
          }
          if (designScreenId == 'face-lab') {
            final mode = state.uri.queryParameters['mode'];
            return FaceLabDesignScreen(
              firstLaunch: mode == 'first-launch',
              creatingColleague: mode == 'colleague-create',
              colleagueName: state.uri.queryParameters['name'] ?? 'Alex',
            );
          }
          if (designScreenId == 'office-map-editor') {
            return const OfficeMapEditorDesignScreen();
          }
          if (designScreenId == 'people-network') {
            return const PeopleNetworkDesignScreen();
          }
          if (designScreenId == 'character-profile') {
            return CharacterProfileDesignScreen(
              initialPerson: state.uri.queryParameters['person'],
            );
          }
          if (designScreenId == 'event-timeline') {
            return const EventTimelineDesignScreen();
          }
          if (designScreenId == 'event-editor') {
            return EventEditorDesignScreen(
              initialMode: state.uri.queryParameters['mode'] == 'create'
                  ? EventEditorModeDesignScreen.create
                  : EventEditorModeDesignScreen.inspect,
            );
          }
          if (designScreenId == 'advice-input') {
            return const AdviceInputDesignScreen();
          }
          if (designScreenId == 'screen-map') {
            return const ScreenMapDesignScreen();
          }
          if (designScreenId == 'arcade') {
            return const ArcadeDesignScreen();
          }
          if (designScreenId == 'slap-desk') {
            return const ArcadeGameDesignScreen(
              game: ArcadeGameDesignType.slapDesk,
            );
          }
          if (designScreenId == 'credit-chase') {
            return const ArcadeGameDesignScreen(
              game: ArcadeGameDesignType.creditChase,
            );
          }
          if (designScreenId == 'rumour-flip') {
            return const ArcadeGameDesignScreen(
              game: ArcadeGameDesignType.rumourFlip,
            );
          }
          if (designScreenId == 'five-pm-ghost') {
            return const ArcadeGameDesignScreen(
              game: ArcadeGameDesignType.fivePmGhost,
            );
          }
          if (designScreenId == 'leaderboard') {
            return const LeaderboardDesignScreen();
          }
          final definition = designScreenDefinitionById(designScreenId);
          if (definition == null) {
            return const EngineeringScreen();
          }
          return DesignPreviewDesignScreen(definition: definition);
        },
      ),
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'shell',
        builder: (context, state) => const ShellScreen(),
      ),
      GoRoute(
        path: '/paywall',
        name: 'paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/account',
        name: 'account',
        builder: (context, state) => const AccountScreen(),
      ),
    ],
  );
});
