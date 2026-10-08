import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/copy/app_copy.dart';
import '../core/navigation/routes.dart';
import '../core/styles/app_styles.dart';
import '../shared/widgets/pill_nav_bar.dart';

/// Holds the tab screens and the floating pill bar. The bar steps aside while the
/// keyboard is open; notes open above it, full screen.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  static const tabs = [
    Routes.home,
    Routes.search,
    Routes.graph,
    Routes.settings,
  ];
  static const items = [
    PillNavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: AppCopy.navHome,
    ),
    PillNavItem(
      icon: Icons.search,
      selectedIcon: Icons.search,
      label: AppCopy.navSearch,
    ),
    PillNavItem(
      icon: Icons.hub_outlined,
      selectedIcon: Icons.hub,
      label: AppCopy.navGraph,
    ),
    PillNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: AppCopy.navSettings,
    ),
  ];

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final index = tabs.indexOf(location).clamp(0, tabs.length - 1);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      // Back from another tab goes Home first, then leaves the app.
      canPop: index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.home);
      },
      child: Stack(
        children: [
          child,
          if (!keyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.s),
                  child: Center(
                    child: PillNavBar(
                      items: items,
                      currentIndex: index,
                      onSelected: (i) => context.go(tabs[i]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
