import 'package:flutter/material.dart';

import '../../../core/styles/app_styles.dart';
import 'onboarding_art.dart';
import 'onboarding_art_kind.dart';
import 'privacy_line.dart';

/// One onboarding page: a line illustration, an optional wordmark, a
/// title, a short paragraph, optionally a control below (the name field),
/// and on every page the same privacy line, so it is never in doubt
/// (decided 2026-10-08). The illustration steps aside while the keyboard
/// is up, so the field stays in view.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.title,
    this.art,
    this.body,
    this.wordmark,
    this.child,
  });

  final String title;
  final OnboardingArtKind? art;
  final String? body;

  /// "Vera N" in the wordmark font, on the first screen only.
  final String? wordmark;

  /// Below the paragraph, e.g. the name field.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final art = this.art;
    // The Scaffold takes the keyboard out of the MediaQuery it gives its
    // body (it shrinks the body instead), so the keyboard is read from the
    // view itself. The LayoutBuilder rebuilds this when the body shrinks.
    return LayoutBuilder(
      builder: (context, _) => _content(
        context,
        art: View.of(context).viewInsets.bottom > 0 ? null : art,
      ),
    );
  }

  Widget _content(BuildContext context, {OnboardingArtKind? art}) {
    final styles = context.textStyles;
    final wordmark = this.wordmark;
    final child = this.child;
    final body = this.body;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (art != null) ...[
            OnboardingArt(art),
            const SizedBox(height: AppSpace.xl),
          ],
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
