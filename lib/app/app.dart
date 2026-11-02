import 'package:fasomo/app/announcement_topic_sync.dart';
import 'package:fasomo/app/app_shell.dart';
import 'package:fasomo/core/di/injection_container.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/ramadan_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/suhoor_iftar_bloc.dart';
import 'package:fasomo/features/reminders/presentation/bloc/notification_tone_bloc.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/prayer_settings_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:fasomo/features/splash/presentation/pages/splash_page.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FasomoApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LanguageBloc>()),
        BlocProvider(create: (_) => sl<ThemeBloc>()),
        BlocProvider(create: (_) => sl<HijriAdjustmentBloc>()),
        BlocProvider(create: (_) => sl<PrayerSettingsBloc>()),
        BlocProvider(create: (_) => sl<HomeBloc>()..add(const LoadHomeData())),
        // App-wide so the shell can refresh it when what it depends on
        // changes; it ticks only while its card is in view.
        BlocProvider(create: (_) => sl<RamadanBloc>()),
        BlocProvider(
          create: (_) => sl<CalendarBloc>()..add(const LoadCalendar()),
        ),
        BlocProvider(
          create: (_) => sl<ReminderBloc>()..add(const LoadReminders()),
        ),
        BlocProvider(create: (_) => sl<NotificationToneBloc>()),
        BlocProvider(create: (_) => sl<SuhoorIftarBloc>()),
        BlocProvider(
          create: (_) => sl<TrackerBloc>()..add(const LoadTracker()),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Both are read synchronously when the blocs are built, so the
          // first frame already has the right language and brightness.
          final locale = context.select<LanguageBloc, Locale?>(
            (bloc) => bloc.state.locale,
          );
          final themeMode = context.select<ThemeBloc, ThemeMode>(
            (bloc) => bloc.state.themeMode,
          );
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            themeMode: themeMode,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: AnnouncementTopicSync(
              sync: sl(),
              child: const _LaunchGate(),
            ),
          );
        },
      ),
    );
  }
}

/// Plays the splash once per launch, then cross-fades into the [AppShell].
class _LaunchGate extends StatefulWidget {
  const new();

  @override
  State<_LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<_LaunchGate> {
  static const _fade = Duration(milliseconds: 600);

  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : _fade,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _splashDone
          ? const AppShell()
          : SplashPage(onFinished: () => setState(() => _splashDone = true)),
    );
  }
}
