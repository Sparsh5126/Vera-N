import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/booster/laptop_booster.dart';
import '../../../core/copy/app_copy.dart';
import '../../../core/models/booster_prefs.dart';
import '../../../core/models/booster_result.dart';
import '../../../core/utils/date_label.dart';
import '../../../shared/widgets/option_sheet.dart';
import '../../../shared/widgets/setting_row.dart';
import '../../../shared/widgets/text_entry_sheet.dart';
import '../state/booster_settings_state.dart';
import 'settings_group.dart';

/// AI ON THIS COMPUTER (laptop only, docs/LAPTOP_PLAN.md L4): the optional
/// local AI app. "Not set up" is a normal state; off means nothing runs.
class LaptopAiSection extends ConsumerWidget {
  const LaptopAiSection({super.key});

  static const _jobs = {
    BoosterKind.why: LaptopCopy.jobWhy,
    BoosterKind.tags: LaptopCopy.jobTags,
    BoosterKind.topic: LaptopCopy.jobTopics,
    BoosterKind.duplicate: LaptopCopy.jobCopies,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(boosterPrefsProvider).value;
    if (prefs == null) return const SizedBox.shrink();
    final controller = ref.read(boosterPrefsProvider.notifier);
    void change(BoosterPrefs Function(BoosterPrefs) edit) =>
        unawaited(controller.change(edit));
    return SettingsGroup(
      label: LaptopCopy.section,
      children: [
        SwitchListTile(
          title: const Text(LaptopCopy.helpSwitch),
          subtitle: const Text(LaptopCopy.helpHint),
          value: prefs.on,
          onChanged: (on) => change((p) => p.copyWith(on: on)),
        ),
        if (prefs.on) ...[
          _status(context, ref, prefs),
          SettingRow(
            label: LaptopCopy.address,
            value: prefs.address,
            onTap: () => unawaited(_editAddress(context, prefs, change)),
          ),
          SwitchListTile(
            title: const Text(LaptopCopy.ownNetwork),
            subtitle: const Text(LaptopCopy.ownNetworkHint),
            value: prefs.ownNetwork,
            onChanged: (on) => change((p) => p.copyWith(ownNetwork: on)),
          ),
          SettingRow(
            label: LaptopCopy.model,
            value: prefs.model ?? LaptopCopy.modelAutomatic,
            onTap: () => unawaited(_pickModel(context, ref, prefs, change)),
          ),
          for (final job in _jobs.entries)
            SwitchListTile(
              title: Text(job.value),
              value: prefs.jobs.contains(job.key),
              onChanged: (on) => change(
                (p) => p.copyWith(
                  jobs: on
                      ? {...p.jobs, job.key}
                      : ({...p.jobs}..remove(job.key)),
                ),
              ),
            ),
          _lastHelped(ref),
        ],
      ],
    );
  }

  Widget _status(BuildContext context, WidgetRef ref, BoosterPrefs prefs) {
    final check = ref.watch(boosterCheckProvider);
    final text = check.when(
      data: (c) => switch (c.reach) {
        BoosterReach.found => LaptopCopy.found,
        BoosterReach.nothing => LaptopCopy.nothing,
        BoosterReach.notLocal =>
          prefs.ownNetwork ? LaptopCopy.notLocalOrNetwork : LaptopCopy.notLocal,
        BoosterReach.invalid => LaptopCopy.invalid,
      },
      loading: () => LaptopCopy.checking,
      error: (_, _) => LaptopCopy.nothing,
    );
    return SettingRow(
      label: text,
      trailing: TextButton(
        onPressed: check.isLoading
            ? null
            : () => ref.invalidate(boosterCheckProvider),
        child: const Text(LaptopCopy.check),
      ),
    );
  }

  Widget _lastHelped(WidgetRef ref) {
    final last = ref.watch(lastHelpedProvider).value;
    return SettingRow(
      label: LaptopCopy.lastHelped,
      value: last == null
          ? LaptopCopy.notYet
          : DateLabel.of(last.toLocal(), DateTime.now()),
    );
  }

  Future<void> _editAddress(
    BuildContext context,
    BoosterPrefs prefs,
    void Function(BoosterPrefs Function(BoosterPrefs)) change,
  ) async {
    final typed = await TextEntrySheet.show(
      context,
      hint: LaptopCopy.addressHint,
      initial: prefs.address,
    );
    if (typed == null) return;
    // Saved as typed; the status line says if it can't be used.
    final address = typed.isEmpty ? BoosterPrefs.defaultAddress : typed;
    change((p) => p.copyWith(address: address));
  }

  Future<void> _pickModel(
    BuildContext context,
    WidgetRef ref,
    BoosterPrefs prefs,
    void Function(BoosterPrefs Function(BoosterPrefs)) change,
  ) async {
    final check = await ref.read(boosterCheckProvider.future);
    if (!context.mounted) return;
    final picked = await OptionSheet.show<String>(
      context,
      options: [
        const SheetOption(null, LaptopCopy.modelAutomatic),
        for (final m in check.models) SheetOption(m, m),
      ],
      selected: prefs.model,
      emptyMessage: LaptopCopy.noModels,
    );
    if (picked == null) return;
    change((p) => p.copyWith(model: () => picked.value));
  }
}
