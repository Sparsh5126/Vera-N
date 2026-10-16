import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/device_kind.dart';
import '../../../core/sync/sync_providers.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/setting_row.dart';
import '../../../shared/widgets/notice_snack_bar.dart';
import 'pair_laptop_sheet.dart';
import 'pair_phone_dialog.dart';

/// SYNC: "Sync with your phone" (laptop) or "with your laptop" (phone)
/// (docs/LAPTOP_PLAN.md, S4). Not paired: a tap starts pairing. Paired: it
/// says where sync stands, and a tap offers Unpair. Hidden in builds
/// without the engine.
class SyncRow extends ConsumerWidget {
  const SyncRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status =
        ref.watch(syncStatusProvider).value ??
        const SyncStatus(SyncState.notPaired);
    if (status.state == SyncState.unavailable) return const SizedBox.shrink();
    return SettingRow(
      label: DeviceKind.isDesktop ? SyncCopy.withPhone : SyncCopy.withLaptop,
      value: _value(status),
      hint: status.paired ? SyncCopy.onlyWifi : null,
      onTap: () => unawaited(_tap(context, ref, status)),
    );
  }

  static String _value(SyncStatus s) {
    final name = s.peerName ?? '';
    final last = s.lastSynced;
    return switch (s.state) {
      SyncState.connected => SyncCopy.inSync(name),
      SyncState.waiting =>
        last == null
            ? SyncCopy.waiting(name)
            : SyncCopy.lastSynced(DateLabel.of(last, DateTime.now())),
      SyncState.problem => SyncCopy.problem,
      _ => SyncCopy.notPaired,
    };
  }

  Future<void> _tap(BuildContext context, WidgetRef ref, SyncStatus s) async {
    final sync = ref.read(syncServiceProvider);
    if (sync == null) return;
    if (!s.paired) {
      return DeviceKind.isDesktop
          ? PairPhoneDialog.show(context, sync)
          : PairLaptopSheet.show(context, sync);
    }
    final messenger = ScaffoldMessenger.of(context);
    final unpair = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.link_off),
          title: const Text(SyncCopy.unpair),
          onTap: () => Navigator.pop(sheet, true),
        ),
      ),
    );
    if (unpair != true) return;
    await sync.unpair();
    NoticeSnackBar.show(messenger, SyncCopy.unpaired, aboveNavBar: true);
  }
}
