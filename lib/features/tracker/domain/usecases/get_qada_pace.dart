import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/tracker/domain/entities/fast_log_summary.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_pace.dart';
import 'package:fasomo/features/tracker/domain/qada_pace_planner.dart';

/// The suggested make-up pace for a summary's balance as of today, or
/// `null` when nothing is owed. Derived on every read, never stored.
class GetQadaPace implements UseCase<QadaPace?, FastLogSummary> {
  const new({required this.planner, required this.clock});

  final QadaPacePlanner planner;
  final Clock clock;

  @override
  QadaPace? call(FastLogSummary summary) => planner.plan(
    remaining: summary.qada.remaining,
    fastedDays: summary.fastedDays,
    today: CalendarDays.dateOnly(clock.now()),
  );
}
