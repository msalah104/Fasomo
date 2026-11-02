# Ramadan mode with prayer times — implementation plan

**Status:** built on the review branch `claude/ramadan-mode-prayer-times`,
in the commits listed in section 8. As built:

- Everything in sections 1 to 4 shipped, with the defaults in section 7
  (open decisions are still open).
- The Ramadan card does not repeat the month bar's progress bar; the bar
  just above it already shows Ramadan and the day.
- Notification text uses the locale's usual clock format (there is no
  device 12/24-hour setting outside a widget).
- `DateFormat` writes Western digits in Arabic, set once at startup, so the
  times match the rest of the app (this also changed the sky header's
  times and dates, which were in Arabic-Indic digits).
- A suhoor and iftar settings change that can't be saved is undone (the
  notifications follow what is saved).

During Ramadan the hardest thing to keep in your head is the clock: when
suhoor ends and when iftar is. This adds prayer times computed on the phone
from the location the sky already uses, a Ramadan card on Home that shows
them with a live countdown and a small daily checklist, and suhoor and iftar
reminders that move with Fajr and Maghrib every day.

Everything stays offline. No new package: the times come from the in-house
astronomy in `lib/core/astronomy/` (NOAA/Meeus, already tested against
PyEphem), not from `adhan`.

---

## 1. What the user sees

### Before Ramadan (Home)

From 30 days before 1 Ramadan, a countdown card sits above "Your fasting":

```
┌ ☾ Ramadan in 12 days ───────────────┐
│ Starts Monday, February 8           │
│ (expected, by the Umm al-Qura       │
│  calendar and your adjustment)      │
└─────────────────────────────────────┘
```

"Ramadan starts tomorrow" on the last day. Outside that window nothing is
added to Home.

### During Ramadan (Home)

The Ramadan card replaces the countdown, above the progress card and the
upcoming list (which stay as they are):

```
┌ ☾ Ramadan · Day 12 of 30 ───────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░       │
│                                     │
│  Iftar in 2 h 15 min                │
│                                     │
│  Suhoor ends   05:31  (Fajr)        │
│  Iftar         17:24  (Maghrib)     │
│  Cairo · Egyptian General Authority │
│                                     │
│ Today                               │
│  [✓ Fasted]   (the tracker's toggle)│
│  [ ] Taraweeh                       │
│  Quran pages   [−]  5  [+]          │
│                                     │
│ ▸ All prayer times today            │
│     Fajr 05:31 · Sunrise 06:56 …    │
└─────────────────────────────────────┘
```

- **Countdown to the next one**: before Fajr, "Suhoor ends in 1 h 05 min";
  between Fajr and Maghrib, "Iftar in 2 h 15 min"; after Maghrib, tomorrow's
  suhoor (or "Eid Mubarak" after the last iftar). Updated every minute while
  Home is showing, paused in the background and on other tabs (same rule as
  the sky).
- **Day N of M**: the Hijri day of Ramadan and the month's length (29 or 30),
  both from the user's adjusted Umm al-Qura calendar. A thin bar shows it.
- **Daily checklist**, for today only:
  - *Fasted* is the tracker's existing toggle, passed in by the app shell, so
    the tracker stays the one owner of the fasting log.
  - *Taraweeh*: a toggle.
  - *Quran pages*: a stepper, 0–604 (the pages of a standard mushaf).
- **All prayer times**: a collapsed row that expands to the six times.
- **Where and how**: the place's name and the method in use, so a wrong
  time can be traced to a wrong setting.
- Times are shown in the device's time zone and clock format (12/24 h), with
  Western digits in Arabic too, as the sky already does.

### Settings › Prayer times (new section)

- **Calculation method**: "Automatic (by country)" (default) or one of the
  methods in section 2. Automatic shows what it resolved to, e.g. "Automatic:
  Egyptian General Authority".
