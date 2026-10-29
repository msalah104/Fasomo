# Fasomo - Islamic Fasting Tracker

A Flutter app that helps Muslims keep track of the recommended (Sunnah) and obligatory fasting days on the Hijri calendar, with reminders, in Arabic and English.

## Features

### ✨ Launch
- **Animated splash**: the sun sets behind the dome, the sky turns through dusk to night and the stars come out. The new moon rises and settles as the dot of the ف logo, the letter draws itself around it, and the app name is typed out. Tap to skip; with reduced motion the finished scene shows briefly instead.

### 🏠 Home
- **Sky header**: a full-width sky with the ف logo mark, showing a daytime scene from 06:00 to 18:00 and a night scene otherwise. Today's Hijri date and the short Gregorian date sit on the ground band. The scenes are static artwork for now; the live sun and moon are on the roadmap.
- **This week**: today and the next six days with their Hijri day numbers, and a dot under each fasting day. The strip stays pinned at the top when the sky scrolls away. Tap a day to list the fasting days from that day on; today keeps an outline.
- **Month bar**: where today falls in the Hijri month, with the White Days marked.
- **Upcoming fasting days**: the next five fasting days in the coming 30 days, including next month's White Days. A day that is several kinds at once (say, a White Day on a Monday) is listed once with all of them.
- **One-tap reminders**: every reminder is on from the start; switch one off (or back on) straight from its card.
- **I fasted today**: today's fasting-day card has a button to mark it as fasted.
- **Your fasting**: a card with the current and longest streak and this month's count ("3 of 5 fasting days"). Tap it for the progress page.

### ✅ Fasting tracker
- **Mark any day up to today** as fasted, from Home or from a day in the calendar. Future days and the forbidden days (the Eids and Tashreeq) can't be marked.
- **Streaks** count fasting days only: a fasted fasting day extends the streak, a missed one before today resets it, and ordinary days never break it. Today counts once you mark it and never breaks the streak before then. A day with several types counts once.
- **Progress page**: the make-up (Qada) balance first, then this Hijri month's and this Hijri year's totals per fasting type so far (e.g. "White Days · 9 of 12"). The streaks are on the Home card.
- Streaks and totals are worked out from the log every time, never stored. The log is kept on the device.

### ↺ Make-up fasts (Qada)
- **Days owed per Ramadan**: mark the Ramadan days you missed in the calendar (a Ramadan day is either *Fasted* or *Missed*), or enter how many days you owe from an earlier Ramadan.
- **Make-up fasts**: tap *Log a make-up fast* on the progress page and pick the day, or switch on *Make-up fast* for a day in the calendar. Ramadan, Eid and Tashreeq days can't be picked. A make-up fast is also a fasted day, so one on a Monday counts toward the Monday & Thursday totals and the streak.
- **Balance**: the progress page shows the days left, each Ramadan's "made up of owed" (make-up fasts pay off the oldest Ramadan first) and, while days are owed, the days until the next Ramadan. The latest five make-up fasts are listed there, each with a button to remove it. Home shows the days left too.
- Missed days carry a ✗ badge in the calendar and make-up fasts a ↺ badge.

### 📅 Calendar
- **Full Hijri month view** for any month from 1356 to 1500 AH, with month navigation.
- **Colour- and icon-coded fasting days**, in the Hilal palette:
  - Pale moon: White Days (13th, 14th, 15th)
  - Gold: Monday & Thursday
  - Violet: Ramadan
  - Teal: Six Days of Shawwal
  - Clay red: special days (Arafah, Ashura, Tasua)
  - Each type also has its own outlined icon: crescent (Ramadan), peak (special days), sparkle (Shawwal), full moon (White Days) and calendar (Monday & Thursday).
- **Day details**: tap a day to see both dates and what each fasting type means, and mark it as fasted, missed (in Ramadan) or a make-up fast.
- **Logged days** carry a badge: ✓ fasted, ↺ make-up fast, ✗ missed in Ramadan.

### 🔔 Reminders
- **On by default**: every fasting type has a reminder, on until you switch it off, and so are the make-up reminders. Each card can be switched off or edited.
- **Real fire times**, worked out from each actual fasting date:
  - **Day before**: 8:00 PM the evening before
  - **Morning of the day**: 7:00 AM on the fasting day
  - **Custom**: any time, on the day itself or the day before
