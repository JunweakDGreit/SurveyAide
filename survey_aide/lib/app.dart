import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme.dart';
import 'providers/setup_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/setup/setup_page.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/calculator_view.dart';
import 'screens/search/search_view.dart';
import 'screens/payment/payment_view.dart';
import 'screens/schedule/schedule_view.dart';

CustomTransitionPage<void> _tabPage(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final setup = ref.watch(setupProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!setup.completed && state.uri.toString() != '/setup') {
        return '/setup';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (_, __) => const SetupPage(),
      ),
      ShellRoute(
        builder: (_, __, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => _tabPage(const CalculatorView(), state),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _tabPage(const SearchView(), state),
          ),
          GoRoute(
            path: '/payment',
            pageBuilder: (context, state) => _tabPage(const PaymentView(), state),
          ),
          GoRoute(
            path: '/schedule',
            pageBuilder: (context, state) => _tabPage(const ScheduleView(), state),
          ),
        ],
      ),
    ],
  );
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Survey Aide',
      debugShowCheckedModeBanner: false,
      themeMode: themeState.mode,
      theme: buildLightTheme(themeState.preset),
      darkTheme: buildDarkTheme(themeState.preset),
      routerConfig: router,
    );
  }
}
