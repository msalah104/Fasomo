# Fasomo - Islamic Fasting Tracker

A Flutter app that helps Muslims keep track of the recommended (Sunnah) and obligatory fasting days on the Hijri calendar, with reminders, in Arabic and English.

## Features

### 🏠 Home
- **Today in both calendars**: the current Hijri (Umm al-Qura) date with the Gregorian date.
- **Upcoming fasting days**: the next five fasting days in the coming 30 days, including next month's White Days. A day that is several kinds at once (say, a White Day on a Monday) is listed once with all of them.
- **One-tap reminders**: turn on a reminder for a fasting type straight from its card.

### 📅 Calendar
- **Full Hijri month view** for any month from 1356 to 1500 AH, with month navigation.
- **Colour- and icon-coded fasting days**:
  - 🟢 Green: White Days (13th, 14th, 15th)
  - 🟠 Orange: Monday & Thursday
  - 🟣 Purple: Ramadan
  - 🩵 Teal: Six Days of Shawwal
  - 🔵 Blue: special days (Arafah, Ashura, Tasua)
- **Day details**: tap a day to see both dates and what each fasting type means.

### 🔔 Reminders
- **Real fire times**, worked out from each actual fasting date:
  - **Day before**: 8:00 PM the evening before
  - **Morning of the day**: 7:00 AM on the fasting day
  - **Custom**: any time, on the day itself or the day before
- **Custom messages** in place of the default text.
- **One notification per day**: if a day matches several reminders, only the most important type fires.
- **Reliable scheduling**: reminders are re-synced whenever the app opens or returns to the foreground, after every change and when the language changes. Up to 50 upcoming reminders (60 days ahead) are kept scheduled, which stays under the iOS limit of 64.
- Permission is requested when you first turn a reminder on, not at launch.

### 🌐 Language
- Arabic and English, with full right-to-left layout in Arabic.
- Choose **System default**, **English** or **العربية** from the language menu. The choice is saved.

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
│   ├── presentation/       # Shared labels, colours, date text
│   └── themes/
├── features/
│   ├── home/  calendar/  reminders/  settings/  about/
│   │   ├── domain/         # Entities, repository interfaces, use cases (pure Dart)
│   │   ├── data/           # Repository implementations
│   │   └── presentation/   # Blocs, pages, widgets
├── l10n/                   # app_en.arb, app_ar.arb (+ generated/)
└── main.dart
```

- **Typed errors**: repositories return `Result<T, Failure>` and never throw for expected failures. Blocs switch on the result exhaustively.
- **Injected clock**: domain and data code read "now" from `package:clock`, so date logic is tested with fixed times.
- **Notifications** follow one path: the stored reminders and the real fasting dates produce the desired set, which is reconciled against the OS pending set. Ids are deterministic, so an unchanged sync does nothing and an edit reschedules. Only `fln_notification_gateway.dart` imports the plugin.

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

- [ ] **Fasting tracker and streaks**: mark the days you fasted and see your streaks and monthly totals.
- [ ] **Ramadan mode with prayer times**: suhoor and iftar times for your location, with reminders tied to Fajr and Maghrib.
- [ ] **Qada tracker**: count the Ramadan days you owe and log them as you make them up.
- [ ] **Home-screen widget**: today's Hijri date and the next fasting day.
- [ ] **Dark mode**: a complete dark theme with a light/dark/system switch.
- [ ] **Hijri date adjustment**: shift the calendar by ±1–2 days to match local moon sighting.
- [ ] **Notification tones**: choose the sound for reminders.

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