- **Custom messages** in place of the default text.
- **One notification per day**: if a day matches several reminders, only the most important type fires. A Sunnah fasting day that is also a suggested make-up day gets one merged notification ("Monday & Thursday + make-up").
- **Make-up (Qada) reminders**, set up from the progress page or the Reminders tab, all on by default:
  - **Weekly** on the days you pick (Saturday by default).
  - **Monthly** on a Hijri day you pick (the 13th, first of the White Days, by default).
  - **Before Ramadan**: a countdown any number of days before it (30 and 7 by default). On a day that already has a notification, the countdown is added to its text.
  - At 8:00 PM the evening before or 7:00 AM on the day. They skip Ramadan, the Eids, Tashreeq and days already fasted, and stop once nothing is owed.
- **Reliable scheduling**: reminders are re-synced whenever the app opens or returns to the foreground, after every change and when the language changes. Up to 50 upcoming reminders (60 days ahead) are kept scheduled, which stays under the iOS limit of 64.
- Since reminders start on, notification permission is asked once, when the app first opens. Turning a reminder back on asks again if it was refused.

### 🌐 Language
- Arabic and English, with full right-to-left layout in Arabic.
- Choose **System default**, **English** or **العربية** from the language menu. The choice is saved.

### 🎨 Look
- **Hilal theme**: night blue and moon gold on warm ivory, with a hand-tuned dark theme. The app follows the system light or dark setting.
- Every text colour pair passes WCAG AA contrast, checked by a unit test.
- **App icon**: the gold ف mark (the letter Fa with the new moon as its dot) on night blue, with an adaptive icon on Android. Regenerate with `dart run flutter_launcher_icons` after changing `design/art/app_icon.svg` and its render in `assets/icon/`.

### ℹ️ About
- App information, the hadith behind each recommended fast, and contact details.

## Supported Fasting Days

- **White Days (الأيام البيض)**: the 13th, 14th and 15th of every Hijri month
- **Monday & Thursday (الاثنين والخميس)**: every week
- **Day of Arafah (يوم عرفة)**: 9 Dhul Hijjah
- **Day of Tasua (يوم تاسوعاء)**: 9 Muharram
- **Day of Ashura (يوم عاشوراء)**: 10 Muharram
- **Ramadan (رمضان)**: the whole month (obligatory). Voluntary types are not shown during Ramadan.
- **Six Days of Shawwal (ست من شوال)**: any days from 2 to 30 Shawwal

Fasting is never suggested on the days it is forbidden: Eid al-Fitr (1 Shawwal), Eid al-Adha and the days of Tashreeq (10–13 Dhul Hijjah). Hijri dates follow the Umm al-Qura calendar and have no manual adjustment yet (see the roadmap).

## Run locally

### Prerequisites
- Flutter **3.47** (stable) or newer, which includes Dart 3.13. Check with `flutter --version`.
- For Android: Android Studio with an emulator or a device (Android SDK and JDK 17).
- For iOS (macOS only): Xcode with an iOS 15+ simulator or device, and CocoaPods.

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/msalah104/Fasomo.git
   cd Fasomo
   ```
2. Install dependencies. `flutter pub get` also generates the localization code from the ARB files:
   ```bash
   flutter pub get
   ```
3. Start an emulator or connect a device, then run:
   ```bash
   flutter run
   ```

### Checks (run before every commit)

```bash
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

### Build for release

```bash
flutter build apk --release      # Android
flutter build ios --release      # iOS (macOS only)
```

Release builds are still signed with the debug key. Add your own signing config before you publish.

### Testing reminders on a device

Reminders need a real fasting day ahead, so the quickest check is to enable **Monday & Thursday** with a **Custom** time a few minutes from now on the day before a Monday or Thursday. Android emulators and iOS simulators deliver scheduled notifications, but survival across reboot and battery optimisation can only be confirmed on real devices.

## Architecture

Clean architecture, organised by feature, with **BLoC** for state and **GetIt** for dependency injection. See `CLAUDE.md` for the project conventions.

```
lib/
├── app/                    # MaterialApp and the tab shell (the only place features meet)
├── core/
│   ├── calendar/           # Pure Hijri dates, conversion, fasting rules
│   ├── notifications/      # Pure reminder scheduling, the gateway port, reconcile
│   ├── services/           # Platform adapters (flutter_local_notifications, time zone)
│   ├── error/              # Result<T, F> and sealed Failure types
│   ├── di/                 # GetIt composition root
│   ├── presentation/       # Shared labels, fasting-type colours and icons, date text
│   └── theme/              # Hilal tokens: primitives, AppColors, AppShapes, buildAppTheme
├── features/
│   ├── home/  calendar/  reminders/  tracker/  settings/  about/
│   │   ├── domain/         # Entities, repository interfaces, use cases (pure Dart)
│   │   ├── data/           # Repository implementations
│   │   └── presentation/   # Blocs, pages, widgets
├── l10n/                   # app_en.arb, app_ar.arb (+ generated/)
└── main.dart
```

