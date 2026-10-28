import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/logo_mark.dart';
import 'package:fasomo/core/theme/sky_art.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// The full-bleed sky at the top of Home: the static [art] for the time of
/// day, the logo mark, an optional action, and today's date on the ground band.
class SkyHero extends StatelessWidget {
  const new({
    required this.dateInfo,
    required this.art,
    this.actionBuilder,
    super.key,
  });

  /// Height of the sky below the status bar.
  static const double skyHeight = 250;

  /// How far the content below overlaps the sky's bottom edge.
  static const double overlap = 30;

  final HijriDateInfo dateInfo;
  final SkyArt art;

  /// Builds a trailing action (the language menu) in the colour that reads on
  /// [art].
  final Widget Function(Color color)? actionBuilder;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final localization = AppLocalizations.of(context);
    final actionBuilder = this.actionBuilder;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: art.overlayStyle,
      child: SizedBox(
        height: topInset + skyHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: Image.asset(
                art.image,
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            PositionedDirectional(
              top: topInset + 8,
              start: 16,
              end: 4,
              child: Row(
                children: [
                  LogoMark(
                    color: art.logoInk,
                    dotColor: art.logoDot,
                    semanticLabel: localization.appName,
                  ),
                  const Spacer(),
                  if (actionBuilder != null) actionBuilder(art.ink),
                ],
              ),
            ),
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: overlap + 16,
              child: _DateRow(dateInfo: dateInfo, color: art.groundInk),
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
          DateFormat.MMMEd(localization.localeName)
              .format(dateInfo.gregorianDate),
          style: textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
