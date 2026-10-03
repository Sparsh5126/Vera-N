import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/navigation/routes.dart';
import '../../core/storage/storage_providers.dart';
import '../../core/styles/app_styles.dart';
import '../../shared/widgets/pill_button.dart';
import 'state/onboarding_controller.dart';

/// Onboarding screen 4: "Choose where your notes live" (UI spec §4).
/// Buttons sit at the bottom, in thumb reach.
class OnboardingFolderScreen extends ConsumerStatefulWidget {
  const OnboardingFolderScreen({super.key});

  @override
  ConsumerState<OnboardingFolderScreen> createState() =>
      _OnboardingFolderScreenState();
}

class _OnboardingFolderScreenState
    extends ConsumerState<OnboardingFolderScreen> {
  late final _controller = OnboardingController(ref.read(storageProvider));
  bool _busy = false;

  Future<void> _choose() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await _controller.chooseFolder() && mounted) {
        context.go(Routes.home);
      }
    } on PlatformException {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppCopy.folderError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _notNow() async {
    await _controller.notNow();
    if (mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final styles = context.textStyles;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Semantics(
                header: true,
                child: Text(
                  AppCopy.onboardingFolderTitle,
                  style: styles.noteTitle,
                ),
              ),
              const SizedBox(height: AppSpace.m),
              Text(
                AppCopy.onboardingFolderBody,
                style: styles.body.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              const Spacer(flex: 2),
              PillButton(
                label: AppCopy.chooseFolder,
                onPressed: _busy ? null : _choose,
              ),
              const SizedBox(height: AppSpace.s),
              TextButton(
                onPressed: _busy ? null : _notNow,
                child: const Text(AppCopy.notNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
