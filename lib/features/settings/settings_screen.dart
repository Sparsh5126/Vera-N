import 'package:flutter/material.dart';

import '../../core/copy/app_copy.dart';
import '../../core/styles/app_styles.dart';
import 'widgets/about_section.dart';
import 'widgets/app_section.dart';
import 'widgets/folder_section.dart';
import 'widgets/suggestions_section.dart';

/// Settings: one scrollable page (UI spec §11). Rows for features not built
/// yet (quick capture, sync status, laptop, trash, export) join later.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpace.m,
                right: AppSpace.m,
                top: AppSpace.l,
              ),
              child: Semantics(
                header: true,
                child: Text(
                  AppCopy.navSettings,
                  style: context.textStyles.noteTitle,
                ),
              ),
            ),
            const AppSection(),
            const FolderSection(),
            const SuggestionsSection(),
            const AboutSection(),
            const SizedBox(height: AppSize.floatingClearance),
          ],
        ),
      ),
    );
  }
}
