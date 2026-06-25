import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../services/storage_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../settings/settings_sheet.dart';
import '../tools/tools_page.dart';
import '../survey_returns/survey_returns_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late PageController _pageController;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkHint();
  }

  Future<void> _checkHint() async {
    final shown = StorageService().getBool('gep_swipe_hint_shown');
    if (!shown && mounted) {
      setState(() => _showHint = true);
      StorageService().setBool('gep_swipe_hint_shown', true);
      unawaited(Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showHint = false);
      }));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsOpen = ref.watch(settingsSheetOpenProvider);

    return Stack(
      children: [
        ScrollConfiguration(
          behavior: MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
            },
          ),
          child: PageView(
            controller: _pageController,
            physics: const PageScrollPhysics(),
            children: [
              Scaffold(
                body: widget.child,
                bottomNavigationBar: settingsOpen ? null : const BottomNavBar(),
              ),
              const ToolsPage(),
              const SurveyReturnsPage(),
            ],
          ),
        ),
        _buildHint(),
      ],
    );
  }

  Widget _buildHint() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _showHint ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 600),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.ink.withValues(alpha: 0.35),
                  Colors.transparent,
                  AppTheme.ink.withValues(alpha: 0.35),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.chevron_left, color: Colors.white70, size: 28),
                        const SizedBox(width: 4),
                        Text('Swipe\nfor tools', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Swipe\nfor returns', textAlign: TextAlign.end, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500, height: 1.3)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.white70, size: 28),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i == 0 ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == 0 ? Colors.white : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
