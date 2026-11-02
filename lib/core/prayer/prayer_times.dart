import 'package:equatable/equatable.dart';

/// The five daily prayers, plus sunrise, which ends the time for Fajr.
enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// Minutes added to (or taken from) each computed time, to match a local
/// timetable. Each is between [min] and [max].
final class PrayerAdjustments extends Equatable {
  const new({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  /// No adjustment.
  static const none = PrayerAdjustments();

  /// The largest adjustment either way, in minutes.
  static const int max = 30;
  static const int min = -max;

  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  /// The minutes for [prayer].
  int operator [](Prayer prayer) => switch (prayer) {
    Prayer.fajr => fajr,
    Prayer.sunrise => sunrise,
    Prayer.dhuhr => dhuhr,
    Prayer.asr => asr,
    Prayer.maghrib => maghrib,
    Prayer.isha => isha,
  };

  /// These adjustments with [prayer] set to [minutes], clamped to
  /// [min]..[max].
  PrayerAdjustments withMinutes(Prayer prayer, int minutes) {
    final value = minutes.clamp(min, max);
    return PrayerAdjustments(
      fajr: prayer == Prayer.fajr ? value : fajr,
      sunrise: prayer == Prayer.sunrise ? value : sunrise,
      dhuhr: prayer == Prayer.dhuhr ? value : dhuhr,
      asr: prayer == Prayer.asr ? value : asr,
      maghrib: prayer == Prayer.maghrib ? value : maghrib,
      isha: prayer == Prayer.isha ? value : isha,
    );
  }

  bool get isNone => this == none;

  @override
  List<Object> get props => [fajr, sunrise, dhuhr, asr, maghrib, isha];
}

/// The prayer times of one local day. Each is a UTC instant on a whole
/// minute (rounded to the nearest, as printed timetables are), or `null`
/// when the sun never reaches the angle that defines it (a polar day or
/// night). Dhuhr, solar noon, always exists.
final class PrayerTimes extends Equatable {
  const new({
    required this.date,
    required this.dhuhr,
    this.fajr,
    this.sunrise,
    this.asr,
    this.maghrib,
    this.isha,
  });

  /// The local calendar day these are for (its year, month and day).
  final DateTime date;
  final DateTime? fajr;
  final DateTime? sunrise;
  final DateTime dhuhr;
  final DateTime? asr;
  final DateTime? maghrib;
  final DateTime? isha;

  /// The time of [prayer].
  DateTime? operator [](Prayer prayer) => switch (prayer) {
    Prayer.fajr => fajr,
    Prayer.sunrise => sunrise,
    Prayer.dhuhr => dhuhr,
    Prayer.asr => asr,
    Prayer.maghrib => maghrib,
    Prayer.isha => isha,
  };

  @override
  List<Object?> get props => [date, fajr, sunrise, dhuhr, asr, maghrib, isha];

  @override
  bool get stringify => true;
}
