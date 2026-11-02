import 'dart:async';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/location/city_picker_page.dart';
import 'package:fasomo/core/presentation/location/location_choice_sheet.dart';
import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/core/theme/sky_palette.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/presentation/bloc/sky_bloc.dart';
import 'package:fasomo/features/home/presentation/sky_text.dart';
import 'package:fasomo/features/home/presentation/widgets/location_chip.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_painter.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// The live sky at the top of Home: the real sun or moon on its arc over
/// the skyline, the location chip, and today's dates and rise and set times
/// on the ground band below.
///
/// It keeps [SkyBloc] ticking only while it can be seen: not with the app
/// in the background, and not while another tab is showing.
class SkyHeader extends StatefulWidget {
  const new({
    required this.dateInfo,
    required this.palette,
    this.actionBuilder,
    super.key,
  });

  /// Height of the painted sky; the ground band below grows with the text.
  static const double skyHeight = 196;

  final HijriDateInfo dateInfo;

  /// The sky's colours now, chosen by the caller from the same state.
  final SkyPalette palette;

  /// Builds a trailing action (the language menu) in a colour that reads on
  /// the sky.
  final Widget Function(Color color)? actionBuilder;

  @override
  State<SkyHeader> createState() => _SkyHeaderState();
}

class _SkyHeaderState extends State<SkyHeader> {
  late final AppLifecycleListener _lifecycle;

  /// Whether this tab is showing, from [TickerMode].
  bool _inView = true;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onShow: () {
        if (_inView) _bloc.add(const SkyResumed());
      },
      onHide: () => _bloc.add(const SkyPaused()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final inView = TickerMode.valuesOf(context).enabled;
    if (inView != _inView) {
      _inView = inView;
      _bloc.add(inView ? const SkyResumed() : const SkyPaused());
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  SkyBloc get _bloc => context.read<SkyBloc>();

  Future<void> _changeLocation() async {
    final bloc = _bloc;
    final choice = await LocationChoiceSheet.show(context);
    if (!mounted) return;
    switch (choice) {
      case LocationChoice.device:
        bloc.add(const SkyDeviceLocationRequested());
      case LocationChoice.city:
        await _pickCity();
      case null:
        break;
    }
  }

  Future<void> _pickCity() async {
    final bloc = _bloc;
    final location = bloc.state.scene.location;
    final city = await CityPickerPage.show(
      context,
      selected: location.isApproximate ? null : location.city,
    );
    if (city != null) bloc.add(SkyCityChosen(city));
  }

  void _showFailure(BuildContext context, SkyState state) {
    final failure = state.locationFailure;
    if (failure == null) return;
    final localization = AppLocalizations.of(context);
    final chooseCity = SnackBarAction(
      label: localization.locationChooseCity,
      onPressed: () => unawaited(_pickCity()),
    );
    final (message, action) = switch (failure) {
      LocationPermissionDenied(permanently: true) => (
        localization.locationDeniedForever,
        SnackBarAction(
          label: localization.openSettings,
          onPressed: () => _bloc.add(const SkyLocationSettingsRequested()),
        ),
      ),
      LocationPermissionDenied() => (localization.locationDenied, chooseCity),
      LocationServiceDisabled() => (
        localization.locationServiceOff,
        chooseCity,
      ),
      LocationUnavailable() => (localization.locationUnavailable, chooseCity),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return BlocConsumer<SkyBloc, SkyState>(
      listenWhen: (previous, current) =>
          current.locationFailure != null &&
          current.locationFailure != previous.locationFailure,
      listener: _showFailure,
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: SkyHeader.skyHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _SkyCanvas(scene: state.scene, palette: palette),
                PositionedDirectional(
                  top: 4,
                  start: 16,
                  end: 4,
                  child: _TopRow(
                    palette: palette,
                    actionBuilder: widget.actionBuilder,
                    chip: LocationChip(
                      location: state.scene.location,
                      isLocating: state.isLocating,
                      palette: palette,
                      onPressed: () => unawaited(_changeLocation()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _GroundBand(
            dateInfo: widget.dateInfo,
            scene: state.scene,
            palette: palette,
          ),
        ],
      ),
    );
  }
}

/// The painted sky, described for screen readers in one label.
class _SkyCanvas extends StatelessWidget {
  const new({required this.scene, required this.palette});

  final SkyScene scene;
  final SkyPalette palette;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: AppLocalizations.of(context).skySemanticsLabel(scene),
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SkyPainter(
            scene: scene,
            palette: palette,
            textDirection: Directionality.of(context),
          ),
        ),
      ),
    );
  }
}

/// The logo mark, the location chip and the trailing action.
class _TopRow extends StatelessWidget {
  const new({
    required this.palette,
    required this.chip,
    required this.actionBuilder,
  });

  final SkyPalette palette;
  final Widget chip;
  final Widget Function(Color color)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    final actionBuilder = this.actionBuilder;
    return Row(
      children: [
        LogoMark(
          color: palette.logoInk,
          dotColor: palette.logoDot,
          semanticLabel: AppLocalizations.of(context).appName,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(alignment: AlignmentDirectional.centerEnd, child: chip),
        ),
        if (actionBuilder != null) actionBuilder(palette.ink),
      ],
    );
  }
}

/// Today's dates and the rise and set times, on the ground below the
/// skyline, where the contrast does not depend on the sky.
class _GroundBand extends StatelessWidget {
  const new({
    required this.dateInfo,
    required this.scene,
    required this.palette,
  });

  final HijriDateInfo dateInfo;
  final SkyScene scene;
  final SkyPalette palette;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: palette.ground,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 2, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DateRow(dateInfo: dateInfo, color: palette.groundInk),
            const SizedBox(height: 4),
            _TimesRow(scene: scene, color: palette.groundInk),
          ],
        ),
      ),
    );
  }
}

/// Today's Hijri date and the short Gregorian date on one row.
class _DateRow extends StatelessWidget {
  const new({required this.dateInfo, required this.color});

  final HijriDateInfo dateInfo;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            localization.formatHijri(dateInfo.hijriDate),
            style: textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat.MMMEd(
            localization.localeName,
          ).format(dateInfo.gregorianDate),
          style: textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}

/// The rise and set times at the start and end of the band.
class _TimesRow extends StatelessWidget {
  const new({required this.scene, required this.color});

  final SkyScene scene;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final (start, end) = skyEventTimes(scene);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 12,
      runSpacing: 2,
      children: [
        if (start != null) _EventLabel(event: start, color: color),
        if (end != null) _EventLabel(event: end, color: color),
      ],
    );
  }
}

class _EventLabel extends StatelessWidget {
  const new({required this.event, required this.color});

  final SkyEventTime event;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).skyEventLabel(
      event,
      use24HourClock: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          switch (event.kind) {
            SkyEventKind.sunrise || SkyEventKind.sunset => Icons.wb_twilight,
            SkyEventKind.moonrise => Icons.nightlight_outlined,
          },
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
