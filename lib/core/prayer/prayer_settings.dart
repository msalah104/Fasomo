import 'package:equatable/equatable.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_time_calculator.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';

/// How the user wants prayer times worked out.
final class PrayerSettings extends Equatable {
  const new({
    this.method,
    this.asrMethod = AsrMethod.standard,
    this.highLatitudeRule = HighLatitudeRule.middleOfTheNight,
    this.adjustments = PrayerAdjustments.none,
  });

  /// Automatic method, Standard Asr, middle of the night, no adjustments.
  static const defaults = PrayerSettings();

  /// The chosen method, or `null` for the default of the location's country.
  final CalculationMethod? method;
  final AsrMethod asrMethod;
  final HighLatitudeRule highLatitudeRule;
  final PrayerAdjustments adjustments;

  /// Whether the method follows the location's country.
  bool get isAutomatic => method == null;

  /// The method in use at [location]: the chosen one, or its country's.
  CalculationMethod methodAt(GeoPoint location) =>
      method ?? CalculationMethod.forCountry(location.city?.countryCode);

  /// The prayer times of the local day [date] at [location].
  PrayerTimes timesOn(
    DateTime date,
    GeoPoint location, {
    required bool inRamadan,
  }) => PrayerTimeCalculator.compute(
    date,
    latitude: location.latitude,
    longitude: location.longitude,
    method: methodAt(location),
    asrMethod: asrMethod,
    highLatitudeRule: highLatitudeRule,
    adjustments: adjustments,
    inRamadan: inRamadan,
  );

  /// These settings with [method] chosen; `null` makes it automatic.
  PrayerSettings withMethod(CalculationMethod? method) => PrayerSettings(
    method: method,
    asrMethod: asrMethod,
    highLatitudeRule: highLatitudeRule,
    adjustments: adjustments,
  );

  PrayerSettings copyWith({
    AsrMethod? asrMethod,
    HighLatitudeRule? highLatitudeRule,
    PrayerAdjustments? adjustments,
  }) => PrayerSettings(
    method: method,
    asrMethod: asrMethod ?? this.asrMethod,
    highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
    adjustments: adjustments ?? this.adjustments,
  );

  @override
  List<Object?> get props => [method, asrMethod, highLatitudeRule, adjustments];
}
