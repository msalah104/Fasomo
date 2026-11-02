import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_month.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_mini_month.dart';
import 'package:flutter/material.dart';

/// The twelve months of a Hijri year as a grid of mini months. Tapping a
/// month opens it.
///
/// The column count follows the width this view is given, not the device:
/// two on a compact width, three on a medium one and four when expanded.
class CalendarYearView extends StatelessWidget {
  const new({
    required this.months,
    required this.onMonthTap,
    this.footer,
    super.key,
  });

  final List<CalendarMonth> months;
  final ValueChanged<HijriMonth> onMonthTap;

  /// Scrolls in after the last row, e.g. the legend.
  final Widget? footer;

  /// Material 3 window size class breakpoints, applied to the local width.
  static int columnsFor(double width) => switch (width) {
    < 600 => 2,
    < 840 => 3,
    _ => 4,
  };

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.maxWidth);
        final rowCount = (months.length / columns).ceil();
        final footer = this.footer;
        return ListView.separated(
          itemCount: rowCount + (footer == null ? 0 : 1),
          separatorBuilder: (context, _) => const SizedBox(height: _gap),
          itemBuilder: (context, row) => row < rowCount
              ? _MiniMonthRow(
                  months: months.skip(row * columns).take(columns).toList(),
                  columns: columns,
                  onMonthTap: onMonthTap,
                )
              : footer ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// One row of mini months, all as tall as the tallest, so a month with six
/// weeks or a title wrapped at large text does not leave a ragged row.
class _MiniMonthRow extends StatelessWidget {
  const new({
    required this.months,
    required this.columns,
    required this.onMonthTap,
  });

  final List<CalendarMonth> months;
  final int columns;
  final ValueChanged<HijriMonth> onMonthTap;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: CalendarYearView._gap,
        children: [
          for (var column = 0; column < columns; column++)
            Expanded(
              child: column < months.length
                  ? CalendarMiniMonth(
                      month: months[column],
                      onTap: () => onMonthTap(months[column].month),
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
