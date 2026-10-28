import 'package:fasomo/core/theme/app_colors.dart';
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
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colors.onBrand,
      ),
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

// The platform font is used so the app works fully offline and renders
// Arabic with a font that has complete glyph coverage.
TextTheme _textTheme(AppColors colors) {
  const base = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  );
  final themed = base.apply(
    bodyColor: colors.onSurface,
    displayColor: colors.onSurface,
  );
  return themed.copyWith(
    bodyMedium: themed.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
  );
}