- **Typed errors**: repositories return `Result<T, Failure>` and never throw for expected failures. Blocs switch on the result exhaustively.
- **Injected clock**: domain and data code read "now" from `package:clock`, so date logic is tested with fixed times.
- **Notifications** follow one path: one core sync asks every reminder source (the fasting reminders and the make-up reminders) for its occurrences, composes them into notifications (merging same-day ones) and reconciles that desired set against the OS pending set. Ids are deterministic, so an unchanged sync does nothing and an edit reschedules. Only `fln_notification_gateway.dart` imports the plugin.

## Tech Stack

- **Flutter / Dart 3**, Material 3
- **State management**: flutter_bloc, bloc_concurrency
- **Dependency injection**: get_it
- **Hijri calendar**: hijri (Umm al-Qura table)
- **Notifications**: flutter_local_notifications, timezone, flutter_timezone
- **Storage**: shared_preferences
- **Localization**: flutter_localizations, intl, gen-l10n (ARB)
- **Testing**: flutter_test, bloc_test, mocktail
- **Lints**: very_good_analysis

## Permissions

### Android
- `POST_NOTIFICATIONS`: show reminders (Android 13+, requested when you enable a reminder)
- `RECEIVE_BOOT_COMPLETED`: restore scheduled reminders after a restart
- `SCHEDULE_EXACT_ALARM`: optional. If granted, reminders fire at the exact minute; otherwise they use inexact alarms that may arrive a few minutes late. `USE_EXACT_ALARM` is deliberately not declared, because Google Play restricts it to alarm-clock apps.

### iOS
- Notification permission, requested when you enable a reminder.

## Roadmap

The ideas below are planned, not built. Each one follows the existing conventions: a feature folder with `domain/`, `data/` and `presentation/`, a Bloc registered in GetIt, `Result`/`Failure` from repositories, "now" from the injected clock, strings in the ARB files, and tests for the pure logic and the bloc.

Priority: **P1** = next up, **P2** = after that, **P3** = later. Everything is offline-first unless it's under [Needs a backend](#needs-a-backend).

### Summary

