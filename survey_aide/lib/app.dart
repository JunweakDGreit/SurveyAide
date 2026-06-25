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
          GoRoute(path: '/', builder: (_, __) => const CalculatorView()),
          GoRoute(path: '/search', builder: (_, __) => const SearchView()),
          GoRoute(path: '/payment', builder: (_, __) => const PaymentView()),
          GoRoute(path: '/schedule', builder: (_, __) => const ScheduleView()),
        ],
      ),
    ],
  );
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Survey Aide',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      routerConfig: router,
    );
  }
}
