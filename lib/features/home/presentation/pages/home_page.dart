import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_localizations.dart';
import '../../../calendar/presentation/pages/calendar_page.dart';
import '../../../reminders/presentation/pages/reminder_settings_page.dart';
import '../../../about/presentation/pages/about_page.dart';
import '../bloc/home_bloc.dart';
import '../widgets/current_date_card.dart';
import '../widgets/fasting_day_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    final pages = [
      _buildHomePage(context, localization),
      const CalendarPage(),
      const ReminderSettingsPage(),
      const AboutPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(localization)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              context.read<HomeBloc>().add(ToggleLanguage());
            },
            tooltip: 'Toggle Language',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: localization.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: localization.calendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_outlined),
            selectedIcon: const Icon(Icons.notifications),
            label: localization.reminders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.info_outlined),
            selectedIcon: const Icon(Icons.info),
            label: localization.about,
          ),
        ],
      ),
    );
  }

  String _getTitle(AppLocalizations localization) {
    switch (_selectedIndex) {
      case 0:
        return localization.home;
      case 1:
        return localization.calendar;
      case 2:
        return localization.reminders;
      case 3:
        return localization.about;
      default:
        return localization.appName;
    }
  }

  Widget _buildHomePage(BuildContext context, AppLocalizations localization) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == HomeStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(localization.errorOccurred),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(LoadHomeData());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<HomeBloc>().add(RefreshHomeData());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Hijri Date Card
                if (state.currentDate != null)
                  CurrentDateCard(dateInfo: state.currentDate!),

                const SizedBox(height: 24),

                // Upcoming Fasting Days Section
                Text(
                  localization.upcomingFastingDays,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                if (state.upcomingFastingDays.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          localization.noUpcomingFasting,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  )
                else
                  ...state.upcomingFastingDays.map(
                    (fastingDay) => FastingDayCard(
                      fastingDay: fastingDay,
                      locale: state.locale,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
