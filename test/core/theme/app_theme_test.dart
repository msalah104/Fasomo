import 'dart:math' as math;

import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/core/theme/app_fonts.dart';
import 'package:fasomo/core/theme/app_shapes.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.2 contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const variants = {'light': AppColors.light, 'dark': AppColors.dark};

  for (final MapEntry(key: name, value: c) in variants.entries) {
    group('$name palette', () {
      // Text pairs need 4.5:1 (WCAG AA, body text).
      final textPairs = <String, (Color, Color)>{
        'onSurface/surface': (c.onSurface, c.surface),
        'onSurface/card': (c.onSurface, c.card),
        'onSurfaceMuted/surface': (c.onSurfaceMuted, c.surface),
        'onSurfaceMuted/card': (c.onSurfaceMuted, c.card),
        'onBrand/brand': (c.onBrand, c.brand),
        'onAccent/accent': (c.onAccent, c.accent),
        'onAccentContainer/accentContainer': (
          c.onAccentContainer,
          c.accentContainer,
        ),
        'onDanger/danger': (c.onDanger, c.danger),
        'danger/card': (c.danger, c.card),
        'onSurface/whiteDays fill': (
          c.onSurface,
          FastingType.whiteDays.fill(c),
        ),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in textPairs.entries) {
        test('$label passes 4.5:1', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
        });
      }

      // Fasting icons sit on their colour: non-text UI needs 3:1.
      for (final type in FastingType.values) {
        test('${type.name} icon passes 3:1 on its colour', () {
          expect(
            contrast(type.onColor(c), type.color(c)),
            greaterThanOrEqualTo(3),
          );
        });
      }
    });
  }

  for (final brightness in Brightness.values) {
    test(
      '${brightness.name} theme carries both extensions and its palette',
      () {
        final theme = buildAppTheme(brightness);
        final colors = theme.extension<AppColors>();
        final expected = brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light;

        expect(colors, same(expected));
        expect(theme.extension<AppShapes>(), isNotNull);
        expect(theme.colorScheme.brightness, brightness);
        expect(theme.colorScheme.primary, expected.accent);
        expect(theme.colorScheme.surface, expected.surface);
        expect(theme.scaffoldBackgroundColor, expected.surface);
      },
    );
  }

  for (final brightness in Brightness.values) {
    group('${brightness.name} typography', () {
      final theme = buildAppTheme(brightness);
      final t = theme.textTheme;

      final headings = <String, TextStyle?>{
        'displayLarge': t.displayLarge,
        'displayMedium': t.displayMedium,
        'displaySmall': t.displaySmall,
        'headlineLarge': t.headlineLarge,
        'headlineMedium': t.headlineMedium,
        'headlineSmall': t.headlineSmall,
        'titleLarge': t.titleLarge,
        'titleMedium': t.titleMedium,
        'titleSmall': t.titleSmall,
        'appBar title': theme.appBarTheme.titleTextStyle,
      };
      for (final MapEntry(key: slot, value: style) in headings.entries) {
        test('$slot is El Messiri, backed by IBM Plex Sans Arabic', () {
          expect(style?.fontFamily, AppFonts.heading);
          expect(style?.fontFamilyFallback, AppFonts.headingFallback);
        });
      }

      final bodies = <String, TextStyle?>{
        'bodyLarge': t.bodyLarge,
        'bodyMedium': t.bodyMedium,
        'bodySmall': t.bodySmall,
        'labelLarge': t.labelLarge,
        'labelMedium': t.labelMedium,
        'labelSmall': t.labelSmall,
      };
      for (final MapEntry(key: slot, value: style) in bodies.entries) {
        test('$slot is IBM Plex Sans Arabic', () {
          expect(style?.fontFamily, AppFonts.body);
        });
      }

      test('sizes and weights survive the family change', () {
        expect(t.displayLarge?.fontSize, 32);
        expect(t.displayLarge?.fontWeight, FontWeight.bold);
        expect(t.titleMedium?.fontWeight, FontWeight.w500);
        expect(t.bodyMedium?.fontSize, 14);
      });

      // MaterialApp merges in per-script geometry (Arabic is "tall"); our
      // families must survive it, and unsized slots pick up Material's sizes.
      final geometries = {
        'englishLike': theme.typography.englishLike,
        'tall': theme.typography.tall,
      };
      for (final MapEntry(key: name, value: geometry) in geometries.entries) {
        test('families survive localisation to $name geometry', () {
          final localized = ThemeData.localize(theme, geometry).textTheme;
          expect(localized.headlineSmall?.fontFamily, AppFonts.heading);
          expect(localized.headlineSmall?.fontSize, isNotNull);
          expect(localized.labelLarge?.fontFamily, AppFonts.body);
          expect(localized.labelLarge?.fontSize, isNotNull);
        });
      }
    });
  }

  test('lerp reaches each end exactly', () {
    const light = AppColors.light;
    const dark = AppColors.dark;
    expect(light.lerp(dark, 0).fastWeekly, light.fastWeekly);
    expect(light.lerp(dark, 1).fastWeekly, dark.fastWeekly);
    expect(light.lerp(dark, 1).tintOpacity, dark.tintOpacity);
  });
}
