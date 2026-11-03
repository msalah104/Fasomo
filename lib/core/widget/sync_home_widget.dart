import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/core/widget/home_widget_copy.dart';
import 'package:fasomo/core/widget/home_widget_gateway.dart';
import 'package:fasomo/core/widget/home_widget_snapshot_builder.dart';

/// Recomputes the home-screen widget's snapshot for today and publishes it.
///
/// Run it on every app start and resume, when the language changes and when
/// the Hijri adjustment moves the dates.
class SyncHomeWidget
    implements
        UseCase<Future<Result<void, HomeWidgetFailure>>, HomeWidgetCopy> {
  const new({
    required this.calendar,
    required this.gateway,
    required this.clock,
  });

  final FastingCalendar calendar;
  final HomeWidgetGateway gateway;
  final Clock clock;

  @override
  Future<Result<void, HomeWidgetFailure>> call(HomeWidgetCopy copy) =>
      gateway.publish(
        HomeWidgetSnapshotBuilder(
          calendar,
        ).build(today: clock.now(), copy: copy),
      );
}
