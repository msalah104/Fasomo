import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/notification_copy.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';

/// [NotificationCopy] for one language. Equal per language, so re-sending it
/// on every rebuild does not trigger a resync.
class LocalizedNotificationCopy extends Equatable implements NotificationCopy {
  const new(this._localization);

  final AppLocalizations _localization;

  @override
  String fastingTitle(FastingType type, {required int daysBefore}) =>
      _localization.reminderTitle(
        daysBefore,
        _localization.fastingTypeTitle(type),
      );

  @override
  String fastingBody(FastingType type) =>
      _localization.fastingTypeDescription(type);

  @override
  String qadaTitle({required int daysBefore}) =>
      _localization.qadaReminderTitle(daysBefore);

  @override
  String qadaBody(int remaining) => _localization.qadaReminderBody(remaining);

  @override
  String mergedTitle(FastingType type, {required int daysBefore}) =>
      _localization.mergedReminderTitle(
        daysBefore,
        _localization.fastingTypeTitle(type),
      );

  @override
  String mergedBody(FastingType type, int remaining) => _localization
      .mergedReminderBody(_localization.fastingTypeTitle(type), remaining);

  @override
  String ramadanCountdownTitle(int daysUntilRamadan) =>
      _localization.ramadanCountdownTitle(daysUntilRamadan);

  @override
  String ramadanCountdownBody(int daysUntilRamadan, int remaining) =>
      _localization.ramadanCountdownBody(remaining);

  @override
  List<Object> get props => [_localization.localeName];
}
