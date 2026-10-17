import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/locked_folder.dart';
import '../../../core/styles/app_styles.dart';
import '../../../core/utils/names.dart';
import '../../../shared/widgets/folder_picker.dart';
import '../state/home_drag.dart';
import '../state/home_view.dart';
import 'folder_drop_tray.dart';
import 'home_selection_actions.dart';
import 'opened_folder_drop.dart';

/// Over Home while notes are dragged (UI spec §5): the folder tray above
/// the nav bar, and, once a folder is open under the finger, a drop
/// anywhere on its notes moves them into it.
class HomeDropLayer extends ConsumerStatefulWidget {
  const HomeDropLayer({super.key, required this.actions});

  final HomeSelectionActions actions;

  @override
  ConsumerState<HomeDropLayer> createState() => _HomeDropLayerState();
}

class _HomeDropLayerState extends ConsumerState<HomeDropLayer> {
  late final HomeDrag _drag = ref.read(homeDragProvider.notifier);

  @override
  void initState() {
    super.initState();
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    super.dispose();
  }

  /// The finger lifting ends the drag. The held card usually says so, but
  /// a folder opened under the finger takes that card off the screen first
  /// (found on the phone, 2026-10-17). Global routes run after the drag's
  /// own, so a drop is taken before the tray goes.
  void _onPointer(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      unawaited(Future.microtask(_drag.stop));
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = widget.actions;
    final view = ref.watch(homeViewProvider);
    final folders = ref.watch(homeFolderSummariesProvider).value ?? const [];
    final messenger = ScaffoldMessenger.of(context);
    final opened = view.view == HomeView.folders ? view.folder : null;
    void move(Set<int> refs, String folder) =>
        unawaited(actions.moveTo(messenger, refs, folder));
    return Stack(
      children: [
        // Locked opens only with the phone's lock, never under a drag.
        if (opened != null && opened != LockedFolder.name)
          Positioned.fill(
            child: OpenedFolderDrop(
              folder: opened,
              onDrop: (refs) => move(refs, opened),
            ),
          ),
        Positioned(
          left: AppSpace.m,
          right: AppSpace.m,
          bottom: AppSize.navBarHeight + AppSpace.m,
          child: FolderDropTray(
            folders: folders,
            onMove: move,
            onOpen: ref.read(homeViewProvider.notifier).openFolder,
            onLock: (refs) => unawaited(actions.lock(messenger, refs)),
            onArchive: (refs) => unawaited(actions.archive(messenger, refs)),
            onNewFolder: (refs) async {
              final folder = await FolderPicker.typeNew(
                context,
                cleanName: Names.folder,
              );
              if (folder != null) move(refs, folder);
            },
          ),
        ),
      ],
    );
  }
}
