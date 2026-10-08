part of 'app_styles.dart';

/// Color roles from product spec §22, for dark and light.
///
/// The world (2026-10-08): a design annual's plate section. Notes are
/// plates on uncoated stock ruled by hairlines, the user's words are ink
/// (never pure black or white), and the only hue is a quiet periwinkle
/// seal that the AI uses to sign its suggestions. Flat: no gradients,
/// glows, shadows or texture. Dark is the same section printed on black
/// stock, composed rather than inverted.
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
    required this.seal,
    required this.sealSoft,
    required this.accept,
    required this.reject,
    required this.border,
    required this.folder,
  });

  /// The stock: the screen's ground.
  final Color background;

  /// Plates (cards, sheets), a shade warmer than the stock in both
  /// themes (dark cards in the ivory family, never cool graphite).
  final Color card;

  /// Ink: the user's words and every label.
  final Color text;
  final Color textSecondary;

  /// The solid ink plate: the primary action, the chosen tab or filter,
  /// confirmed chips, the caret. Ink in light, ivory in dark.
  final Color accent;

  /// Text and icons drawn on top of [accent].
  final Color onAccent;

  /// The AI's seal: only for suggestions (dashed outlines, the waiting
  /// dot, the connections mark, graph suggestion lines). Never on
  /// anything the user confirmed.
  final Color seal;

  /// The seal pressed lightly into the stock: matched and selected text.
  final Color sealSoft;

  /// Bottle green: confirms.
  final Color accept;

  /// Vermilion: strikes (reject, delete forever).
  final Color reject;

  /// 1px hairline that rules plates and outlined controls.
  final Color border;

  /// Amber, the folder color: only the Graph's dots while a Folder filter
  /// is on (UI spec §10; amber chosen by the user, 2026-10-08). Fills and
  /// marks only, never text (light amber is 3.3:1).
  final Color folder;

  static const dark = AppPalette(
    background: Color(0xFF121315),
    card: Color(0xFF1C1B19),
    text: Color(0xFFECEBE8),
    textSecondary: Color(0xFFA2A2AA),
    accent: Color(0xFFECEBE8),
    onAccent: Color(0xFF121315),
    seal: Color(0xFFA7AAE8),
    sealSoft: Color(0xFF34365A),
    accept: Color(0xFF6CBF96),
    reject: Color(0xFFE8806F),
    border: Color(0xFF393834),
    folder: Color(0xFFF2B84B),
  );

  static const light = AppPalette(
    background: Color(0xFFF5F4F6),
    card: Color(0xFFFAF9F7),
    text: Color(0xFF16181A),
    textSecondary: Color(0xFF5C5E66),
    accent: Color(0xFF16181A),
    onAccent: Color(0xFFF5F4F6),
    seal: Color(0xFF6266B0),
    sealSoft: Color(0xFFDCDDF3),
    accept: Color(0xFF2D6A4F),
    reject: Color(0xFFB4382D),
    border: Color(0xFFC9C7C4),
    folder: Color(0xFFB7791F),
  );

  /// Confirmed link or tag: a solid ink plate.
  ChipLook get solidChip =>
      ChipLook(fill: accent, outline: accent, label: onAccent, dashed: false);

  /// AI suggestion: same shape, no fill, a dashed seal outline. "Dimmed"
  /// is carried by the empty fill and the secondary label, not by fading
  /// the dashes: on thin strokes a faded seal measured 2.1:1 in light and
  /// read grey in dark (finish review, 2026-10-08). The dashes keep at
  /// least 3:1, so meaning never relies on color.
  ChipLook get dimmedChip => ChipLook(
    fill: Colors.transparent,
    outline: seal,
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
    Color? seal,
    Color? sealSoft,
    Color? accept,
    Color? reject,
    Color? border,
    Color? folder,
  }) {
    return AppPalette(
      background: background ?? this.background,
      card: card ?? this.card,
      text: text ?? this.text,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      seal: seal ?? this.seal,
      sealSoft: sealSoft ?? this.sealSoft,
      accept: accept ?? this.accept,
      reject: reject ?? this.reject,
      border: border ?? this.border,
      folder: folder ?? this.folder,
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
      seal: Color.lerp(seal, other.seal, t)!,
      sealSoft: Color.lerp(sealSoft, other.sealSoft, t)!,
      accept: Color.lerp(accept, other.accept, t)!,
      reject: Color.lerp(reject, other.reject, t)!,
      border: Color.lerp(border, other.border, t)!,
      folder: Color.lerp(folder, other.folder, t)!,
    );
  }
}