| Priority | Feature | New packages | Backend |
|---|---|---|---|
| P1 | [Home sky header](#home-sky-header-p1) | `dart_suncalc`, `geolocator` (optional) | No |
| P1 | [Ramadan mode with prayer times](#ramadan-mode-with-prayer-times-p1) | `adhan`, `geolocator` | No |
| P3 | [Qada suggested pace](#qada-suggested-pace-p3) | — | No |
| P2 | [Hijri date adjustment](#hijri-date-adjustment-p2) | — | No |
| P2 | [Theme switch](#theme-switch-p2) | — | No |
| P2 | [Hilal fonts](#hilal-fonts-p2) | — (bundled font files) | No |
| P2 | [Notification tones](#notification-tones-p2) | — (bundled sounds) | No |
| P2 | [Home-screen widget](#home-screen-widget-p2) | `home_widget` | No |
| P2 | [Onboarding](#onboarding-p2) | — | No |
| P3 | [Calendar extras](#calendar-extras-p3) | — | No |
| P3 | [Duas and intentions for fasting](#duas-and-intentions-for-fasting-p3) | — | No |
| P3 | [Share a fasting day](#share-a-fasting-day-p3) | `share_plus` | No |
| P3 | [Backup and restore](#backup-and-restore-p3) | `share_plus`, `file_picker` | No |
| — | [Needs a backend](#needs-a-backend) | Firebase or Supabase | Yes |

### Home sky header (P1)

A live sky at the top of Home: the sun by day and the moon by night, placed where they really are for the user's time and location, with the moon drawn in its real phase. It shows sunrise and sunset times and a countdown to the next one.

- **Status:** the layout ships with two static scenes (day and night PNGs from `design/art/`), switched at fixed hours. What's left is drawing the scene live.

- **Why:** it makes the app feel alive every time it opens, and it links the Hijri date to the moon it comes from.
- **How:** a `CustomPainter` fed by a pure `SkyPosition` calculation (sun/moon altitude, azimuth and lit fraction from `dart_suncalc`, read through the injected clock). A `SkyBloc` loads the location (saved city, or device location if granted) and refreshes every minute while Home is visible. Respects reduced motion.
- **Plan:** the full design is in [`docs/plans/home-sky-header.md`](docs/plans/home-sky-header.md).

### Ramadan mode with prayer times (P1)

During Ramadan (and optionally on any fasting day), Home switches to a Ramadan view.

- **What it shows:** a countdown to Ramadan before it starts; during it, today's **suhoor (Fajr)** and **iftar (Maghrib)** times, a countdown to the next one, the day number ("Day 12 of 30"), and a simple daily checklist (fasted, Taraweeh, Quran pages).
- **Reminders:** new reminder timings relative to prayer times, e.g. "30 minutes before Fajr" for suhoor and "at Maghrib" for iftar, instead of fixed clock times.
- **How:** the `adhan` package computes prayer times offline from coordinates and a calculation method (Umm al-Qura, Egyptian, MWL, ISNA, …, chosen in settings, with a sensible default per country). Location comes from `geolocator` or a manually picked city, so the app still works with location permission denied. Prayer-time math stays pure and clock-injected; the reminder scheduler gains a "relative to prayer" timing.

### Hijri date adjustment (P2)

A setting to shift the Hijri calendar by −2 to +2 days.

- **Why:** the app uses the Umm al-Qura table, but many countries start months by local moon sighting, so the date can be a day off. This is the most common correctness complaint in Hijri apps.
- **How:** one offset stored in settings and applied inside the Hijri converter, so the calendar, fasting rules and reminders all move together. Reminders re-sync when it changes. Later, the default could come from a remote config per country (see backend).

### Theme switch (P2)

- The Hilal dark theme is done and the app follows the system setting. What's left is a **System / Light / Dark** choice in settings, saved and restored before the first frame, like the language choice.

### Hilal fonts (P2)

- Bundle El Messiri (headings) and IBM Plex Sans Arabic (body) as assets, with their licences registered, so the app stays fully offline.

### Notification tones (P2)

- Pick a reminder sound from a few bundled tones (e.g. a soft chime or a short adhan clip) or the system default, plus vibrate-only.
- **How:** sounds are bundled assets (`res/raw` on Android, the app bundle on iOS). On Android the sound belongs to the notification channel, so each tone gets its own channel; changing the tone re-syncs pending reminders.

### Home-screen widget (P2)

- Shows today's Hijri date and the next fasting day ("White Days in 3 days"); tapping it opens the app on that day.
- **How:** `home_widget` with a native widget (Android `AppWidgetProvider`, iOS WidgetKit). The app writes a small snapshot whenever data or the date changes, and the widget only reads it.

### Onboarding (P2)

A short first-run flow: choose language, choose which fasting types interest you, set a default reminder time, and only then ask for notification permission (and location, if Ramadan mode or the sky header needs it), with a sentence explaining why.

### Qada suggested pace (P3)

A make-up reminder that plans the pace for you: from the days owed and the weeks left before Ramadan it works out something like "1 a week" and schedules those days. See [`docs/plans/qada-reminders.md`](docs/plans/qada-reminders.md).

### Calendar extras (P3)

- A **Today** button to jump back to the current month.
- A **year view** showing all twelve Hijri months with fasting days marked.
- A **Gregorian toggle** to show the Gregorian day number in each cell.
- Swipe between months.

### Duas and intentions for fasting (P3)

A small offline collection: the intention for fasting, the dua at iftar, and the relevant hadith for each fasting type, in Arabic with English translation and source references. It can be opened from a fasting day's details.

### Share a fasting day (P3)

Share an image card ("Tomorrow is the Day of Arafah") with the date and its hadith, using the system share sheet behind an injected share service.

### Backup and restore (P3)

Export reminders, settings and the fasting log to a versioned JSON file and restore it on a new phone. This avoids accounts while still letting users keep their history.

### Needs a backend

These need a server or an account, so they come only after the offline features above:

- **Sync across devices** with an account (Firebase Auth + Firestore, or Supabase).
- **Family or group challenges**: fast together and see each other's progress.
- **Remote content and moon-sighting updates**: update hadith text, or the per-country Hijri offset, without an app release (e.g. Firebase Remote Config).
- **Announcement push notifications**, e.g. "Ramadan confirmed to start tomorrow" (Firebase Cloud Messaging).
- **Crash reporting and analytics** (Crashlytics), opt-in and declared in the store privacy forms.

## Contributing

Contributions are welcome. Follow the conventions in `CLAUDE.md` and make sure the three checks above pass before opening a pull request.

## License

No license has been chosen yet.

## Contact

- **Email**: support@fasomo.app
- **Website**: www.fasomo.app
- **GitHub**: github.com/msalah104/Fasomo

---

**May Allah accept our fasting and good deeds. Ameen.** 🤲
