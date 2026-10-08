import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/copy/app_copy.dart';
import '../../core/feedback/motion.dart';
import '../../core/navigation/routes.dart';
import '../../core/styles/app_styles.dart';
import '../../shared/widgets/progress_dots.dart';
import 'state/onboarding_controller.dart';
import 'widgets/onboarding_actions.dart';
import 'widgets/onboarding_page.dart';

/// Onboarding (UI spec §4) as one set of pages with dots: private by
/// design, what it does, how it works, the notes folder (where one can be
/// picked), and the name. Swipe or use the buttons; Skip on the first
/// three goes straight to the folder.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  static const intro = [
    OnboardingPage(
      wordmark: AppCopy.appName,
      title: AppCopy.onboardingPrivateTitle,
      body: AppCopy.onboardingPrivateBody,
    ),
    OnboardingPage(
      title: AppCopy.onboardingWhatTitle,
      body: AppCopy.onboardingWhatBody,
    ),
    OnboardingPage(
      title: AppCopy.onboardingHowTitle,
      body: AppCopy.onboardingHowBody,
    ),
  ];

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();
  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  var _page = 0;
  var _busy = false;

  OnboardingController get _controller =>
      ref.read(onboardingControllerProvider);

  /// The folder page exists only where a folder can be picked (Android).
  late final int? _folderPage = _controller.canChooseFolder
      ? OnboardingScreen.intro.length
      : null;
  late final int _namePage =
      OnboardingScreen.intro.length + (_folderPage == null ? 0 : 1);

  @override
  void dispose() {
    _pages.dispose();
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    final duration = Motion.of(context);
    if (duration == Duration.zero) return _pages.jumpToPage(page);
    _pages.animateToPage(
      page,
      duration: duration,
      curve: AppMotion.standardCurve,
    );
  }

  void _onPage(int page) {
    setState(() => _page = page);
    // The keyboard comes up on the name page only.
    if (page == _namePage) {
      _nameFocus.requestFocus();
    } else {
      _nameFocus.unfocus();
    }
  }

  Future<void> _chooseFolder() async {
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await _controller.chooseFolder() && mounted) _goTo(_namePage);
    } on PlatformException {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppCopy.folderError)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finish({String? name}) async {
    setState(() => _busy = true);
    await _controller.finish(name: name);
    if (mounted) context.go(Routes.home);
  }

  OnboardingActions _actions() {
    if (_page == _folderPage) {
      return OnboardingActions(
        label: AppCopy.chooseFolder,
        onPressed: _busy ? null : _chooseFolder,
        secondLabel: AppCopy.notNow,
        onSecond: _busy ? null : () => _goTo(_namePage),
      );
    }
    if (_page == _namePage) {
      return OnboardingActions(
        label: AppCopy.done,
        onPressed: _busy || _name.text.trim().isEmpty
            ? null
            : () => _finish(name: _name.text),
        secondLabel: AppCopy.skip,
        onSecond: _busy ? null : _finish,
      );
    }
    return OnboardingActions(
      label: AppCopy.next,
      onPressed: () => _goTo(_page + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _namePage + 1;
    final skipTo = _folderPage ?? _namePage;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Skip on the first pages only; the same space stays after,
            // so the pages don't jump.
            Align(
              alignment: Alignment.centerRight,
              child: _page < skipTo
                  ? TextButton(
                      onPressed: () => _goTo(skipTo),
                      child: const Text(AppCopy.skip),
                    )
                  : const SizedBox.square(dimension: AppSize.minTapTarget),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: _onPage,
                children: [
                  for (final page in OnboardingScreen.intro)
                    Center(child: page),
                  if (_folderPage != null)
                    const Center(
                      child: OnboardingPage(
                        title: AppCopy.onboardingFolderTitle,
                        body: AppCopy.onboardingFolderBody,
                      ),
                    ),
                  Center(child: _namePageContent()),
                ],
              ),
            ),
            Center(
              child: ProgressDots(
                done: _page,
                total: total,
                label: AppCopy.onboardingPage(_page + 1, total),
              ),
            ),
            _actions(),
          ],
        ),
      ),
    );
  }

  Widget _namePageContent() => OnboardingPage(
    title: AppCopy.onboardingNameTitle,
    child: TextField(
      controller: _name,
      focusNode: _nameFocus,
      style: context.textStyles.body,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(hintText: AppCopy.nameHint),
      onChanged: (_) => setState(() {}),
      onSubmitted: (v) => _finish(name: v),
    ),
  );
}
