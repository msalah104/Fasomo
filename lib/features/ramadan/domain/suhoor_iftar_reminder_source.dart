import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_source.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_settings_repository.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/repositories/suhoor_iftar_settings_repository.dart';

/// The suhoor and iftar reminders: on each day of Ramadan (and, if chosen,
/// each recommended fasting day) in the horizon, one before Fajr and one
/// at or before Maghrib, from that day's prayer times at the saved
/// location.
///
/// The fire time is resolved to the local minute here, on every sync, so a
/// new location, prayer setting or time zone applies at the next one.
class SuhoorIftarReminderSource implements ReminderSource {
  const new({
    required this.settings,
    required this.prayerSettings,
    required this.locationRepository,
    required this.calendar,
  });

  final SuhoorIftarSettingsRepository settings;
  final PrayerSettingsRepository prayerSettings;
  final LocationRepository locationRepository;
  final FastingCalendar calendar;

  @override
  Result<List<ReminderOccurrence>, Failure> occurrences({
    required DateTime today,
    required int horizonDays,
  }) {
    final SuhoorIftarSettings reminders;
    switch (settings.getSettings()) {
      case Ok(:final value):
        reminders = value;
      case Err(:final failure):
        return Err(failure);
    }
    if (!reminders.anyEnabled) return const Ok([]);

    // Unreadable prayer settings fall back to the defaults, as the Ramadan
    // card does, so the reminders still match what the card shows.
    final prayer = switch (prayerSettings.getSettings()) {
      Ok(:final value) => value,
      Err() => PrayerSettings.defaults,
    };
    final location = locationRepository.current();
    return Ok([
      for (var offset = 0; offset < horizonDays; offset++)
        if (calendar.dayInfo(CalendarDays.addDays(today, offset))
            case final day?)
          ..._forDay(day, reminders, prayer, location),
    ]);
  }

  static Iterable<SuhoorIftarOccurrence> _forDay(
    FastingDayInfo day,
    SuhoorIftarSettings reminders,
    PrayerSettings prayer,
    GeoPoint location,
  ) sync* {
    final inRamadan = day.types.contains(FastingType.ramadan);
    if (!inRamadan && !(reminders.onOtherFastingDays && day.isFastingDay)) {
      return;
    }
    final times = prayer.timesOn(day.date, location, inRamadan: inRamadan);
    if (times.fajr case final fajr? when reminders.suhoorEnabled) {
      yield _occurrence(
        FastingMeal.suhoor,
        fajr,
        reminders.suhoorMinutesBeforeFajr,
      );
    }
    if (times.maghrib case final maghrib? when reminders.iftarEnabled) {
      yield _occurrence(
        FastingMeal.iftar,
        maghrib,
        reminders.iftarMinutesBeforeMaghrib,
      );
    }
  }

  static SuhoorIftarOccurrence _occurrence(
    FastingMeal meal,
    DateTime prayerTime,
    int minutesBefore,
  ) {
    final fireAt = prayerTime
        .subtract(Duration(minutes: minutesBefore))
        .toLocal();
    return SuhoorIftarOccurrence(
      date: CalendarDays.dateOnly(fireAt),
      timing: ReminderTiming(
        daysBefore: 0,
        time: WallClockTime(fireAt.hour, fireAt.minute),
      ),
      meal: meal,
      prayerTime: prayerTime,
      minutesBefore: minutesBefore,
    );
  }
}
