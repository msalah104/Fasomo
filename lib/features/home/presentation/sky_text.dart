import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/features/home/domain/entities/day_phase.dart';
import 'package:fasomo/features/home/domain/entities/moon_phase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// A rise or set shown under the sky.
enum SkyEventKind { sunrise, sunset, moonrise }

/// One rise or set and its UTC instant.
final class SkyEventTime {
  const new(this.kind, this.time);

  final SkyEventKind kind;
  final DateTime time;
}

/// The two times under the sky, start side then end side, either of which
/// may be missing on a polar day or night.
///
/// By day: today's sunrise and sunset. By night: the moon's rise (of the
/// moon in the sky, or the next one) and the next sunrise.
(SkyEventTime?, SkyEventTime?) skyEventTimes(SkyScene scene) {
  SkyEventTime? at(SkyEventKind kind, DateTime? time) =>
      time == null ? null : SkyEventTime(kind, time);
  final sun = scene.sun;
  return sun.isUp
      ? (at(SkyEventKind.sunrise, sun.rise), at(SkyEventKind.sunset, sun.set))
      : (
          at(SkyEventKind.moonrise, scene.moon.rise),
          at(SkyEventKind.sunrise, sun.rise),
        );
}

/// Localized sky text. Values become strings only here, at render time.
extension SkyText on AppLocalizations {
  /// "Sunrise 6:04 AM", in the device's time zone and clock format.
  String skyEventLabel(SkyEventTime event, {required bool use24HourClock}) {
    final format = use24HourClock
        ? DateFormat.Hm(localeName)
        : DateFormat.jm(localeName);
    final time = format.format(event.time.toLocal());
    return switch (event.kind) {
      SkyEventKind.sunrise => skySunrise(time),
      SkyEventKind.sunset => skySunset(time),
      SkyEventKind.moonrise => skyMoonrise(time),
    };
  }

  String moonPhaseName(MoonPhaseName name) => switch (name) {
    MoonPhaseName.newMoon => moonNew,
    MoonPhaseName.waxingCrescent => moonWaxingCrescent,
    MoonPhaseName.firstQuarter => moonFirstQuarter,
    MoonPhaseName.waxingGibbous => moonWaxingGibbous,
    MoonPhaseName.fullMoon => moonFull,
    MoonPhaseName.waningGibbous => moonWaningGibbous,
    MoonPhaseName.lastQuarter => moonLastQuarter,
    MoonPhaseName.waningCrescent => moonWaningCrescent,
  };

  /// The place's name: the city, or "My location" for an unnamed fix.
  String placeName(GeoPoint location) =>
      location.city?.nameFor(localeName) ?? locationMyLocation;

  /// What a screen reader says for the painted sky, e.g. "Night. Sky over
  /// Cairo. The moon is up: waxing crescent, 23% lit."
  String skySemanticsLabel(SkyScene scene) {
    final place = placeName(scene.location);
    final moon = scene.moonPhase;
    final phase = moonPhaseName(moon.name);
    final percent = NumberFormat.percentPattern(
      localeName,
    ).format(moon.illuminatedFraction);
    final sentences = [
      switch (scene.dayPhase) {
        DayPhase.night => skyNight,
        DayPhase.goldenHour || DayPhase.day => skyDaytime,
        DayPhase.astronomicalTwilight ||
        DayPhase.nauticalTwilight ||
        DayPhase.civilTwilight => scene.isMorning ? skyDawn : skyDusk,
      },
      if (scene.location.isApproximate)
        skyOverApproximate(place)
      else
        skyOver(place),
      if (scene.sun.isUp) skySunUp,
      if (scene.moon.isUp)
        skyMoonUp(phase, percent)
      else
        skyMoonDown(phase, percent),
    ];
    return '${sentences.join('. ')}.';
  }
}
