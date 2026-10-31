import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/presentation/sky_palette.dart';
import 'package:fasomo/features/home/presentation/sky_text.dart';
import 'package:fasomo/features/home/presentation/widgets/location_chip.dart';
import 'package:fasomo/features/home/presentation/widgets/sky_painter.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// The full-bleed live sky at the top of Home, below the status bar: the sun
/// or moon where they really are over the user, the logo mark, an optional
/// action, and today's date and sun times on the ground band. It scrolls
/// away; the week strip stays.
class SkyHero extends StatelessWidget {
  const new({
    required this.dateInfo,
    required this.scene,
    required this.palette,
    this.actionBuilder,
    this.locationChip,
    super.key,
  });

  /// Height of the sky below the status bar.
  static const double skyHeight = 250;

  final HijriDateInfo dateInfo;

  /// `null` until the sky is first computed; the plain sky shows meanwhile.
  final SkyScene? scene;
  final SkyPalette palette;

  /// Builds a trailing action (the language menu) in the colour that reads on
  /// the sky.
  final Widget Function(Color color)? actionBuilder;

  /// Shown before the action, e.g. a [LocationChip].
  final Widget? locationChip;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final actionBuilder = this.actionBuilder;
    final scene = this.scene;
    final sunTimes = scene == null ? null : localization.sunTimes(scene);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: palette.overlayStyle,
      child: SizedBox(
        height: skyHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (scene == null)
              ColoredBox(color: palette.top)
            else
              // The painting is described in words by a sibling, so it
              // doesn't need to be read itself.
              Semantics(
                label: localization.skyDescription(scene),
                image: true,
                child: ExcludeSemantics(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: SkyPainter(
                        scene: scene,
                        palette: palette,
                        textDirection: Directionality.of(context),
                      ),
                    ),
                  ),
                ),
              ),
            PositionedDirectional(
              top: 8,
              start: 16,
              end: 4,
              child: Row(
                children: [
                  LogoMark(
                    color: palette.logoInk,
                    dotColor: palette.logoDot,
                    semanticLabel: localization.appName,
                  ),
                  const Spacer(),
                  ?locationChip,
                  if (actionBuilder != null) actionBuilder(palette.ink),
                ],
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateRow(dateInfo: dateInfo, color: palette.groundInk),
                  if (sunTimes != null)
                    ExcludeSemantics(
                      child: Text(
                        sunTimes,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: palette.groundInk,
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
