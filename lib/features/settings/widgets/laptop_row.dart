import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/booster_settings_state.dart';

/// The phone's Laptop row (docs/LAPTOP_PLAN.md, L4): when a laptop last
/// helped, or "Not set up", which is a normal state. Tapping it explains
/// the laptop in two lines.
class LaptopRow extends ConsumerWidget {
  const LaptopRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(lastHelpedProvider).value;
    return SettingRow(
      label: LaptopCopy.laptop,
      value: last == null
          ? LaptopCopy.notSetUp
          : LaptopCopy.lastHelpedOn(
              DateLabel.of(last.toLocal(), DateTime.now()),
            ),
      onTap: () => unawaited(_explain(context)),
    );
  }

  Future<void> _explain(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text(LaptopCopy.explainTitle),
        content: const Text(LaptopCopy.explain),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog),
            child: const Text(LaptopCopy.gotIt),
          ),
        ],
      ),
    );
  }
}
