import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/theme_provider.dart';
import '../core/theme_presets.dart';

class BottomNavBar extends ConsumerWidget {
  final AnimationController controller;
  const BottomNavBar({super.key, required this.controller});

  int _currentIndex(String location) {
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/payment')) return 2;
    if (location.startsWith('/schedule')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _currentIndex(location);
    final preset = ref.watch(themeProvider).preset;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final presetColors = isDark ? preset.dark() : preset.light();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: glassBackdrop(
            context,
            radius: 24,
            opacity: 0.92,
            background: presetColors.cardColor,
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              currentIndex: index,
              onTap: (i) {
                switch (i) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/search');
                    break;
                  case 2:
                    context.go('/payment');
                    break;
                  case 3:
                    context.go('/schedule');
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_outlined),
                  activeIcon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.credit_card_outlined),
                  activeIcon: Icon(Icons.credit_card),
                  label: 'Payment',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'Schedule',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
