import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/styles/app_styles.dart';

/// The pill-shaped search box. The keyboard opens as soon as Search opens.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final outline = OutlineInputBorder(
      borderRadius: AppRadius.fieldBorder,
      borderSide: BorderSide(color: colors.border, width: AppBorder.width),
    );
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
      style: context.textStyles.body,
      decoration: InputDecoration(
        hintText: AppCopy.searchHint,
        filled: true,
        fillColor: colors.card,
        prefixIcon: Icon(Icons.search, color: colors.textSecondary),
        suffixIcon: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: onClear,
                  tooltip: AppCopy.clearSearch,
                  icon: Icon(Icons.close, color: colors.textSecondary),
                ),
        ),
        border: outline,
        enabledBorder: outline,
        focusedBorder: outline.copyWith(
          borderSide: BorderSide(color: colors.accent, width: AppBorder.width),
        ),
      ),
    );
  }
}
