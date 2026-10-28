import 'dart:math' as math;

import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_style.dart';
import 'package:fasomo/core/theme/app_colors.dart';
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

  test('lerp reaches each end exactly', () {
    const light = AppColors.light;
    const dark = AppColors.dark;
    expect(light.lerp(dark, 0).fastWeekly, light.fastWeekly);
    expect(light.lerp(dark, 1).fastWeekly, dark.fastWeekly);
    expect(light.lerp(dark, 1).tintOpacity, dark.tintOpacity);
  });
}
