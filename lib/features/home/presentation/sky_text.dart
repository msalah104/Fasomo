import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Localized text for the sky header.
extension SkyText on AppLocalizations {
  String moonPhaseName(MoonPhaseName name) => switch (name) {
    MoonPhaseName.newMoon => moonNew,
    MoonPhaseName.waxingCrescent => moonWaxingCrescent,
    MoonPhaseName.firstQuarter => moonFirstQuarter,
    MoonPhaseName.waxingGibbous => moonWaxingGibbous,
    MoonPhaseName.full => moonFull,
    MoonPhaseName.waningGibbous => moonWaningGibbous,
    MoonPhaseName.lastQuarter => moonLastQuarter,
    MoonPhaseName.waningCrescent => moonWaningCrescent,
  };

  String clockTime(DateTime time) => DateFormat.jm(localeName).format(time);

  /// Today's sunrise and sunset, e.g. "Sunrise 6:04 AM · Sunset 5:12 PM",
  /// or `null` when the sun doesn't rise or set today.
  String? sunTimes(SkyScene scene) {
    final (rise, set) = (scene.sun.rise, scene.sun.set);
    if (rise == null || set == null) return null;
    return '${sunriseAt(clockTime(rise))} · ${sunsetAt(clockTime(set))}';
  }

  /// What a screen reader says for the painted sky, e.g. "Night. Sunrise
  /// 6:04 AM · Sunset 5:12 PM. Waxing crescent moon, 23% lit", ending with
  /// "Shown for Makkah" until the user shares a location.
  String skyDescription(SkyScene scene) => [
    if (scene.dayPhase.isDaylight) skyDaytime else skyNight,
    ?sunTimes(scene),
    if (scene.moon.isUp)
      moonLit(
        moonPhaseName(scene.moonPhase.name),
        (scene.moonPhase.fraction * 100).round(),
      ),
    if (scene.location.isApproximate) skyOverMakkah,
  ].join('. ');
}
