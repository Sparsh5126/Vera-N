import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/copy/app_copy.dart';
import '../core/navigation/open_note.dart';
import '../core/navigation/routes.dart';
import '../core/styles/app_styles.dart';
import '../shared/widgets/pill_nav_bar.dart';
import '../shared/widgets/side_nav.dart';

/// Holds the tab screens. On a phone: the floating pill bar, which steps
/// aside while the keyboard is open; notes open above it, full screen. On
/// a wide window (docs/LAPTOP_PLAN.md, L1): a sidebar, with Ctrl+N for a
/// new note and Ctrl+F for Search.
class AppShell extends ConsumerWidget {
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

  /// A new note: beside the list on a wide window, full screen on a phone.
  static void newNote(BuildContext context, WidgetRef ref) {
    if (AppBreakpoints.wide(context)) {
      context.go(Routes.home);
      ref.read(openNoteProvider.notifier).startNew();
    } else {
      context.push(Routes.newNote);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = tabs.indexOf(location).clamp(0, tabs.length - 1);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () =>
            newNote(context, ref),
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
            context.go(Routes.search),
      },
      child: Focus(
        autofocus: true,
        child: PopScope(
          // Back from another tab goes Home first, then leaves the app.
          canPop: index == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.go(Routes.home);
          },
          child: AppBreakpoints.wide(context)
              ? _wide(context, ref, index)
              : _narrow(context, index),
        ),
      ),
    );
  }

  Widget _wide(BuildContext context, WidgetRef ref, int index) {
    // One surface under the sidebar and the panes: the app background and
    // text defaults for parts that sit outside a Scaffold.
    return Material(
      color: context.colors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SideNav(
            items: items,
            currentIndex: index,
            onSelected: (i) => context.go(tabs[i]),
            onNewNote: () => newNote(context, ref),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _narrow(BuildContext context, int index) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Stack(
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
    );
  }
}
