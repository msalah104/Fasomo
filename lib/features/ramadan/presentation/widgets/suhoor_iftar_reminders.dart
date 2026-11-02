import 'dart:async';

import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/suhoor_iftar_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// "Suhoor and iftar" on the Reminders tab, with what is on. Tapping it
/// opens the [SuhoorIftarSheet].
class SuhoorIftarReminderCard extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    return BlocConsumer<SuhoorIftarBloc, SuhoorIftarState>(
      listenWhen: (previous, current) =>
          current.failure != null && current != previous,
      listener: (context, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localization.settingSaveFailed)),
      ),
      builder: (context, state) {
        final settings = state.settings;
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              // The icon changes shape with the state, not only colour.
              leading: Icon(
                settings.anyEnabled
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                color: settings.anyEnabled
                    ? colors.accent
                    : colors.onSurfaceMuted,
              ),
              title: Text(localization.suhoorIftarReminders),
              subtitle: Text(localization.suhoorIftarSummary(settings)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => SuhoorIftarSheet.show(context),
            ),
          ),
        );
      },
    );
  }
}

/// A switch and the lead time for each of suhoor and iftar, and whether
/// they also run on other fasting days. Every change is saved at once.
class SuhoorIftarSheet extends StatelessWidget {
  const new({super.key});

  static void show(BuildContext context) => unawaited(
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SuhoorIftarSheet(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = context.select<SuhoorIftarBloc, SuhoorIftarSettings>(
      (bloc) => bloc.state.settings,
    );
    void update(SuhoorIftarSettings next) =>
        context.read<SuhoorIftarBloc>().add(SuhoorIftarSettingsChanged(next));

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localization.suhoorIftarReminders,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              localization.suhoorIftarHint,
              style: theme.textTheme.bodyMedium,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localization.suhoorReminder),
              value: settings.suhoorEnabled,
              onChanged: (on) => update(settings.copyWith(suhoorEnabled: on)),
            ),
            if (settings.suhoorEnabled)
              _LeadTimeChips(
                options: SuhoorIftarSettings.suhoorOptions,
                selected: settings.suhoorMinutesBeforeFajr,
                labelOf: localization.suhoorMinutesBefore,
                onSelected: (minutes) => update(
                  settings.copyWith(suhoorMinutesBeforeFajr: minutes),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localization.iftarReminder),
              value: settings.iftarEnabled,
              onChanged: (on) => update(settings.copyWith(iftarEnabled: on)),
            ),
            if (settings.iftarEnabled)
              _LeadTimeChips(
                options: SuhoorIftarSettings.iftarOptions,
                selected: settings.iftarMinutesBeforeMaghrib,
                labelOf: localization.iftarMinutesBefore,
                onSelected: (minutes) => update(
                  settings.copyWith(iftarMinutesBeforeMaghrib: minutes),
                ),
              ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(localization.suhoorIftarOtherDays),
              subtitle: Text(localization.suhoorIftarOtherDaysDetail),
              value: settings.onOtherFastingDays,
              onChanged: (on) =>
                  update(settings.copyWith(onOtherFastingDays: on)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeadTimeChips extends StatelessWidget {
  const new({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<int> options;
  final int selected;
  final String Function(int minutes) labelOf;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    // A chosen chip shows a tick, so the choice is not colour alone.
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final minutes in options)
          ChoiceChip(
            label: Text(labelOf(minutes)),
            selected: minutes == selected,
            onSelected: (_) => onSelected(minutes),
          ),
      ],
    );
  }
}

extension on AppLocalizations {
  /// "Suhoor: 45 min before Fajr · Iftar: At Maghrib", or "Off".
  String suhoorIftarSummary(SuhoorIftarSettings settings) {
    final parts = [
      if (settings.suhoorEnabled)
        suhoorIftarSummaryItem(
          suhoorReminder,
          suhoorMinutesBefore(settings.suhoorMinutesBeforeFajr),
        ),
      if (settings.iftarEnabled)
        suhoorIftarSummaryItem(
          iftarReminder,
          iftarMinutesBefore(settings.iftarMinutesBeforeMaghrib),
        ),
    ];
    return parts.isEmpty ? suhoorIftarOff : parts.join(' · ');
  }
}
