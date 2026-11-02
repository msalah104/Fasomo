import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_grid.dart';
import 'package:flutter/material.dart';

/// A [HijriMonth] as a page of an endless month pager, and back.
extension HijriMonthPageIndex on HijriMonth {
  int get pageIndex => year * 12 + month - 1;

  static HijriMonth fromPageIndex(int index) =>
      HijriMonth(index ~/ 12, index % 12 + 1);
}

/// The month grid, swiped sideways to change month.
///
/// The pager follows reading direction: the next month lies at the end side,
/// so in Arabic it slides in from the left. The shown month is owned by the
/// bloc; a swipe reports the new month through [onMonthChanged], and a month
/// changed elsewhere (arrows, Today, a refused swipe) turns the pager to it.
/// Under reduced motion the grid does not slide: a fling changes the month
/// in place.
class CalendarMonthPager extends StatefulWidget {
  const new({
    required this.month,
    required this.days,
    required this.previousDays,
    required this.nextDays,
    required this.onMonthChanged,
    required this.onDayTap,
    this.dayBadgeBuilder,
    this.showGregorianDays = false,
    super.key,
  });

  final HijriMonth month;
  final List<CalendarDay> days;

  /// The days either side of [month]; empty when unavailable.
  final List<CalendarDay> previousDays;
  final List<CalendarDay> nextDays;
  final ValueChanged<HijriMonth> onMonthChanged;
  final ValueChanged<CalendarDay> onDayTap;
  final Widget? Function(CalendarDay day)? dayBadgeBuilder;
  final bool showGregorianDays;

  @override
  State<CalendarMonthPager> createState() => _CalendarMonthPagerState();
}

class _CalendarMonthPagerState extends State<CalendarMonthPager> {
  static const Duration _pageTurn = Duration(milliseconds: 300);

  /// Slower flings are taken as a scroll of the grid, not a month change.
  static const double _minFlingVelocity = 300;

  late final PageController _controller = PageController(
    initialPage: widget.month.pageIndex,
  );

  @override
  void didUpdateWidget(CalendarMonthPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    // After layout, so the controller reads the settled page.
    WidgetsBinding.instance.addPostFrameCallback((_) => _turnToMonth());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _turnToMonth() {
    if (!mounted || !_controller.hasClients) return;
    final target = widget.month.pageIndex;
    final page = _controller.page?.round();
    if (page == null || page == target) return;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion || (page - target).abs() > 1) {
      _controller.jumpToPage(target);
    } else {
      // Fire and forget is safe: a newer turn or a drag simply interrupts it.
      _controller.animateToPage(
        target,
        duration: _pageTurn,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int index) {
    final month = HijriMonthPageIndex.fromPageIndex(index);
    // A turn started by the bloc lands on its own month: nothing to report.
    if (month != widget.month) widget.onMonthChanged(month);
  }

  /// Reduced motion: a fling towards the start edge brings in the month that
  /// lies at the end side, which is the next one.
  void _onFling(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _minFlingVelocity) return;
    final towardsStart = Directionality.of(context) == TextDirection.ltr
        ? velocity < 0
        : velocity > 0;
    widget.onMonthChanged(
      towardsStart ? widget.month.next : widget.month.previous,
    );
  }

  List<CalendarDay> _daysFor(HijriMonth month) => switch (month) {
    _ when month == widget.month => widget.days,
    _ when month == widget.month.previous => widget.previousDays,
    _ when month == widget.month.next => widget.nextDays,
    _ => const [],
  };

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pager = PageView.builder(
      controller: _controller,
      physics: reduceMotion ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) {
        final days = _daysFor(HijriMonthPageIndex.fromPageIndex(index));
        if (days.isEmpty) return const SizedBox.shrink();
        return CalendarGrid(
          days: days,
          showGregorianDays: widget.showGregorianDays,
          dayBadgeBuilder: widget.dayBadgeBuilder,
          onDayTap: widget.onDayTap,
        );
      },
    );
    // Always wrapped, so toggling reduced motion keeps the pager's position.
    return GestureDetector(
      onHorizontalDragEnd: reduceMotion ? _onFling : null,
      child: pager,
    );
  }
}
