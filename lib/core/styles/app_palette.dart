part of 'app_styles.dart';

/// Color roles from product spec §22, for dark and light.
///
/// Read in widgets with `context.colors`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.card,
    required this.text,
    required this.textSecondary,
    required this.accent,
    required this.onAccent,
    required this.accept,
    required this.reject,
    required this.border,
  });

  final Color background;
  final Color card;
  final Color text;
  final Color textSecondary;

  /// Amber: fills, outlines and icons only. Never use it as a text color:
  /// light amber is below 4.5:1 for text. Link labels use [text].
  final Color accent;

  /// Text and icons drawn on top of [accent].
  final Color onAccent;
  final Color accept;
  final Color reject;

  /// Thin subtle border on flat surfaces (not in the spec; chosen to sit
  /// just above the card color).
  final Color border;

  static const dark = AppPalette(
    background: Color(0xFF0B0B0C),
    card: Color(0xFF1A1A1C),
    text: Color(0xFFF2F2F0),
    textSecondary: Color(0xFF9A9A9F),
    accent: Color(0xFFF2B84B),
    onAccent: Color(0xFF0B0B0C),
    accept: Color(0xFF4CAF7A),
    reject: Color(0xFFE5484D),
    border: Color(0xFF2A2A2E),
  );

  static const light = AppPalette(
    background: Color(0xFFF7F6F3),
    card: Color(0xFFFFFFFF),
    text: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF6B6B70),
    accent: Color(0xFFB7791F),
    onAccent: Color(0xFF1A1A1A),
    accept: Color(0xFF4CAF7A),
    reject: Color(0xFFE5484D),
    border: Color(0xFFE4E2DD),
  );

  /// Confirmed link or tag: filled accent chip.
  ChipLook get solidChip =>
      ChipLook(fill: accent, outline: accent, label: onAccent, dashed: false);

  /// AI suggestion: same shape, no fill, dashed outline at the dimmed
  /// opacity. The label keeps full-strength secondary text so it stays
  /// readable (4.5:1); meaning comes from the dashes and dimming, not color.
  ChipLook get dimmedChip => ChipLook(
    fill: Colors.transparent,
    outline: accent.withValues(alpha: AppOpacity.dimmed),
    label: textSecondary,
    dashed: true,
  );

  @override
  AppPalette copyWith({
    Color? background,
    Color? card,
    Color? text,
    Color? textSecondary,
    Color? accent,
    Color? onAccent,
    Color? accept,
    Color? reject,
    Color? border,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      accept: accept ?? this.accept,
      reject: reject ?? this.reject,
      border: border ?? this.border,
    );
  }

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      accept: Color.lerp(accept, other.accept, t)!,
      reject: Color.lerp(reject, other.reject, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}
