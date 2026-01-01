import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/app_localizations.dart';
import '../bloc/reminder_bloc.dart';
import '../widgets/reminder_card.dart';

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state.status == ReminderStatus.loading &&
            state.reminders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ReminderStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? localization.errorOccurred),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReminderBloc>().add(LoadReminders());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.reminderSettings,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your fasting day reminders',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Active Reminders',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              if (state.reminders.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reminders set yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add reminders from the Home page',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...state.reminders.map(
                  (reminder) => ReminderCard(reminder: reminder),
                ),
            ],
          ),
        );
      },
    );
  }
}
