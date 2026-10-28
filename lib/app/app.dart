import 'package:fasomo/app/app_shell.dart';
import 'package:fasomo/core/di/injection_container.dart';
import 'package:fasomo/core/themes/app_theme.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/home/presentation/bloc/home_bloc.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FasomoApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<HomeBloc>()..add(const LoadHomeData())),
        BlocProvider(
          create: (_) => sl<CalendarBloc>()..add(const LoadCalendar()),
        ),
        BlocProvider(
          create: (_) => sl<ReminderBloc>()..add(const LoadReminders()),
        ),
      ],
      child: BlocSelector<HomeBloc, HomeState, Locale>(
        selector: (state) => state.locale,
        builder: (context, locale) {
          return MaterialApp(
            title: 'Fasomo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            locale: locale,
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'SA')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AppShell(),
          );
        },
      ),
    );
  }
}
