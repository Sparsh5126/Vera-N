import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';
import 'empty_state.dart';

/// One choice in an [OptionSheet].
@immutable
class SheetOption<T> {
  const SheetOption(this.value, this.label);

  /// Null is the "clear" choice (e.g. "Any folder").
  final T? value;
  final String label;
}

/// A bottom sheet with one choice per row; the current one has a tick.
/// Pops with the chosen [SheetOption], or null if dismissed.
class OptionSheet<T> extends StatelessWidget {
  const OptionSheet({
    super.key,
    required this.options,
    required this.selected,
    this.emptyMessage,
  });

  /// Shows the sheet and returns the chosen option, or null if dismissed.
  static Future<SheetOption<T>?> show<T>(
    BuildContext context, {
    required List<SheetOption<T>> options,
    required T? selected,
    String? emptyMessage,
  }) {
    return showModalBottomSheet<SheetOption<T>>(
      context: context,
      // Above the floating nav bar, which would otherwise cover its rows.
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => OptionSheet<T>(
        options: options,
        selected: selected,
        emptyMessage: emptyMessage,
      ),
    );
  }

  final List<SheetOption<T>> options;
  final T? selected;

  /// Shown under the "clear" row when there is nothing else to pick.
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    final message = emptyMessage;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(bottom: AppSpace.l),
      children: [
        for (final option in options) _row(context, option),
        if (options.length <= 1 && message != null)
          EmptyState(message: message),
      ],
    );
  }

  Widget _row(BuildContext context, SheetOption<T> option) {
    final isSelected = option.value == selected;
    return ListTile(
      title: Text(option.label, style: context.textStyles.body),
      trailing: isSelected
          ? Icon(Icons.check, color: context.colors.text)
          : null,
      selected: isSelected,
      // Amber is never a text color; the tick marks the choice.
      selectedColor: context.colors.text,
      onTap: () => Navigator.of(context).pop(option),
    );
  }
}
