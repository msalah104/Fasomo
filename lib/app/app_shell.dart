import 'package:fasomo/features/about/presentation/pages/about_page.dart';
import 'package:fasomo/features/calendar/presentation/pages/calendar_page.dart';
import 'package:fasomo/features/home/presentation/pages/home_page.dart';
import 'package:fasomo/features/reminders/presentation/bloc/reminder_bloc.dart';
import 'package:fasomo/features/reminders/presentation/localized_reminder_copy.dart';
import 'package:fasomo/features/reminders/presentation/pages/reminder_settings_page.dart';
import 'package:fasomo/features/settings/presentation/widgets/language_menu_button.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The bottom-navigation shell. It is the one place that composes features,
/// so features never import each other.
class AppShell extends StatefulWidget {
  const new({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  /// The foreground sync is the reliability backbone for reminders: it
  /// refills the rolling window and repairs anything the OS dropped.
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<ReminderBloc>().add(const SyncRequested()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs on the first build and whenever the language changes.
    context.read<ReminderBloc>().add(
      ReminderCopyChanged(LocalizedReminderCopy(AppLocalizations.of(context))),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final titles = [
      localization.home,
      localization.calendar,
      localization.reminders,
      localization.about,
    ];

    return Scaffold(
      // Home draws its own sky header in place of the app bar.
      appBar: _selectedIndex == 0
          ? null
          : AppBar(
              title: Text(titles[_selectedIndex]),
              actions: const [LanguageMenuButton()],
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          CalendarPage(),
          ReminderSettingsPage(),
          AboutPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: titles[0],
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: titles[1],
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: titles[2],
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outlined),
            selectedIcon: const Icon(Icons.info),
            label: titles[3],
          ),
        ],
      ),
    );
  }
}

/// Home wired to the reminders feature.
class _HomeTab extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final reminders = context.watch<ReminderBloc>().state;
    return HomePage(
      isReminderOn: reminders.isEnabledFor,
      onToggleReminder: (type) =>
          context.read<ReminderBloc>().add(ToggleReminder(type)),
      headerActionBuilder: (color) => LanguageMenuButton(color: color),
    );
  }
}
