import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:fasomo/core/theme/primitives.dart';
import 'package:fasomo/core/theme/sky_cycle.dart';
import 'package:flutter/services.dart';

/// The colours of the Home sky for one sun altitude, from bright day through
/// dusk to night. The sky follows the real sun, not the app theme, so these
/// come from the fixed sky tokens rather than `AppColors`.
class SkyPalette extends Equatable {
  const new _({required this.sky, required this.darkness});

  /// Day while the sun is 6° or more up, dusk at −6° (end of civil twilight)
  /// and full night from −18°, blended in between.
  factory forSunAltitude(double degrees) {
    final darkness = switch (degrees) {
      >= 6 => 0.0,
      >= -6 => (6 - degrees) / 12 * 0.5,
      >= -18 => 0.5 + (-6 - degrees) / 12 * 0.5,
      _ => 1.0,
    };
    return SkyPalette._(sky: SkyCycle.at(darkness), darkness: darkness);
  }

  static final day = SkyPalette.forSunAltitude(90);
  static final night = SkyPalette.forSunAltitude(-90);

  final SkyCycle sky;

  /// 0 in full day, 0.5 at dusk, 1 in full night.
  final double darkness;

  /// Whether light ink reads better than dark ink on the top of the sky.
  /// Chosen by contrast rather than a fixed darkness, so text stays legible
  /// through the mid-tones of sunset and dawn.
  bool get _isDark =>
      _contrast(Primitives.ivory96, top) >= _contrast(Primitives.indigo27, top);

  /// How visible the stars are: none until dusk, all by full night.
  double get starAlpha => ((darkness - 0.5) * 2).clamp(0.0, 1.0);

  /// The top of the sky, also used behind the status bar.
  Color get top => sky.top;

  /// The ground band below the skyline.
  Color get ground => sky.ground;

  /// The ف letter of the logo mark: moon gold on a dark sky when it reads
  /// well enough, ivory otherwise.
  Color get logoInk => !_isDark
      ? Primitives.indigo27
      : _contrast(Primitives.gold80, top) >= _graphicContrast
      ? Primitives.gold80
      : Primitives.ivory96;

  /// The new-moon dot of the logo mark.
  Color get logoDot => _isDark ? Primitives.ivory96 : Primitives.gold75;

  /// Icons and text on the open sky.
  Color get ink => _isDark ? Primitives.ivory96 : Primitives.indigo27;

  /// Text on the dark ground band.
  Color get groundInk => Primitives.ivory96;

  SystemUiOverlayStyle get overlayStyle =>
      _isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

  /// WCAG's minimum for graphics and large text.
  static const double _graphicContrast = 3;

  /// The WCAG contrast ratio between two opaque colours.
  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  @override
  List<Object> get props => [darkness];
}
