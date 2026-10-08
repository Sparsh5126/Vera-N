import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/suggestions/suggestion_actions.dart';
import '../../../core/copy/app_copy.dart';
import '../../../core/settings/app_prefs_controller.dart';
import '../../../shared/widgets/setting_row.dart';
import '../../../shared/widgets/undo_snack_bar.dart';
import '../state/settings_controller.dart';
import 'settings_group.dart';

/// SMART SUGGESTIONS, the only place AI appears (UI spec §11): one switch
/// turns it off completely. ADVANCED, collapsed until asked for, holds
/// rebuild and reset, each with Undo instead of a question.
class SuggestionsSection extends ConsumerStatefulWidget {
  const SuggestionsSection({super.key});

  @override
  ConsumerState<SuggestionsSection> createState() => _SuggestionsSectionState();
}

class _SuggestionsSectionState extends ConsumerState<SuggestionsSection> {
  var _advanced = false;

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(appPrefsProvider);
    final settings = ref.read(settingsControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          label: AppCopy.sectionSmartSuggestions,
          children: [
            SwitchListTile(
              title: const Text(AppCopy.suggestConnections),
              value: prefs.suggestions,
              onChanged: (on) => unawaited(settings.setSuggestions(on)),
            ),
            SwitchListTile(
              title: const Text(AppCopy.analyzeOnlyWhenCharging),
              value: prefs.chargingOnly,
              onChanged: prefs.suggestions
                  ? (on) => unawaited(
                      settings.change((p) => p.copyWith(chargingOnly: on)),
                    )
                  : null,
            ),
          ],
        ),
        SettingsGroup(
          label: AppCopy.sectionAdvanced,
          children: [
            SettingRow(
              label: _advanced ? AppCopy.hideAdvanced : AppCopy.showAdvanced,
              trailing: Icon(_advanced ? Icons.expand_less : Icons.expand_more),
              onTap: () => setState(() => _advanced = !_advanced),
            ),
            if (_advanced) ...[
              SettingRow(
                label: AppCopy.rebuildSuggestions,
                onTap: () => _withUndo(
                  settings.rebuildSuggestions,
                  AppCopy.suggestionsRebuilt,
                ),
              ),
              SettingRow(
                label: AppCopy.resetRejected,
                onTap: () =>
                    _withUndo(settings.resetRejected, AppCopy.rejectedReset),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _withUndo(Future<Undo> Function() action, String message) {
    final messenger = ScaffoldMessenger.of(context);
    unawaited(
      action().then(
        (undo) => UndoSnackBar.show(
          messenger,
          message: message,
          onUndo: () => unawaited(undo()),
          aboveNavBar: true,
        ),
      ),
    );
  }
}
