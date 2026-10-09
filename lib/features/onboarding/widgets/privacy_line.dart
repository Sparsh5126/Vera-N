import 'package:flutter/material.dart';

import '../../../core/copy/app_copy.dart';
import '../../../core/platform/device_kind.dart';
import '../../../core/styles/app_styles.dart';

/// "Private · Open source · On this phone · No account · No cloud", with a
/// lock, at the foot of every onboarding page.
class PrivacyLine extends StatelessWidget {
  const PrivacyLine({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpace.s,
      children: [
        Icon(
          Icons.lock_outline,
          size: AppSize.iconSmall,
          color: colors.textSecondary,
        ),
        Expanded(
          child: Text(
            DeviceKind.isDesktop
                ? OnboardingCopy.privacyLineDesktop
                : OnboardingCopy.privacyLine,
            style: context.textStyles.small,
          ),
        ),
      ],
    );
  }
}
