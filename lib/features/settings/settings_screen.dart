import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/platform/device_kind.dart';
import '../../core/styles/app_styles.dart';
import 'widgets/about_section.dart';
import 'widgets/app_section.dart';
import 'widgets/data_section.dart';
import 'widgets/folder_section.dart';
import 'widgets/laptop_ai_section.dart';
import 'widgets/suggestions_section.dart';

/// Settings: one scrollable page (UI spec §11). A laptop adds AI ON THIS
/// COMPUTER (docs/LAPTOP_PLAN.md, L4); a phone shows the laptop's help in
/// its sync row.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        // A readable column on a wide window; the whole pane still scrolls.
        child: LayoutBuilder(
          builder: (context, box) => ListView(
            padding: EdgeInsets.symmetric(
              horizontal: ((box.maxWidth - AppSize.readableWidth) / 2).clamp(
                0,
                double.infinity,
              ),
            ),
            children: _rows(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _rows(BuildContext context) => [
    Padding(
      padding: const EdgeInsets.only(
        left: AppSpace.m,
        right: AppSpace.m,
        top: AppSpace.l,
      ),
      child: Semantics(
        header: true,
        child: Text(AppCopy.navSettings, style: context.textStyles.noteTitle),
      ),
    ),
    const AppSection(),
    const FolderSection(),
    const SuggestionsSection(),
    if (DeviceKind.isDesktop) const LaptopAiSection(),
    const DataSection(),
    const AboutSection(),
    const SizedBox(height: AppSize.floatingClearance),
  ];
}
