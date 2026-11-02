import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/ramadan_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/ramadan_countdown_card.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/ramadan_day_card.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Builds the "fasted today" control for the checklist, given today's two
/// dates; the app shell passes the tracker's toggle.
typedef FastedActionBuilder = Widget Function(
  DateTime gregorianDate,
  HijriDate hijriDate,
);

/// What Home shows for Ramadan: the countdown in the month before it, the
/// day's card during it, and nothing the rest of the year.
///
/// Keeps [RamadanBloc] ticking only while it can be seen: not with the app
/// in the background and not while another tab is showing. Needs a
/// [RamadanBloc] above it.
class RamadanSpotlight extends StatefulWidget {
  const new({this.fastedActionBuilder, super.key});

  final FastedActionBuilder? fastedActionBuilder;

  @override
  State<RamadanSpotlight> createState() => _RamadanSpotlightState();
}

class _RamadanSpotlightState extends State<RamadanSpotlight> {
  late final AppLifecycleListener _lifecycle;

  /// Whether this tab is showing, from [TickerMode]. Starts false so the
  /// first build resumes the ticks.
  bool _inView = false;

  /// Kept from the last dependency change so [dispose] can still reach it.
  late RamadanBloc _bloc;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onShow: () {
        if (_inView) _bloc.add(const RamadanResumed());
      },
      onHide: () => _bloc.add(const RamadanPaused()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<RamadanBloc>();
    final inView = TickerMode.valuesOf(context).enabled;
    if (inView != _inView) {
      _inView = inView;
      _bloc.add(inView ? const RamadanResumed() : const RamadanPaused());
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _bloc.add(const RamadanPaused());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RamadanBloc, RamadanState>(
      listenWhen: (previous, current) =>
          current.saveFailure != null &&
          previous.saveFailure != current.saveFailure,
      listener: (context, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).ramadanChecklistSaveFailed,
          ),
        ),
      ),
      builder: (context, state) {
        final card = switch (state.overview) {
          RamadanNotNear() => null,
          final RamadanCountdown countdown => RamadanCountdownCard(
            countdown: countdown,
          ),
          final RamadanDay day => RamadanDayCard(
            day: day,
            checklist: state.checklist,
            checklistFailed: state.loadFailure != null,
            fastedAction: widget.fastedActionBuilder?.call(
              day.date,
              day.hijriDate,
            ),
          ),
        };
        // The gap above comes with the card, so nothing is left when
        // there is no card.
        return card == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsetsDirectional.only(top: 24),
                child: card,
              );
      },
    );
  }
}
