import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/notification_copy.dart';

/// Predictable notification text for tests.
class TestCopy implements NotificationCopy {
  const new();

  @override
  String fastingTitle(FastingType type, {required int daysBefore}) =>
      '${type.name}-$daysBefore';

  @override
  String fastingBody(FastingType type) => 'body-${type.name}';

  @override
  String qadaTitle({required int daysBefore}) => 'qada-$daysBefore';

  @override
  String qadaBody(int remaining) => 'owe-$remaining';

  @override
  String mergedTitle(FastingType type, {required int daysBefore}) =>
      '${type.name}+qada-$daysBefore';

  @override
  String mergedBody(FastingType type, int remaining) =>
      'both-${type.name}-owe-$remaining';

  @override
  String ramadanCountdownTitle(int daysUntilRamadan) =>
      'ramadan-in-$daysUntilRamadan';

  @override
  String ramadanCountdownBody(int daysUntilRamadan, int remaining) =>
      'countdown-$daysUntilRamadan-owe-$remaining';
}
