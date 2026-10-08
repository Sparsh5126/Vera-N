import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import '../../../shared/widgets/section_label.dart';

/// A labelled group of Settings rows ("APP", "SMART SUGGESTIONS", …).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpace.m,
            right: AppSpace.m,
            top: AppSpace.l,
            bottom: AppSpace.xs,
          ),
          child: SectionLabel(label),
        ),
        ...children,
      ],
    );
  }
}
