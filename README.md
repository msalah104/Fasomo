# Fasomo - Islamic Fasting Tracker

A Flutter app that helps Muslims keep track of the recommended (Sunnah) and obligatory fasting days on the Hijri calendar, with reminders, in Arabic and English.

## Features

### ✨ Launch
- **Animated splash**: the sun sets behind the dome, the sky turns through dusk to night and the stars come out. The new moon rises and settles as the dot of the ف logo, the letter draws itself around it, and the app name is typed out. Tap to skip; with reduced motion the finished scene shows briefly instead.

### 🏠 Home
- **Live sky**: the top of Home shows the real sky over where you are: the sun by day and the moon by night on their arcs, with the moon in its actual phase and tilt, and sunrise, sunset and moonrise times under the skyline. The sky's colours follow the sun through dawn, golden hour and dusk, and it refreshes every minute while Home is showing. Today's Hijri and Gregorian dates sit on the ground band.
- **Location**: tap the location chip to use the device's approximate location (asked only when you tap) or pick from 317 bundled cities in English or Arabic, offline. Until then the sky is drawn for Makkah. Everything is computed on the phone (`lib/core/astronomy/`), and the location never leaves it.
- **This week**: today and the next six days with their Hijri day numbers, and a dot under each fasting day. The strip stays pinned at the top when the sky scrolls away. Tap a day to list the fasting days from that day on; today keeps an outline.
- **Month bar**: where today falls in the Hijri month, with the White Days marked.
- **Upcoming fasting days**: the next five fasting days in the coming 30 days, including next month's White Days. A day that is several kinds at once (say, a White Day on a Monday) is listed once with all of them.
- **One-tap reminders**: every reminder is on from the start; switch one off (or back on) straight from its card.
- **I fasted today**: today's fasting-day card has a button to mark it as fasted.
- **Your fasting**: a card with the current and longest streak and this month's count ("3 of 5 fasting days"). Tap it for the progress page.

