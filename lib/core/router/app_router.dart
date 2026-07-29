import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_screen.dart';
import '../../features/element/presentation/element_detail_screen.dart';
import '../../features/encyclopedia/presentation/encyclopedia_screen.dart';
import '../../features/faq/presentation/faq_screen.dart';
import '../../features/game/presentation/game_view.dart';
import '../../features/hints/presentation/hints_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/intro/presentation/intro_screen.dart';
import '../../features/journey/presentation/journey_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';

/// Declarative route table for MixRun.
///
/// The four in-game sections (canvas, encyclopedia, stats, settings) live in a
/// [StatefulShellRoute] so they share a persistent bottom toolbar and each
/// keeps its state. Modals (discovery, element detail, hints) are shown over
/// the shell.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String game = '/game';
  static const String encyclopedia = '/encyclopedia';
  static const String hints = '/hints';
  static const String settings = '/settings';
  static const String stats = '/stats';
  static const String journey = '/journey';
  static const String login = '/login';
  static const String faq = '/faq';
  static const String intro = '/intro';

  /// Base path for the element detail page; append `/<id>` to open one.
  static const String element = '/element';
}

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.game,
                builder: (context, state) => const GameView(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.encyclopedia,
                builder: (context, state) => const EncyclopediaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.stats,
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.hints,
                builder: (context, state) => const HintsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.journey,
                builder: (context, state) => const JourneyScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: AppRoutes.intro,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.element}/:id',
        builder: (context, state) =>
            ElementDetailScreen(elementId: state.pathParameters['id']!),
      ),
    ],
  );
}
