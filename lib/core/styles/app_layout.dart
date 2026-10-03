part of 'app_styles.dart';

/// 8-point spacing grid. [xs] is the one half-step, for tight icon gaps.
abstract final class AppSpace {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Side margin of every screen.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: m);

  /// Inner padding of cards.
  static const EdgeInsets card = EdgeInsets.all(m);

  /// Horizontal padding inside pills and buttons.
  static const EdgeInsets pill = EdgeInsets.symmetric(horizontal: l);
}

/// Corner radii. Buttons, tabs, chips and the nav bar are fully rounded.
abstract final class AppRadius {
  static const double card = 24;
  static const BorderRadius cardBorder = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius sheetBorder = BorderRadius.vertical(
    top: Radius.circular(card),
  );
  static const OutlinedBorder pill = StadiumBorder();

  /// Text fields drawn as pills (half of the tap-target height).
  static const BorderRadius fieldBorder = BorderRadius.all(
    Radius.circular(AppSize.minTapTarget / 2),
  );
}

/// Fixed sizes.
abstract final class AppSize {
  /// Minimum tap target on every interactive element.
  static const double minTapTarget = 48;
  static const Size tapTarget = Size(minTapTarget, minTapTarget);
  static const double icon = 24;
  static const double iconSmall = 20;

  /// Note card in the Home grid and pinned row, before text scaling.
  static const double noteCardHeight = 168;
  static const double pinnedCardWidth = 168;

  /// Widest a tag, folder or link chip grows before its label is cut
  /// with "…" (a note's title is its whole first line).
  static const double chipMaxWidth = 240;

  /// Where a card preview starts fading out, as a fraction of its height.
  static const double previewFadeStart = 0.6;

  /// Soft fade above the floating controls at the bottom of Home.
  static const double bottomFade = 96;

  /// Floating pill navigation bar (Home | Search | …).
  static const double navBarHeight = 64;

  /// Width of each icon pill in the nav bar (wider than tall, so the
  /// selected one reads as a pill, not a circle).
  static const double navItemWidth = 64;

  /// Space kept under scrolling content so the nav bar and the floating
  /// "New note" button never cover the last card.
  static const double floatingClearance = 168;

  /// Space under lists on screens with the nav bar but no floating button.
  static const double navBarClearance = 96;

  /// Widest a column of text grows on large screens.
  static const double readableWidth = 680;
}

/// Borders: flat surfaces with a thin line, no shadows.
abstract final class AppBorder {
  static const double width = 1;

  /// Dashed outline of dimmed (suggested) chips.
  static const double dashLength = 4;
  static const double dashGap = 3;
}

/// Opacities.
abstract final class AppOpacity {
  /// AI suggestions: always paired with a dashed outline.
  static const double dimmed = 0.55;

  /// Text selection highlight.
  static const double selection = 0.35;

  /// Matched words in search results (amber fill behind normal text).
  static const double searchMatch = 0.35;
}
