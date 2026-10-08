import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/copy/app_copy.dart';
import '../../../shared/widgets/setting_row.dart';
import '../state/settings_controller.dart';
import 'settings_group.dart';

/// ABOUT: the privacy promise, the version, and open-source licenses
/// (including the suggestion model's).
class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).value;
    return SettingsGroup(
      label: AppCopy.sectionAbout,
      children: [
        const SettingRow(label: AppCopy.privacy, hint: AppCopy.privacyValue),
        SettingRow(label: AppCopy.version, value: version),
        SettingRow(
          label: AppCopy.licenses,
          onTap: () => showLicensePage(
            context: context,
            applicationName: AppCopy.appName,
            applicationVersion: version,
            useRootNavigator: true,
          ),
        ),
      ],
    );
  }
}
