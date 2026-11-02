part of 'prayer_settings_bloc.dart';

class PrayerSettingsState extends Equatable {
  const new({required this.settings, required this.location, this.failure});

  final PrayerSettings settings;

  /// Where the times are for; its country decides the automatic method.
  final GeoPoint location;

  /// Set when the last change could not be saved.
  final StorageFailure? failure;

  /// The method the times are computed with now.
  CalculationMethod get methodInUse => settings.methodAt(location);

  PrayerSettingsState copyWith({GeoPoint? location, StorageFailure? failure}) =>
      PrayerSettingsState(
        settings: settings,
        location: location ?? this.location,
        failure: failure,
      );

  @override
  List<Object?> get props => [settings, location, failure];
}
