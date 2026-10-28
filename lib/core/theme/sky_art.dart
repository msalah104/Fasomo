import 'package:fasomo/core/theme/primitives.dart';
import 'package:flutter/services.dart';

/// The static artwork behind the Home sky header, one per time of day.
///
/// The sky looks the same in the light and dark app themes (it follows the
/// clock, not the theme), so these are fixed tokens rather than `AppColors`
/// slots. Sources live in `design/art/`.
enum SkyArt {
  day(
    image: 'assets/images/sky_day.png',
    logoInk: Primitives.indigo27,
    logoDot: Primitives.gold75,
    ink: Primitives.indigo27,
    groundInk: Primitives.ivory96,
    overlayStyle: SystemUiOverlayStyle.dark,
  ),
  night(
    image: 'assets/images/sky_night.png',
    logoInk: Primitives.gold80,
    logoDot: Primitives.ivory96,
    ink: Primitives.ivory96,
    groundInk: Primitives.ivory96,
    overlayStyle: SystemUiOverlayStyle.light,
  );

  new({
    required this.image,
    required this.logoInk,
    required this.logoDot,
    required this.ink,
    required this.groundInk,
    required this.overlayStyle,
  });

  /// The sky picture, 3:2, with the ground band in its bottom 30%.
  final String image;

  /// The ف letter of the logo mark, in a colour that reads on this sky.
  final Color logoInk;

  /// The new-moon dot of the logo mark.
  final Color logoDot;

  /// Icons and text drawn on the open sky.
  final Color ink;

  /// Text drawn on the dark ground band.
  final Color groundInk;

  /// Status bar icons that read on this sky.
  final SystemUiOverlayStyle overlayStyle;
}
