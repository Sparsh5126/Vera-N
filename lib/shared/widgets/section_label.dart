import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// Small heading above a group: "Pinned", "Tags", "Linked".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(text, style: context.textStyles.sectionLabel),
    );
  }
}
