import 'package:fasomo/core/theme/app_colors.dart';
import 'package:fasomo/features/home/domain/entities/week_day.dart';
import 'package:fasomo/features/home/presentation/sky_palette.dart';
import 'package:fasomo/features/home/presentation/widgets/week_strip.dart';
import 'package:flutter/material.dart';

/// Pins the [WeekStrip] to the top of Home once the sky has scrolled away.
///
/// Above the strip is a [band] of colour: the sky's ground while it is
/// visible, so the strip overlaps the sky's bottom edge, and the sky's top
/// colour once pinned, so it joins the status bar band.
class WeekHeaderDelegate extends SliverPersistentHeaderDelegate {
  new({
    required this.week,
    required this.selectedDate,
    required this.onDaySelected,
    required this.palette,
    required this.textScaler,
  });

  /// Height of the coloured band the strip overlaps.
  static const double band = 24;

  /// Space below the strip.
  static const double gap = 8;

  final List<WeekDay> week;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;
  final SkyPalette palette;
  final TextScaler textScaler;

  double get _stripHeight => WeekStrip.heightFor(textScaler);

  @override
  double get minExtent => band + _stripHeight + gap;

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isPinned = overlapsContent || shrinkOffset > 0;
    return Stack(
      children: [
        Column(
          children: [
            ColoredBox(
              color: isPinned ? palette.top : palette.ground,
              child: const SizedBox(height: band * 2, width: double.infinity),
            ),
            Expanded(
              child: ColoredBox(
                color: AppColors.of(context).surface,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
        PositionedDirectional(
          top: band,
          start: 16,
          end: 16,
          height: _stripHeight,
          child: WeekStrip(
            week: week,
            selectedDate: selectedDate,
            onDaySelected: onDaySelected,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(WeekHeaderDelegate old) =>
      old.week != week ||
      old.selectedDate != selectedDate ||
      old.palette != palette ||
      old.textScaler != textScaler;
}
