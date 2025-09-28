import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:learning_app/app/widgets/main_scaffold.dart';
import 'package:learning_app/features/auth/providers/auth_provider.dart';
import 'package:learning_app/features/auth/screens/login_screen.dart';
import 'package:learning_app/features/auth/screens/register_screen.dart';
import 'package:learning_app/features/evaluation/screens/evaluation_screen.dart';
import 'package:learning_app/features/home/screens/home_screen.dart';
import 'package:learning_app/features/history/screens/history_screen.dart';
import 'package:learning_app/features/overview/screens/overview_screen.dart';
import 'package:learning_app/features/quiz/screens/quiz_screen.dart';

// class QuizScreenPlaceholder extends StatelessWidget {
//   final String materialId;
//   const QuizScreenPlaceholder({super.key, required this.materialId});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(title: const Text('Judul materi')),
//     body: Center(child: Text('Quiz untuk Materi ID: $materialId')),
//   );
// }

// class OverviewScreenPlaceholder extends StatelessWidget {
//   final String attemptId;
//   const OverviewScreenPlaceholder({super.key, required this.attemptId});

//   @override
//   Widget build(BuildContext context) => Scaffold(
//     appBar: AppBar(),
//     body: Center(child: Text('Overview untuk Attempt ID: $attemptId')),
//   );
// }

class AppRouter {
  final AuthProvider authProvider;
  AppRouter({required this.authProvider});

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authProvider,
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/evaluate/:attemptId',
        builder: (context, state) =>
            EvaluationScreen(attemptId: state.pathParameters['attemptId']!),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(child: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
                routes: [
                  GoRoute(
                    path: 'overview/:attemptId',
                    builder: (context, state) => OverviewScreen(
                      attemptId: state.pathParameters['attemptId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/quiz/:materialId',
        builder: (context, state) =>
            QuizScreen(materialId: state.pathParameters['materialId']!),
      ),
    ],

    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = authProvider.status;
      final onAuthScreen =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authStatus == AuthStatus.unknown) {
        return null;
      }

      if (authStatus == AuthStatus.authenticated) {
        return onAuthScreen ? '/home' : null;
      }

      if (authStatus == AuthStatus.unauthenticated) {
        return onAuthScreen ? null : '/login';
      }

      return null;
    },
  );
}
