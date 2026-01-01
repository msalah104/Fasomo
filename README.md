# Fasomo - Islamic Fasting Tracker

A beautiful and comprehensive Flutter app to help Muslims track recommended fasting days (Nawafel) according to the Sunnah of Prophet Muhammad (PBUH).

## Features

### 🏠 Home Page
- **Current Hijri Date**: Display today's Hijri date with corresponding Gregorian date
- **Upcoming Fasting Days**: View the next recommended fasting days
- **Quick Reminders**: Activate reminders for each fasting day with one tap
- **Language Toggle**: Switch between Arabic and English

### 📅 Calendar View
- **Full Hijri Calendar**: Browse any Hijri month
- **Color-Coded Fasting Days**: Visual indicators for different types of fasting:
  - 🟢 Green: White Days (13th, 14th, 15th)
  - 🟠 Orange: Monday & Thursday
  - 🟣 Purple: Ramadan
  - 🔵 Blue: Special days (Arafah, Ashura, Tasua)
- **Day Details**: Tap any date to view detailed information
- **Month Navigation**: Easily switch between months

### 🔔 Reminder Settings
- **Smart Notifications**: Get reminded about upcoming fasting days
- **Flexible Timing**: Choose when to receive reminders:
  - Day before
  - Morning of the day
  - Custom time
- **Custom Messages**: Personalize notification messages
- **Full Control**: Enable/disable and manage all reminders

### ℹ️ About Page
- **App Information**: Learn about Fasomo
- **Islamic References**: Authentic Hadith supporting optional fasting
- **Features Overview**: Discover all app capabilities
- **Contact & Support**: Get help when needed

## Supported Fasting Days

- **White Days (الأيام البيض)**: 13th, 14th, and 15th of every Hijri month
- **Monday & Thursday (الاثنين والخميس)**: Weekly fasting days
- **Day of Arafah (يوم عرفة)**: 9th of Dhul Hijjah
- **Day of Ashura (يوم عاشوراء)**: 10th of Muharram
- **Day of Tasua (يوم تاسوعاء)**: 9th of Muharram
- **Ramadan (رمضان)**: The entire month (obligatory)
- **Six Days of Shawwal (ست من شوال)**: After Eid al-Fitr

## Architecture

This app follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities, themes, constants
│   ├── constants/
│   ├── di/                 # Dependency injection
│   ├── error/
│   ├── themes/
│   ├── usecases/
│   └── utils/
├── features/               # Feature modules
│   ├── home/
│   │   ├── data/          # Data sources & repositories
│   │   ├── domain/        # Entities, repositories, use cases
│   │   └── presentation/  # BLoC, pages, widgets
│   ├── calendar/
│   ├── reminders/
│   └── about/
└── main.dart
```

### Design Patterns Used
- **BLoC Pattern**: For state management
- **Repository Pattern**: For data abstraction
- **Dependency Injection**: Using GetIt
- **SOLID Principles**: Throughout the codebase

## Tech Stack

- **Flutter SDK**: 3.0+
- **State Management**: flutter_bloc
- **Hijri Calendar**: hijri, shamsi_date
- **Local Notifications**: flutter_local_notifications
- **Local Storage**: shared_preferences
- **Dependency Injection**: get_it
- **Localization**: intl, flutter_localizations
- **UI**: Material Design 3, google_fonts

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/msalah104/Fasomo.git
cd Fasomo
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Localization

The app supports two languages:
- 🇬🇧 English
- 🇸🇦 Arabic (العربية)

Language can be toggled from any screen using the language icon in the app bar.

## Permissions

### Android
- `POST_NOTIFICATIONS`: For reminder notifications
- `SCHEDULE_EXACT_ALARM`: For precise notification timing
- `RECEIVE_BOOT_COMPLETED`: To reschedule notifications after device restart

### iOS
- Notification permissions requested at runtime

## Testing

Run tests:
```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Developed with ❤️ to help Muslims maintain Sunnah fasting practices.

## Contact

- **Email**: support@fasomo.app
- **Website**: www.fasomo.app
- **GitHub**: github.com/msalah104/Fasomo

---

**May Allah accept our fasting and good deeds. Ameen.** 🤲
