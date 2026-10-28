import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder_copy.dart';

/// Predictable notification text for tests.
class TestCopy implements ReminderCopy {
  const new();

  @override
  String title(FastingType type, {required int daysBefore}) =>
      '${type.name}-$daysBefore';

  @override
  String body(FastingType type) => 'body-${type.name}';
}
