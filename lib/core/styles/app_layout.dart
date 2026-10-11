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

  /// Margin of a floating message on tab screens, so the floating nav bar
  /// never covers it.
  static const EdgeInsets aboveNavBar = EdgeInsets.only(
    left: m,
    right: m,
    bottom: AppSize.navBarClearance,
  );

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

  /// The main choice buttons on the Review screen: larger, in thumb reach.
  static const double xlTapTarget = 64;
  static const double icon = 24;
  static const double iconSmall = 20;

  /// Note card in the Home grid and pinned row, before text scaling.
  static const double noteCardHeight = 168;
  static const double pinnedCardWidth = 168;

  /// Note card in the Home list layout, before text scaling.
  static const double noteRowHeight = 112;

  /// Space a checkbox or bullet takes at the start of a list line in the
  /// editor. The checkbox is tappable across this width and the line's
  /// height (an inline glyph can't reach the 48 minimum without spreading
  /// every list line apart).
  static const double glyphWidth = 32;

  /// Attachments in a note: the side of the rounded square a photo or
  /// drawing is shown in, and the drawing pen's width.
  static const double embedSize = 220;
  static const double drawingStroke = 3;

  /// Widest a link card grows inside a note (it fills narrower screens).
  static const double linkCardWidth = 360;

  /// Lines a link card's title and description show before "…".
  static const int linkTitleLines = 2;
  static const int linkDescriptionLines = 3;

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

  /// Graph dots: the radius of a note with one link, how much each further
  /// link adds, and the largest a dot grows.
  static const double graphDot = 6;
  static const double graphDotStep = 1.5;
  static const double graphDotMax = 18;

  /// Graph lines (confirmed links).
  static const double graphLine = 1.5;

  /// Room each note gets in the graph before zooming.
  static const double graphSpacing = 110;

  /// Zoom from which note titles appear next to their dots.
  static const double graphTitleZoom = 1.4;

  /// Folder bubbles (very large libraries): the smallest and largest
  /// radius, and the room each bubble gets.
  static const double graphBubbleMin = 28;
  static const double graphBubbleMax = 64;
  static const double graphBubbleSpacing = 168;

  /// Graph zoom limits.
  static const double graphMinZoom = 0.3;
  static const double graphMaxZoom = 4;

  /// Wide windows (a laptop, docs/LAPTOP_PLAN.md L1): from this width the
  /// sidebar replaces the pill bar and a note opens beside the list.
  static const double wideLayout = 900;
  static const double sidebarWidth = 240;
  static const double listPaneWidth = 400;

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
  /// Fades a mark while it is being dragged (Review's faint ✓ / ✕).
  static const double dimmed = 0.55;

  /// The ink veil behind sheets in light, so the near-white page stays
  /// pale instead of turning mid-grey (Material 3 scrim level).
  static const double scrim = 0.32;

  /// The light amber wash inside a Graph folder bubble.
  static const double bubbleFill = 0.16;
}

/// Which layout a window gets (docs/LAPTOP_PLAN.md, L1).
abstract final class AppBreakpoints {
  /// Sidebar and two panes instead of the phone's single column.
  static bool wide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppSize.wideLayout;
}
