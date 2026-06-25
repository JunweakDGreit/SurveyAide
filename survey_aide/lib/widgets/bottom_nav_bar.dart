import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/uiprovider.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

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
    final sheetOpen = ref.watch(bottomSheetOpenProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.bottomCenter,
      child: sheetOpen
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: glassBackdrop(
                context,
                radius: 24,
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
    );
  }
}
