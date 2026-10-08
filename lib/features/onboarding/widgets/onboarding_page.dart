import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'privacy_line.dart';

/// One onboarding page: an optional wordmark, a title, a short paragraph,
/// optionally a control below (the name field), and on every page the
/// same privacy line, so it is never in doubt (decided 2026-10-08).
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    this.body,
    this.wordmark,
    this.child,
  });

  final String title;
  final String? body;

  /// "Vera N" in the wordmark font, on the first screen only.
  final String? wordmark;

  /// Below the paragraph, e.g. the name field.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    final wordmark = this.wordmark;
    final child = this.child;
    final body = this.body;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (wordmark != null) ...[
            Text(wordmark, style: styles.wordmark),
            const SizedBox(height: AppSpace.l),
          ],
          Semantics(header: true, child: Text(title, style: styles.noteTitle)),
          if (body != null) ...[
            const SizedBox(height: AppSpace.m),
            Text(
              body,
              style: styles.body.copyWith(color: context.colors.textSecondary),
            ),
          ],
          if (child != null) ...[const SizedBox(height: AppSpace.l), child],
          const SizedBox(height: AppSpace.xl),
          const PrivacyLine(),
        ],
      ),
    );
  }
}