### 🌙 Ramadan mode and prayer times
- **Before Ramadan**: in the 30 days before it, Home shows a countdown ("Ramadan in 12 days") with the expected first day by your adjusted calendar, and on the last day when the first suhoor ends.
- **During Ramadan**: a Ramadan card on Home with the day ("Day 12 of 29"), a live countdown to the next moment ("Iftar in 3 h 42 min"; before Fajr "Suhoor ends in 45 min"; after Maghrib tomorrow's suhoor; "Eid Mubarak" after the last iftar), today's **suhoor end (Fajr)** and **iftar (Maghrib)**, where and how they were worked out ("London · Muslim World League"), and all six prayer times on request. It updates every minute while Home is showing.
- **Daily checklist**: *I fasted today* (the same toggle as the tracker), Taraweeh, and a Quran pages counter (0–604). Kept per day on the device.
- **Prayer times are computed on the phone** from the location the sky uses (`lib/core/prayer/`, on the in-house astronomy, no extra package), for the eleven common methods: Umm al-Qura (Isha 120 minutes after Maghrib in Ramadan), Egyptian General Authority, Muslim World League, ISNA, Karachi, Dubai, Kuwait, Qatar, Singapore, Turkey and Tehran. The method follows your country unless you choose one. Checked against the PrayTimes.org algorithm to within two minutes.
- **Settings › Prayer times**: method (automatic by country, showing which), Standard or Hanafi Asr, the high-latitude rule (middle of the night, one-seventh, or twilight angle, for places where Fajr or Isha never comes in summer) and per-prayer adjustments of up to ±30 minutes to match your mosque.

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
- **Full Hijri month view** for any month from 1356 to 1500 AH. Swipe between months (in Arabic it follows reading direction; with reduced motion the month changes without sliding) or use the arrows, and tap **Today** to jump back.
- **Gregorian day numbers**: a toggle shows the Gregorian day under each Hijri day. The choice is remembered.
- **Year view**: all twelve Hijri months at once with fasting days marked in colour; tap a month to open it. It shows 2 to 4 columns depending on screen width.
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
  - **Suggested pace** (off by default): from the days owed and the days left before Ramadan, works out a pace ("fast 1 make-up day a week", "every day you can", or an honest "fewer days left than you owe") and schedules those days, Mondays and Thursdays first. It is re-planned as the balance changes, and the progress page shows it ("Suggested pace: 1 day a week · Next: Thu, Nov 5").
  - At 8:00 PM the evening before or 7:00 AM on the day. They skip Ramadan, the Eids, Tashreeq and days already fasted, and stop once nothing is owed.
- **Suhoor and iftar**: on by default in Ramadan, timed from each day's prayer times where you are: suhoor 45 minutes before Fajr (15, 30, 45, 60 or 90) and iftar at Maghrib (or 5, 10 or 15 minutes before) — "Suhoor ends in 45 minutes · Fajr is at 5:16 AM". Optionally on every other recommended fasting day too. Set up from the Reminders tab; they follow a new location or prayer setting at once.
- **Reminder sound**: Settings › Notifications lets you pick the system default, one of three bundled tones (Soft chime, Bell, Gentle) or vibrate only (silent on iPhone, which can't vibrate without a sound). Each option can be tried first. On Android each tone has its own notification channel, and changing the tone reschedules every pending reminder. The tones are synthesized by `tool/tones/generate_tones.py`.
- **Reliable scheduling**: reminders are re-synced whenever the app opens or returns to the foreground, after every change and when the language changes. Up to 50 upcoming reminders (60 days ahead) are kept scheduled, which stays under the iOS limit of 64.
- Since reminders start on, notification permission is asked once, when the app first opens. Turning a reminder back on asks again if it was refused.

### 📣 Announcements
- **Push announcements** such as "Ramadan confirmed to start tomorrow", sent from the Firebase console with Firebase Cloud Messaging.
- **In your language**: the app joins the `announcements_en` or `announcements_ar` topic, following the language it is shown in, and switches topic when you change language. Send each announcement to both topics, one per language.
- Shown by the system while the app is in the background, and as a local notification on the Announcements channel while it is open.
- No account: the app only joins a topic. Firebase still issues the device a push token and an installation ID.

### ⚙️ Settings
- A gear in the top bar, and on Home's sky, opens Settings. Options are grouped under **Appearance** (language, theme), **Calendar** (Hijri date adjustment) and **Prayer times** (method, Asr, high latitudes, adjustments). Every choice is saved.
- **Theme**: follow the phone's light or dark setting, or always use Light or Dark. The app opens straight in the chosen theme, with no flash of the other one.
- **Hijri date adjustment**: if your country starts months by local moon sighting, shift the Hijri date by −2 to +2 days (+1 moves the Hijri date one day forward). A preview shows today's date as it will appear. The calendar, fasting days, progress and reminders all move together right away.

### 🌐 Language
- Arabic and English, with full right-to-left layout in Arabic.
- Choose **System default**, **English** or **العربية** in Settings. The choice is saved.
- Numbers, times and dates use Western digits (0-9) in Arabic too.

### 🎨 Look
- **Hilal theme**: night blue and moon gold on warm ivory, with a hand-tuned dark theme. By default the app follows the system light or dark setting; see Settings.
- Every text colour pair passes WCAG AA contrast, checked by a unit test.
- **Hilal fonts**: El Messiri for headings and IBM Plex Sans Arabic for body text, bundled as static weights 400–700, so the app looks the same fully offline. Their OFL licences are listed on the licence page.
- **App icon**: the gold ف mark (the letter Fa with the new moon as its dot) on night blue, with an adaptive icon on Android. Regenerate with `dart run flutter_launcher_icons` after changing `design/art/app_icon.svg` and its render in `assets/icon/`.

### 🤲 Duas and intentions
- An offline collection: the intention, the dua at iftar, the dua when breaking the fast as a guest, the dua for Laylat al-Qadr, and the hadith on the virtue of each fasting day, each with its reference (Bukhari, Muslim, Abu Dawud, Tirmidhi, Ibn Majah).
- The Arabic is always laid out right-to-left and can be selected or copied; the English UI adds the transliteration and meaning.
- Open it from the About tab, or from any fasting day on Home or in the calendar, already filtered to that fast.

### 📤 Share a fasting day
- Share any fasting day as an image card in the Hilal colours: the ف mark, "Fasting tomorrow: Day of Arafah", the Hijri and Gregorian dates, and the day's hadith with its reference, plus a short text, through the system share sheet.

### ℹ️ About
- App information, the hadith behind each recommended fast, a link to the duas, and contact details.

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

### Screenshots

`tool/screenshots/app_screenshots_test.dart` boots the real app with fake OS notifications and push, the bundled fonts loaded, and saves every tab in English and Arabic, light and dark, as phone-sized PNGs. Home before and during Ramadan 1448 is rendered with a fixed clock (`ramadan-countdown`, `ramadan`, `ramadan-times`). It sits outside `test/`, so the normal `flutter test` run skips it.

```bash
flutter test tool/screenshots/app_screenshots_test.dart --dart-define=SHOT_DIR=build/screenshots
```

### Testing reminders on a device

Reminders need a real fasting day ahead, so the quickest check is to enable **Monday & Thursday** with a **Custom** time a few minutes from now on the day before a Monday or Thursday. Android emulators and iOS simulators deliver scheduled notifications, but survival across reboot and battery optimisation can only be confirmed on real devices.

## Architecture

Clean architecture, organised by feature, with **BLoC** for state and **GetIt** for dependency injection. See `CLAUDE.md` for the project conventions.

```
lib/
├── app/                    # MaterialApp and the tab shell (the only place features meet)
├── core/
│   ├── astronomy/          # Pure sun and moon positions, rises and sets
│   ├── calendar/           # Pure Hijri dates, conversion, fasting rules
│   ├── location/           # The saved location, bundled cities, device fix
│   ├── prayer/             # Pure prayer times, methods, prayer settings
│   ├── notifications/      # Pure reminder scheduling, the gateway port, reconcile
│   ├── services/           # Platform adapters (flutter_local_notifications, time zone)
│   ├── error/              # Result<T, F> and sealed Failure types
│   ├── di/                 # GetIt composition root
│   ├── presentation/       # Shared labels, fasting-type colours and icons, date text
│   └── theme/              # Hilal tokens: primitives, AppColors, AppShapes, buildAppTheme
├── features/
│   ├── home/  calendar/  reminders/  tracker/  ramadan/  settings/  about/
│   │   ├── domain/         # Entities, repository interfaces, use cases (pure Dart)
│   │   ├── data/           # Repository implementations
│   │   └── presentation/   # Blocs, pages, widgets
├── l10n/                   # app_en.arb, app_ar.arb (+ generated/)
└── main.dart
```

- **Typed errors**: repositories return `Result<T, Failure>` and never throw for expected failures. Blocs switch on the result exhaustively.
- **Injected clock**: domain and data code read "now" from `package:clock`, so date logic is tested with fixed times.
- **Notifications** follow one path: one core sync asks every reminder source (the fasting reminders, the make-up reminders, and suhoor and iftar) for its occurrences, composes them into notifications (merging same-day ones) and reconciles that desired set against the OS pending set. Ids are deterministic, so an unchanged sync does nothing and an edit reschedules. Only `fln_notification_gateway.dart` imports the plugin.
- **Push** goes through the `PushMessaging` port in `core/push/`; only `fcm_push_messaging.dart` imports `firebase_messaging`. `SyncAnnouncementTopic` keeps the device on one language topic.

## Tech Stack

- **Flutter / Dart 3**, Material 3
- **State management**: flutter_bloc, bloc_concurrency
- **Dependency injection**: get_it
- **Hijri calendar**: hijri (Umm al-Qura table)
- **Notifications**: flutter_local_notifications, timezone, flutter_timezone
- **Push**: firebase_core, firebase_messaging (Firebase Cloud Messaging)
- **Storage**: shared_preferences
- **Location**: geolocator (coarse, on request only); sun and moon positions and prayer times are computed in-house in `lib/core/astronomy/` and `lib/core/prayer/`
- **Sharing**: share_plus
- **Fonts**: El Messiri and IBM Plex Sans Arabic, bundled
- **Localization**: flutter_localizations, intl, gen-l10n (ARB)
- **Testing**: flutter_test, bloc_test, mocktail
- **Lints**: very_good_analysis

## Permissions

### Android
- `POST_NOTIFICATIONS`: show reminders (Android 13+, requested when you enable a reminder)
- `RECEIVE_BOOT_COMPLETED`: restore scheduled reminders after a restart
- `INTERNET`, `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `com.google.android.c2dm.permission.RECEIVE`: added by `firebase_messaging` to receive push announcements.
- `ACCESS_COARSE_LOCATION`: optional, asked only when you tap "Use my location" on the sky. Approximate location is enough; it is rounded to about 1 km and stays on the device.
- `SCHEDULE_EXACT_ALARM`: optional. If granted, reminders fire at the exact minute; otherwise they use inexact alarms that may arrive a few minutes late. `USE_EXACT_ALARM` is deliberately not declared, because Google Play restricts it to alarm-clock apps.

### iOS
- Notification permission, requested when you enable a reminder.
- Location when in use: optional, asked only when you tap "Use my location".
- Add to photo library: only used if you choose "Save Image" from the share sheet.

## Roadmap

The ideas below are planned, not built. Each one follows the existing conventions: a feature folder with `domain/`, `data/` and `presentation/`, a Bloc registered in GetIt, `Result`/`Failure` from repositories, "now" from the injected clock, strings in the ARB files, and tests for the pure logic and the bloc.

Priority: **P1** = next up, **P2** = after that, **P3** = later. Everything is offline-first unless it's under [Needs a backend](#needs-a-backend).

### Summary

| Priority | Feature | New packages | Backend |
|---|---|---|---|
| P2 | [Home-screen widget](#home-screen-widget-p2) | `home_widget` | No |
| P2 | [Onboarding](#onboarding-p2) | — | No |
| P3 | [Backup and restore](#backup-and-restore-p3) | `share_plus`, `file_picker` | No |
| — | [Needs a backend](#needs-a-backend) | Firebase or Supabase | Yes |

### Home-screen widget (P2)

- Shows today's Hijri date and the next fasting day ("White Days in 3 days"); tapping it opens the app on that day.
- **How:** `home_widget` with a native widget (Android `AppWidgetProvider`, iOS WidgetKit). The app writes a small snapshot whenever data or the date changes, and the widget only reads it.

### Onboarding (P2)

A short first-run flow: choose language, choose which fasting types interest you, set a default reminder time, and only then ask for notification permission (and location, if Ramadan mode or the sky header needs it), with a sentence explaining why.

### Backup and restore (P3)

Export reminders, settings and the fasting log to a versioned JSON file and restore it on a new phone. This avoids accounts while still letting users keep their history.

### Needs a backend

These need a server or an account, so they come only after the offline features above:

- **Sync across devices** with an account (Firebase Auth + Firestore, or Supabase).
- **Family or group challenges**: fast together and see each other's progress.
- **Remote content and moon-sighting updates**: update hadith text, or the per-country Hijri offset, without an app release (e.g. Firebase Remote Config).
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
