import 'package:flutter/material.dart';

import '../../core/styles/app_styles.dart';

/// A bottom sheet for typing a short name (a tag, a folder), with matching
/// existing names offered below so the user reuses them before inventing
/// near-duplicates. Pops with the text or the picked suggestion.
class TextEntrySheet extends StatefulWidget {
  const TextEntrySheet({
    super.key,
    required this.hint,
    required this.suggestions,
    this.labelFor,
  });

  /// Shows the sheet above the nav bar; null if dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String hint,
    List<String> suggestions = const [],
    String Function(String)? labelFor,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => TextEntrySheet(
        hint: hint,
        suggestions: suggestions,
        labelFor: labelFor,
      ),
    );
  }

  final String hint;
  final List<String> suggestions;

  /// How a suggestion is shown (e.g. with a `#`).
  final String Function(String)? labelFor;

  @override
  State<TextEntrySheet> createState() => _TextEntrySheetState();
}

class _TextEntrySheetState extends State<TextEntrySheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _done(String value) {
    if (value.trim().isNotEmpty) Navigator.of(context).pop(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final typed = _text.text.trim().toLowerCase();
    final matches = widget.suggestions
        .where((s) => s.toLowerCase().contains(typed))
        .toList();
    final label = widget.labelFor ?? (s) => s;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpace.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: AppSpace.screen,
            child: TextField(
              controller: _text,
              autofocus: true,
              style: context.textStyles.body,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(hintText: widget.hint),
              onChanged: (_) => setState(() {}),
              onSubmitted: _done,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final s in matches)
                  ListTile(
                    title: Text(label(s), style: context.textStyles.body),
                    onTap: () => Navigator.of(context).pop(s),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
