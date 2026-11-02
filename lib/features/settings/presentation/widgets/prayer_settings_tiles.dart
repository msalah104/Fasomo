import 'dart:async';

import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/presentation/prayer_text.dart';
import 'package:fasomo/features/settings/presentation/bloc/prayer_settings_bloc.dart';
import 'package:fasomo/features/settings/presentation/widgets/prayer_adjustments_dialog.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_choice_dialog.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The method choice, where `null` is automatic. Wrapped so a dismissed
/// dialog (`null`) can't be mistaken for choosing automatic.
typedef _MethodOption = ({CalculationMethod? method});

/// The calculation method: automatic by country (showing what it resolved
/// to) or one chosen from the list.
class PrayerMethodTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final state = context.watch<PrayerSettingsBloc>().state;
    final method = state.settings.method;
    return ListTile(
      leading: const Icon(Icons.calculate_outlined),
      title: Text(localization.prayerMethod),
      subtitle: Text(
        method == null
            ? localization.prayerMethodAutomaticResolved(
                localization.calculationMethodName(state.methodInUse),
              )
            : localization.calculationMethodName(method),
      ),
      onTap: () => unawaited(_choose(context, method)),
    );
  }

  Future<void> _choose(BuildContext context, CalculationMethod? current) async {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<PrayerSettingsBloc>();
    final choice = await showSettingsChoice<_MethodOption>(
      context: context,
      title: localization.prayerMethod,
      options: [
        (method: null),
        for (final method in CalculationMethod.values) (method: method),
      ],
      selected: (method: current),
      labelOf: (option) => switch (option.method) {
        null => localization.prayerMethodAutomatic,
        final method => localization.calculationMethodName(method),
      },
    );
    if (choice != null) bloc.add(PrayerMethodChanged(choice.method));
  }
}

/// Standard or Hanafi Asr.
class AsrMethodTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final current = context.select<PrayerSettingsBloc, AsrMethod>(
      (bloc) => bloc.state.settings.asrMethod,
    );
    return ListTile(
      leading: const Icon(Icons.wb_sunny_outlined),
      title: Text(localization.asrMethod),
      subtitle: Text(localization.asrMethodName(current)),
      onTap: () => unawaited(_choose(context, current)),
    );
  }

  Future<void> _choose(BuildContext context, AsrMethod current) async {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<PrayerSettingsBloc>();
    final choice = await showSettingsChoice(
      context: context,
      title: localization.asrMethod,
      options: AsrMethod.values,
      selected: current,
      labelOf: localization.asrMethodName,
    );
    if (choice != null) bloc.add(AsrMethodChanged(choice));
  }
}

/// How Fajr and Isha are capped where twilight lasts all night.
class HighLatitudeRuleTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final current = context.select<PrayerSettingsBloc, HighLatitudeRule>(
      (bloc) => bloc.state.settings.highLatitudeRule,
    );
    return ListTile(
      leading: const Icon(Icons.public_outlined),
      title: Text(localization.highLatitudeRule),
      subtitle: Text(
        '${localization.highLatitudeRuleName(current)}\n'
        '${localization.highLatitudeHint}',
      ),
      isThreeLine: true,
      onTap: () => unawaited(_choose(context, current)),
    );
  }

  Future<void> _choose(BuildContext context, HighLatitudeRule current) async {
    final localization = AppLocalizations.of(context);
    final bloc = context.read<PrayerSettingsBloc>();
    final choice = await showSettingsChoice(
      context: context,
      title: localization.highLatitudeRule,
      options: HighLatitudeRule.values,
      selected: current,
      labelOf: localization.highLatitudeRuleName,
    );
    if (choice != null) bloc.add(HighLatitudeRuleChanged(choice));
  }
}

/// Per-prayer minute adjustments; opens [PrayerAdjustmentsDialog].
class PrayerAdjustmentsTile extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final adjustments = context.select<PrayerSettingsBloc, PrayerAdjustments>(
      (bloc) => bloc.state.settings.adjustments,
    );
    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(localization.prayerAdjustments),
      subtitle: Text(localization.adjustmentsSummary(adjustments)),
      onTap: () => unawaited(PrayerAdjustmentsDialog.show(context)),
    );
  }
}
