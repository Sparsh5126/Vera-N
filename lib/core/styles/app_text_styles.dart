part of 'app_styles.dart';

/// Bundled font families (see pubspec.yaml). Never fetched at runtime.
abstract final class AppFonts {
  static const ui = 'Inter';
  static const fallback = ['NotoSansDevanagari'];
  static const wordmark = 'InstrumentSerif';
}

/// Text styles from product spec §22. Read with `context.textStyles`.
///
/// Sizes scale with the system text size automatically.
@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.wordmark,
    required this.noteTitle,
    required this.body,
    required this.cardTitle,
    required this.card,
    required this.label,
    required this.small,
    required this.sectionLabel,
  });

  factory AppTextStyles.forPalette(AppPalette p) {
    return AppTextStyles(
      wordmark: TextStyle(
        fontFamily: AppFonts.wordmark,
        fontSize: 28,
        height: 34 / 28,
        color: p.text,
      ),
      noteTitle: _inter(22, 28, FontWeight.w600, p.text),
      body: _inter(16, 24, FontWeight.w400, p.text),
      cardTitle: _inter(15, 22, FontWeight.w600, p.text),
      card: _inter(15, 22, FontWeight.w400, p.text),
      label: _inter(15, 20, FontWeight.w500, p.text),
      small: _inter(12, 16, FontWeight.w400, p.textSecondary),
      sectionLabel: _inter(12, 16, FontWeight.w600, p.textSecondary),
    );
  }

  /// "Vera N" on Home and onboarding only.
  final TextStyle wordmark;
  final TextStyle noteTitle;

  /// Note text: 16 / 24.
  final TextStyle body;
  final TextStyle cardTitle;
  final TextStyle card;

  /// Buttons, pills, tabs.
  final TextStyle label;
  final TextStyle small;

  /// Headings such as "Pinned", "Tags", "Linked".
  final TextStyle sectionLabel;

  /// Link markup kept in the note's text but not shown in the editor
  /// (`[[name|` and `]]`): practically no width, no color.
  static TextStyle hidden(TextStyle base) => base.copyWith(
    fontSize: _hiddenSize,
    color: Colors.transparent,
    letterSpacing: 0,
    decoration: TextDecoration.none,
  );

  static const double _hiddenSize = 0.01;

  /// A link's visible title in the editor: normal text color (amber is
  /// never a text color), with an amber underline.
  static TextStyle link(TextStyle base, AppPalette p) => base.copyWith(
    decoration: TextDecoration.underline,
    decorationColor: p.accent,
    decorationThickness: _linkUnderline,
  );

  static const double _linkUnderline = 2;

  /// Bold text in the editor (`**…**` with the stars hidden).
  static TextStyle strong(TextStyle base) => base.copyWith(
    fontWeight: FontWeight.w700,
    fontVariations: const [FontVariation.weight(700)],
  );

  /// A ticked checklist item: secondary text, struck through.
  static TextStyle done(TextStyle base, AppPalette p) => base.copyWith(
    color: p.textSecondary,
    decoration: TextDecoration.lineThrough,
    decorationColor: p.textSecondary,
  );

  /// Inter is a variable font: the weight axis must be set explicitly.
  static TextStyle _inter(
    double size,
    double lineHeight,
    FontWeight weight,
    Color color,
  ) {
    return TextStyle(
      fontFamily: AppFonts.ui,
      fontFamilyFallback: AppFonts.fallback,
      fontSize: size,
      height: lineHeight / size,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: weight,
      fontVariations: [FontVariation.weight(weight.value.toDouble())],
      color: color,
    );
  }

  @override
  AppTextStyles copyWith({
    TextStyle? wordmark,
    TextStyle? noteTitle,
    TextStyle? body,
    TextStyle? cardTitle,
    TextStyle? card,
    TextStyle? label,
    TextStyle? small,
    TextStyle? sectionLabel,
  }) {
    return AppTextStyles(
      wordmark: wordmark ?? this.wordmark,
      noteTitle: noteTitle ?? this.noteTitle,
      body: body ?? this.body,
      cardTitle: cardTitle ?? this.cardTitle,
      card: card ?? this.card,
      label: label ?? this.label,
      small: small ?? this.small,
      sectionLabel: sectionLabel ?? this.sectionLabel,
    );
  }

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) {
    if (other == null) return this;
    return AppTextStyles(
      wordmark: TextStyle.lerp(wordmark, other.wordmark, t)!,
      noteTitle: TextStyle.lerp(noteTitle, other.noteTitle, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      card: TextStyle.lerp(card, other.card, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      small: TextStyle.lerp(small, other.small, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
    );
  }
}
