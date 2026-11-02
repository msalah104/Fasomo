import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_rules.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/ramadan_dates.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';

/// Where "now" stands relative to Ramadan, with today's prayer times and
/// the next suhoor end or iftar during it.
///
/// Dates go through the adjusted Hijri calendar, times through the saved
/// prayer settings (the defaults if they can't be read) at the saved
/// location. Never fails: outside the supported calendar it is
/// [RamadanNotNear].
class GetRamadanOverview implements UseCase<RamadanOverview, NoParams> {
  const new({
    required this.calendar,
    required this.prayerSettings,
    required this.locationRepository,
    required this.clock,
  });

  final FastingCalendar calendar;
  final PrayerSettingsRepository prayerSettings;
  final LocationRepository locationRepository;
  final Clock clock;

  @override
  RamadanOverview call(NoParams params) {
    final now = clock.now();
    final today = CalendarDays.dateOnly(now);
    final converter = calendar.converter;
    if (!converter.supportsGregorian(today)) return const RamadanNotNear();

    final settings = switch (prayerSettings.getSettings()) {
      Ok(:final value) => value,
      Err() => PrayerSettings.defaults,
    };
    final location = locationRepository.current();
    final hijri = converter.toHijri(today);
    if (hijri.month == FastingRules.ramadan) {
      return _day(now, today, hijri, settings, location);
    }

    final start = nextRamadanStart(calendar, hijri);
    if (start == null) return const RamadanNotNear();
    final daysUntil = CalendarDays.between(today, start);
    if (daysUntil < 1 || daysUntil > RamadanOverview.countdownDays) {
      return const RamadanNotNear();
    }
    return RamadanCountdown(
      daysUntil: daysUntil,
      startDate: start,
      firstSuhoorEnds: daysUntil == 1
          ? settings.timesOn(start, location, inRamadan: true).fajr
          : null,
    );
  }

  RamadanDay _day(
    DateTime now,
    DateTime today,
    HijriDate hijri,
    PrayerSettings settings,
    GeoPoint location,
  ) {
    final times = settings.timesOn(today, location, inRamadan: true);
    final daysInMonth = calendar.converter.daysInMonth(hijri.hijriMonth);

    FastingMoment? upcoming(FastingMomentKind kind, DateTime? at) =>
        at != null && at.isAfter(now)
        ? FastingMoment(kind: kind, at: at, remaining: at.difference(now))
        : null;

    var next =
        upcoming(FastingMomentKind.suhoorEnds, times.fajr) ??
        upcoming(FastingMomentKind.iftar, times.maghrib);
    // After iftar, tomorrow's suhoor, unless today was the last day.
    if (next == null && hijri.day < daysInMonth) {
      final tomorrow = CalendarDays.addDays(today, 1);
      next = upcoming(
        FastingMomentKind.suhoorEnds,
        settings.timesOn(tomorrow, location, inRamadan: true).fajr,
      );
    }

    return RamadanDay(
      date: today,
      hijriDate: hijri,
      daysInMonth: daysInMonth,
      times: times,
      location: location,
      method: settings.methodAt(location),
      next: next,
    );
  }
}
