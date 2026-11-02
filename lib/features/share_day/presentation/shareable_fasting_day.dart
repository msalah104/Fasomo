import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';

/// A hadith quoted on a shared day, already in display form. It comes from
/// outside this feature (the app shell reads it from the duas feature).
class SharedHadith extends Equatable {
  const new({
    required this.arabic,
    required this.translation,
    required this.reference,
  });

  /// The original Arabic, shown in every language.
  final String arabic;

  /// English meaning, shown when the app is not in Arabic.
  final String translation;

  /// Localized reference, e.g. "Sahih Muslim 1162".
  final String reference;

  @override
  List<Object> get props => [arabic, translation, reference];
}

/// What a shared fasting day shows.
class ShareableFastingDay extends Equatable {
  const new({
    required this.type,
    required this.hijriDate,
    required this.gregorianDate,
    required this.daysUntil,
    this.hadith,
  });

  /// The day's primary type.
  final FastingType type;
  final HijriDate hijriDate;

  /// Local midnight of the Gregorian day.
  final DateTime gregorianDate;

  /// Calendar days from today: 0 today, 1 tomorrow, negative in the past.
  final int daysUntil;
  final SharedHadith? hadith;

  /// An ASCII file name, e.g. `fasomo-arafah-2027-05-16.png`.
  String get fileName {
    String two(int value) => value.toString().padLeft(2, '0');
    final date = gregorianDate;
    return 'fasomo-${type.name}-${date.year}-${two(date.month)}-'
        '${two(date.day)}.png';
  }

  @override
  List<Object?> get props => [
    type,
    hijriDate,
    gregorianDate,
    daysUntil,
    hadith,
  ];
}
