part of 'prayer_settings_bloc.dart';

sealed class PrayerSettingsEvent extends Equatable {
  const new();

  @override
  List<Object?> get props => [];
}

/// Re-reads the location, which decides the automatic method.
final class PrayerSettingsRefreshed extends PrayerSettingsEvent {
  const new();
}

/// Reads the saved settings and location again, e.g. after a restore.
final class PrayerSettingsReloaded extends PrayerSettingsEvent {
  const new();
}

/// The user chose [method], or automatic when it is `null`.
final class PrayerMethodChanged extends PrayerSettingsEvent {
  const new(this.method);

  final CalculationMethod? method;

  @override
  List<Object?> get props => [method];
}

final class AsrMethodChanged extends PrayerSettingsEvent {
  const new(this.asrMethod);

  final AsrMethod asrMethod;

  @override
  List<Object?> get props => [asrMethod];
}

final class HighLatitudeRuleChanged extends PrayerSettingsEvent {
  const new(this.rule);

  final HighLatitudeRule rule;

  @override
  List<Object?> get props => [rule];
}

/// Sets [prayer]'s adjustment to [minutes] (clamped to ±30).
final class PrayerAdjustmentChanged extends PrayerSettingsEvent {
  const new(this.prayer, this.minutes);

  final Prayer prayer;
  final int minutes;

  @override
  List<Object?> get props => [prayer, minutes];
}

/// Sets every adjustment back to zero.
final class PrayerAdjustmentsReset extends PrayerSettingsEvent {
  const new();
}
