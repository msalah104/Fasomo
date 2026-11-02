import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/presentation/prayer_text.dart';
import 'package:fasomo/features/settings/presentation/bloc/prayer_settings_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Minutes to add to or take from each prayer time, one stepper per
/// prayer. Every step applies and saves at once.
class PrayerAdjustmentsDialog extends StatelessWidget {
  const new({super.key});

  /// Shows the dialog over [context], which must have a
  /// [PrayerSettingsBloc] above it.
  static Future<void> show(BuildContext context) {
    final bloc = context.read<PrayerSettingsBloc>();
    return showDialog<void>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const PrayerAdjustmentsDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final adjustments = context.select<PrayerSettingsBloc, PrayerAdjustments>(
      (bloc) => bloc.state.settings.adjustments,
    );
    final bloc = context.read<PrayerSettingsBloc>();

    return AlertDialog(
      title: Text(localization.prayerAdjustments),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              localization.prayerAdjustmentsHint,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            for (final prayer in Prayer.values)
              _AdjustmentRow(
                prayer: prayer,
                minutes: adjustments[prayer],
                onChanged: (minutes) =>
                    bloc.add(PrayerAdjustmentChanged(prayer, minutes)),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: adjustments.isNone
              ? null
              : () => bloc.add(const PrayerAdjustmentsReset()),
          child: Text(localization.reset),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localization.close),
        ),
      ],
    );
  }
}

class _AdjustmentRow extends StatelessWidget {
  const new({
    required this.prayer,
    required this.minutes,
    required this.onChanged,
  });

  final Prayer prayer;
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final name = localization.prayerName(prayer);
    return Row(
      children: [
        Expanded(child: Text(name)),
        IconButton(
          icon: const Icon(Icons.remove),
          tooltip: localization.prayerAdjustEarlier(name),
          onPressed: minutes > PrayerAdjustments.min
              ? () => onChanged(minutes - 1)
              : null,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 64),
          child: Text(
            localization.adjustmentMinutes(minutes),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: localization.prayerAdjustLater(name),
          onPressed: minutes < PrayerAdjustments.max
              ? () => onChanged(minutes + 1)
              : null,
        ),
      ],
    );
  }
}
