import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:fasomo/features/tracker/presentation/qada_reminder_text.dart';
import 'package:fasomo/features/tracker/presentation/widgets/qada_reminder_sheet.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Make-up reminders" with a summary of what's on. Tapping it opens the
/// [QadaReminderSheet]. Used in the Qada section and on the Reminders tab.
class QadaReminderTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return BlocBuilder<TrackerBloc, TrackerState>(
      buildWhen: (previous, current) =>
          previous.qadaReminders != current.qadaReminders ||
          previous.summary.qada.remaining != current.summary.qada.remaining,
      builder: (context, state) {
        final settings = state.qadaReminders;
        final owing = state.summary.qada.remaining > 0;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            settings.anyEnabled
                ? Icons.notifications_active_outlined
                : Icons.notifications_off_outlined,
            color: settings.anyEnabled ? colors.accent : colors.onSurfaceMuted,
          ),
          title: Text(localization.qadaReminders),
          subtitle: Text(
            [
              localization.qadaReminderSummary(settings),
              if (settings.anyEnabled && !owing) localization.qadaRemindersIdle,
            ].join('\n'),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => QadaReminderSheet.show(context),
        );
      },
    );
  }
}

/// The make-up reminders as a card for the Reminders tab.
class QadaReminderCard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: QadaReminderTile(),
      ),
    );
  }
}