- **Asr**: Standard (Shafi'i, Maliki, Hanbali) or Hanafi.
- **High latitudes**: Middle of the night (default), One-seventh of the night,
  or Twilight angle. Explained in one line; it only changes anything where
  the sky never gets dark enough for Fajr or Isha (e.g. London in June).
- **Adjust times**: minutes added to or taken from each prayer (−30 to +30),
  for matching a local mosque's timetable. Maghrib + N minutes is a common
  precaution and is set here.

### Reminders tab (new card) — "Suhoor and iftar"

- **Suhoor**: on, 45 minutes before Fajr (choices: 15, 30, 45, 60, 90).
- **Iftar**: on, at Maghrib (choices: at Maghrib, 5, 10, 15 minutes before).
- **Also on other fasting days** (off by default): the same reminders on
  every recommended fasting day (Mondays and Thursdays, White Days, Arafah …).
- Notifications: "Suhoor ends in 45 minutes" / "Fajr is at 05:31. Finish
  your suhoor." and "It's time for iftar" / "Maghrib has come. May Allah
  accept your fast."

---

## 2. Prayer-time calculation (`lib/core/prayer/`)

Pure Dart on top of `core/astronomy`: every function is total and takes the
local calendar date plus coordinates; results are UTC instants rounded to the
nearest minute (as printed timetables are), `null` where the sun never
reaches the angle and no high-latitude rule applies.

| Time | How |
|---|---|
| Fajr | Sun at −(Fajr angle) before noon (`sunTimeForAngle(rising: true)`). |
| Sunrise | Sun's centre at −0.833° (refraction + semi-diameter). |
| Dhuhr | Solar noon. |
| Asr | Afternoon altitude where the shadow is *k* × height + the noon shadow: `atan(1 / (k + tan|φ − δ|))`, *k* = 1 (Standard) or 2 (Hanafi). |
| Maghrib | Sunset (or the sun at −4.5° for Tehran). |
| Isha | Sun at −(Isha angle) after noon, or a fixed number of minutes after Maghrib. |

### Methods (Fajr angle / Isha)

| Method | Fajr | Isha | Default for |
|---|---|---|---|
| Umm al-Qura | 18.5° | 90 min after Maghrib (**120 in Ramadan**) | SA, YE |
| Egyptian General Authority | 19.5° | 17.5° | EG, SD, LY, SY, LB, JO, PS, IQ |
| Muslim World League | 18° | 17° | everyone else, and no country known |
| ISNA (North America) | 15° | 15° | US, CA |
| Karachi (Univ. of Islamic Sciences) | 18° | 18° | PK, IN, BD, AF |
| Dubai | 18.2° | 18.2° | AE |
| Kuwait | 18° | 17.5° | KW |
| Qatar | 18° | 90 min after Maghrib | QA |
| Singapore (MUIS) | 20° | 18° | SG, MY, ID, BN |
| Turkey (Diyanet) | 18° | 17° | TR |
| Tehran (Institute of Geophysics) | 17.7° | 14°, Maghrib at 4.5° | IR |

The country comes from `GeoPoint.city.countryCode` (a picked city, or the
bundled city nearest a device fix). A device fix with no city within 50 km,
and the Makkah fallback's own country, resolve as above (no city → MWL).

Dubai and Turkey publish small per-prayer offsets on top of the angles
(adhan applies them); we don't, so the user's own adjustments cover them.

### High latitudes

Where the sun never gets to the Fajr or Isha angle, or gets there absurdly
late, the time is capped at a portion of the night (sunset to the next
sunrise, taken as 24 h minus the day), counted back from sunrise for Fajr and
forward from sunset for Isha, as PrayTimes.org does:

- **Middle of the night**: ½ of the night (default).
- **One-seventh**: ⅐ of the night.
- **Twilight angle**: angle ⁄ 60 of the night (18° → 0.3).

The cap applies only when it is earlier (Fajr) or later (Isha) than the true
time, so at ordinary latitudes nothing changes. On polar days or nights with
no sunrise or sunset, Fajr, sunrise, Maghrib and Isha are `null` (Asr too
when the sun stays down at noon) and the UI shows "—".

### Validation

Unit tests pin each method against reference timetables from an independent
implementation of PrayTimes.org's published algorithm (v2.3), within ±2
minutes: Makkah (Umm al-Qura, in and out of Ramadan), Cairo (Egyptian),
London in June (MWL, all three high-latitude rules) and December, Karachi
(Hanafi Asr), Tehran (Maghrib angle) and New York (ISNA). Plus invariants:
Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha wherever all exist; Hanafi Asr
later than Standard; adjustments shift exactly by their minutes.

---

## 3. Location

`LocationRepository.current()` (already built for the sky) is read on every
computation: a picked city, a rounded device fix, or Makkah until the user
sets one. Nothing new is asked for. When the sky's location changes, the
app shell refreshes the Ramadan card and resyncs the reminders.

---

## 4. Architecture

```
lib/
  core/
    calendar/ramadan_dates.dart        # nextRamadanStart, moved from tracker
    prayer/
      calculation_method.dart          # enum with parameters + forCountry
      prayer_settings.dart             # method?, AsrMethod, HighLatitudeRule, adjustments
      prayer_times.dart                # value: fajr … isha (UTC, minute)
      prayer_time_calculator.dart      # pure, on core/astronomy
      prayer_settings_repository.dart  # interface: Result reads/writes
      prayer_settings_repository_impl.dart  # SharedPreferences JSON
      usecases/                        # GetPrayerSettings, SavePrayerSettings
    notifications/                     # + PrayerTimeOccurrence, copy, composer
  features/
    settings/presentation/             # PrayerSettingsBloc + "Prayer times" tiles
    ramadan/
      domain/  entities (RamadanOverview sealed: NotNear / Countdown / Today,
               NextFastingMoment, RamadanChecklist, SuhoorIftarSettings),
               repositories, GetRamadanOverview, checklist + reminder use
               cases, SuhoorIftarReminderSource (a ReminderSource)
      data/    checklist and reminder-settings repositories (SharedPreferences)
      presentation/  RamadanBloc, SuhoorIftarBloc, RamadanCard,
               countdown card, checklist, reminder card + sheet
  app/app_shell.dart                   # composes Home + Ramadan + tracker
```

- **Prayer settings live in core** (like the location), because both the
  Ramadan view and the reminder source read them and features never import
  each other. The settings feature owns the UI for them, as it does for the
  Hijri adjustment.
- **`RamadanBloc`**: clock-injected through `GetRamadanOverview`; ticks every
  minute with `core/time/MinuteTicker` while the card is in view
  (`TickerMode` + app lifecycle, as `SkyHeader` does); events for refresh,
  Taraweeh and Quran pages. Saving persists first, then emits; a failed save
  reverts and shows a snackbar.
- **Home** gains one slot, `spotlightSection`, above the progress card. The
  app shell fills it with the `RamadanCard` and passes the tracker's
  `FastedToggle` into the card's checklist.
- **Checklist storage**: one JSON value in SharedPreferences,
  `{"2027-02-19": {"taraweeh": true, "quranPages": 5}}`, keyed by local
  ISO date; malformed data is a `StorageReadFailed`, never a crash.
- **Prayer-relative reminders**: `SuhoorIftarReminderSource` is added to the
  one `SyncNotifications` sources list. For each day in the 60-day horizon
  that is in Ramadan (or, with the option on, any recommended fasting day), it computes that day's times and emits a
  `PrayerTimeOccurrence` at Fajr − N and Maghrib − M. The occurrence carries a
  concrete local fire time, resolved from the UTC instant at sync time; the
  rolling foreground sync keeps them right after a time-zone or DST change.
  They are never merged with the day-before fasting reminders, and a Ramadan
  countdown never attaches to them. Two a day share the budget of 50 with
  the others, so about two weeks are scheduled ahead, refilled on every open.

---

## 5. Tests

- Calculator: the reference table above, invariants, adjustments, Umm
  al-Qura's Ramadan Isha, polar day/night returning `null`.
- Country defaults: SA → Umm al-Qura, EG → Egyptian, GB → MWL, US → ISNA,
  no city → MWL.
- Repositories: round trips, defaults when nothing is stored, malformed JSON
  → `StorageReadFailed`, refused writes → `StorageWriteFailed`.
- `GetRamadanOverview`: not near, 30-day window edges, day N of M, next
  moment before Fajr / between / after Maghrib / after the last iftar,
  respects the Hijri adjustment.
- `RamadanBloc` with `bloc_test` and fakes: load, tick, pause/resume,
  Taraweeh and Quran pages persisted per date, a failed save reverts.
- Reminder source: Ramadan days only by default, fasting days with the
  option, Fajr − 45 and Maghrib − 0 land on the right local minutes, disabled
  parts emit nothing, composer keeps them separate.
- Widgets in English and Arabic: the countdown card, the Ramadan card
  (times, day N, checklist), the prayer-time settings tiles and the reminder
  sheet; screenshots of Home in Ramadan and before it.

---

## 6. Out of scope

- Qibla direction, the adhan sound or full prayer-time notifications for all
  five prayers (only suhoor and iftar here).
- Imsak as a separate time (suhoor "ends" at Fajr; the reminder covers the
  precaution).
- Elevation correction, official city timetables, or downloading them.
- Laylat al-Qadr and last-ten-nights features, Quran khatm planning.
- Time-zone of a picked city: times are shown in the device's zone.

---

## 7. Open decisions (for the user)

1. **High-latitude default**: middle of the night (PrayTimes' default) or
   one-seventh (adhan's recommendation above 48°)? The middle of the night
   puts London's Fajr and Isha both at about 01:00 BST in June.
2. **Country defaults**: the table above is a starting point; e.g. Algeria,
   Morocco and Tunisia have their own ministries' angles (MWL-like here).
3. **Rounding**: nearest minute everywhere. Some timetables round Fajr up and
   Maghrib down for caution; the adjustments allow that per user.
4. **Iftar reminder default**: at Maghrib (0 min) vs 5 minutes before.
5. **"Also on other fasting days"** off by default — on would add two
   notifications to every Monday and Thursday.
6. **Countdown window**: 30 days before Ramadan.

---

## 8. Delivery (one commit each, each green)

1. This plan.
2. `core/prayer` calculator and methods, with the reference tests.
3. Prayer-time settings: storage, default by country, the Settings section.
4. The `ramadan` feature: overview, countdown and Ramadan cards on Home,
   the checklist, screenshots.
5. Suhoor and iftar reminders as a new `ReminderSource`, the Reminders tab
   card, localized copy; README updated.
