import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';
import 'pill_tabs.dart';

/// A Settings choice shown as pills under its label, e.g.
/// "Theme: System | Dark | Light". One tap changes it.
class SettingChoice<T> extends StatelessWidget {
  const SettingChoice({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;

  /// Each value with its label, in order.
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final values = options.keys.toList();
    return Semantics(
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpace.screen,
              child: Text(label, style: context.textStyles.body),
            ),
            const SizedBox(height: AppSpace.s),
            PillTabs(
              labels: options.values.toList(),
              selected: values.indexOf(selected),
              onSelected: (i) => onChanged(values[i]),
            ),
          ],
        ),
      ),
    );
  }
}
