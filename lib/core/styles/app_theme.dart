part of 'app_styles.dart';

/// Theme builders. The app follows the system theme by default.
abstract final class AppTheme {
  static final ThemeData light = _build(AppPalette.light, Brightness.light);
  static final ThemeData dark = _build(AppPalette.dark, Brightness.dark);

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final text = AppTextStyles.forPalette(p);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: _scheme(p, brightness),
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      fontFamily: AppFonts.ui,
      fontFamilyFallback: AppFonts.fallback,
      textTheme: _textTheme(text),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [p, text],
      cardTheme: CardThemeData(
        color: p.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: BorderSide(color: p.border, width: AppBorder.width),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: p.border,
        thickness: AppBorder.width,
        space: AppBorder.width,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          minimumSize: AppSize.tapTarget,
          padding: AppSpace.pill,
          shape: AppRadius.pill,
          textStyle: text.label,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: AppSize.tapTarget,
          shape: AppRadius.pill,
          textStyle: text.label,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.text,
          minimumSize: AppSize.tapTarget,
          iconSize: AppSize.icon,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.sheetBorder,
        ),
        showDragHandle: true,
        dragHandleColor: p.border,
        modalBarrierColor: brightness == Brightness.light
            ? p.text.withValues(alpha: AppOpacity.scrim)
            : null,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: text.body.copyWith(color: p.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.text,
        contentTextStyle: text.label.copyWith(color: p.background),
        actionTextColor: p.background,
        behavior: SnackBarBehavior.floating,
        shape: AppRadius.pill,
        elevation: 0,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.sealSoft,
        selectionHandleColor: p.accent,
      ),
    );
  }

  static ColorScheme _scheme(AppPalette p, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      secondary: p.accent,
      onSecondary: p.onAccent,
      error: p.reject,
      onError: p.onAccent,
      surface: p.card,
      onSurface: p.text,
      onSurfaceVariant: p.textSecondary,
      outline: p.border,
      outlineVariant: p.border,
      surfaceTint: Colors.transparent,
    );
  }

  static TextTheme _textTheme(AppTextStyles t) {
    return TextTheme(
      titleLarge: t.noteTitle,
      titleMedium: t.cardTitle,
      bodyLarge: t.body,
      bodyMedium: t.card,
      bodySmall: t.small,
      labelLarge: t.label,
      labelSmall: t.small,
    );
  }
}
