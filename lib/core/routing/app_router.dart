import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/application/session_controller.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/paywall/presentation/paywall_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (previous, next) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;
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
