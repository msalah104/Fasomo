import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/core/theme/app_fonts.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:flutter/material.dart';

/// Builds the Hilal [ThemeData] for [brightness].
///
/// The [ColorScheme] is written out role by role from [AppColors] instead of
/// `ColorScheme.fromSeed`, so every Material widget gets a colour we chose and
/// checked for contrast. Both brightnesses carry the same extensions.
ThemeData buildAppTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark
      ? AppColors.dark
      : AppColors.light;
  const shapes = AppShapes.standard;

  final scheme = ColorScheme(
    brightness: brightness,
    primary: colors.accent,
    onPrimary: colors.onAccent,
    primaryContainer: colors.accentContainer,
    onPrimaryContainer: colors.onAccentContainer,
    // Secondary is the quiet role: widgets use it for supporting text and
    // icons, so it must stay readable on cards.
    secondary: colors.onSurfaceMuted,
    onSecondary: colors.surface,
    secondaryContainer: colors.accentContainer,
    onSecondaryContainer: colors.onAccentContainer,
    tertiary: colors.fastWeekly,
    onTertiary: colors.onFastWeekly,
    error: colors.danger,
    onError: colors.onDanger,
    surface: colors.surface,
    onSurface: colors.onSurface,
    onSurfaceVariant: colors.onSurfaceMuted,
    surfaceContainerLowest: colors.card,
    surfaceContainerLow: colors.card,
    surfaceContainer: colors.card,
    surfaceContainerHigh: colors.card,
    surfaceContainerHighest: colors.hairline,
    outline: colors.onSurfaceMuted,
    outlineVariant: colors.hairline,
    inverseSurface: colors.onSurface,
    onInverseSurface: colors.surface,
    inversePrimary: colors.fastWeekly,
    shadow: colors.brand,
    scrim: colors.brand,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.surface,
    textTheme: _textTheme(colors),
    cardTheme: CardThemeData(
      color: colors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: shapes.cardShape.copyWith(
        side: BorderSide(color: colors.hairline),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: shapes.smallRadius * 1.5),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.brand,
      foregroundColor: colors.onBrand,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _heading(
        size: 20,
        weight: FontWeight.w600,
      ).copyWith(color: colors.onBrand),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.card,
      indicatorColor: colors.accentContainer,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
      shape: shapes.sheetShape,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.card,
      surfaceTintColor: Colors.transparent,
    ),
    iconTheme: IconThemeData(color: colors.accent),
    dividerColor: colors.hairline,
    extensions: [colors, shapes],
  );
}

// Headings (display, headline, title) are set in El Messiri and everything
// else (body, label) in IBM Plex Sans Arabic. Both are bundled, so the app
// renders the same type offline. Slots without a size keep Material's.
TextTheme _textTheme(AppColors colors) {
  final base = TextTheme(
    displayLarge: _heading(size: 32, weight: FontWeight.bold),
    displayMedium: _heading(size: 28, weight: FontWeight.bold),
    displaySmall: _heading(size: 24, weight: FontWeight.bold),
    headlineLarge: _heading(),
    headlineMedium: _heading(size: 20, weight: FontWeight.w600),
    headlineSmall: _heading(),
    titleLarge: _heading(size: 18, weight: FontWeight.w600),
    titleMedium: _heading(size: 16, weight: FontWeight.w500),
    titleSmall: _heading(),
    bodyLarge: _body(size: 16),
    bodyMedium: _body(size: 14),
    bodySmall: _body(),
    labelLarge: _body(),
    labelMedium: _body(),
    labelSmall: _body(),
  );
  final themed = base.apply(
    bodyColor: colors.onSurface,
    displayColor: colors.onSurface,
  );
  return themed.copyWith(
    bodyMedium: themed.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
  );
}

TextStyle _heading({double? size, FontWeight? weight}) => TextStyle(
  fontFamily: AppFonts.heading,
  fontFamilyFallback: AppFonts.headingFallback,
  fontSize: size,
  fontWeight: weight,
);

TextStyle _body({double? size}) =>
    TextStyle(fontFamily: AppFonts.body, fontSize: size);
