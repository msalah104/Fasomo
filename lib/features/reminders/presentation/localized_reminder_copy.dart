import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/utils/app_localizations.dart';
import 'package:fasomo/features/reminders/domain/entities/reminder_copy.dart';

/// [ReminderCopy] for one language. Equal per language, so re-sending it on
/// every rebuild does not trigger a resync.
class LocalizedReminderCopy extends Equatable implements ReminderCopy {
  const new(this._localization);

  final AppLocalizations _localization;

  @override
  String title(FastingType type, {required int daysBefore}) =>
      _localization.reminderTitle(
        _localization.fastingTypeTitle(type),
        daysBefore: daysBefore,
      );

  @override
  String body(FastingType type) => _localization.fastingTypeDescription(type);

  @override
  List<Object> get props => [_localization.locale];
}
