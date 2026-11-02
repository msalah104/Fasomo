import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shifts every Hijri date in the app by −2..+2 days, explains why, and
/// previews today's date with the shift applied.
class HijriAdjustmentTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final state = context.watch<HijriAdjustmentBloc>().state;
    final today = state.today;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.nightlight_outlined),
          title: Text(localization.hijriAdjustment),
          subtitle: Text(localization.hijriAdjustmentExplanation),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 0),
          child: _OffsetPicker(selected: state.offset),
        ),
        if (today != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 8),
            child: Text(
              localization.hijriAdjustmentToday(
                localization.formatHijri(today),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _OffsetPicker extends StatelessWidget {
  const new({required this.selected});

  final HijriOffset selected;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return SegmentedButton<HijriOffset>(
      showSelectedIcon: false,
      segments: [
        for (final offset in HijriOffset.values)
          ButtonSegment(
            value: offset,
            label: Text(
              _signedDays(offset.days),
              semanticsLabel: localization.hijriOffsetDescription(offset),
            ),
          ),
      ],
      selected: {selected},
      onSelectionChanged: (choice) => context.read<HijriAdjustmentBloc>().add(
        HijriOffsetChanged(choice.single),
      ),
    );
  }
}

/// "+1", "0" or "−2" (a real minus sign), isolated left-to-right so the
/// sign stays in front of the number in right-to-left text.
String _signedDays(int days) => switch (days) {
  0 => '0',
  > 0 => '\u2066+$days\u2069',
  _ => '\u2066\u2212${-days}\u2069',
};

extension on AppLocalizations {
  String hijriOffsetDescription(HijriOffset offset) => switch (offset.days) {
    0 => hijriOffsetNone,
    > 0 => hijriOffsetAdd(offset.days),
    _ => hijriOffsetSubtract(-offset.days),
  };
}
