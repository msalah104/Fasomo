import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/notifications/notification_copy.dart';
import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/presentation/qada_pace_text.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

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
  String qadaPace(QadaPaceRate pace) => _localization.qadaPaceSentence(pace);

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
  String suhoorTitle(int minutesBeforeFajr) =>
      _localization.suhoorNotificationTitle(minutesBeforeFajr);

  @override
  String suhoorBody(DateTime fajr) =>
      _localization.suhoorNotificationBody(_time(fajr));

  @override
  String iftarTitle(int minutesBeforeMaghrib) =>
      _localization.iftarNotificationTitle(minutesBeforeMaghrib);

  @override
  String iftarBody(DateTime maghrib) =>
      _localization.iftarNotificationBody(_time(maghrib));

  /// The locale's usual clock format: there is no device setting to read
  /// here, outside a widget.
  String _time(DateTime time) =>
      DateFormat.jm(_localization.localeName).format(time.toLocal());

  @override
  List<Object> get props => [_localization.localeName];
}
