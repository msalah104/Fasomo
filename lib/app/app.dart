import 'package:fasomo/app/app_shell.dart';
import 'package:fasomo/core/di/injection_container.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
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
        BlocProvider(create: (_) => sl<HomeBloc>()..add(const LoadHomeData())),
        BlocProvider(
          create: (_) => sl<CalendarBloc>()..add(const LoadCalendar()),
        ),
        BlocProvider(
          create: (_) => sl<ReminderBloc>()..add(const LoadReminders()),
        ),
      ],
      child: BlocSelector<LanguageBloc, LanguageState, Locale?>(
        selector: (state) => state.locale,
        builder: (context, locale) {
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(Brightness.light),
            darkTheme: buildAppTheme(Brightness.dark),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
