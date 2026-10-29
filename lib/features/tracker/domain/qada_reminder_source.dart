import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/reminder_occurrence.dart';
import 'package:fasomo/core/notifications/reminder_source.dart';
import 'package:fasomo/features/tracker/domain/qada_reminder_planner.dart';
import 'package:fasomo/features/tracker/domain/repositories/fast_log_repository.dart';
import 'package:fasomo/features/tracker/domain/repositories/qada_reminder_repository.dart';

/// The make-up (Qada) reminders, planned from the settings and the current
/// balance in the fasting log.
class QadaReminderSource implements ReminderSource {
  const new({
    required this.settings,
    required this.fastLog,
    required this.planner,
  });

  final QadaReminderRepository settings;
  final FastLogRepository fastLog;
  final QadaReminderPlanner planner;

  @override
  Result<List<ReminderOccurrence>, Failure> occurrences({
    required DateTime today,
    required int horizonDays,
  }) => switch ((settings.getSettings(), fastLog.getSummary())) {
    (Ok(value: final settings), Ok(value: final summary)) => Ok(
      planner.plan(
        settings: settings,
        remaining: summary.qada.remaining,
        fastedDays: summary.fastedDays,
        today: today,
        horizonDays: horizonDays,
      ),
    ),
    (Err(:final failure), _) || (_, Err(:final failure)) => Err(failure),
  };
}
