import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/presentation/date_formatter.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/core/widget/home_widget_copy.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// [HomeWidgetCopy] for one language. Equal per language, so re-sending it
/// on every rebuild does not republish the widget.
class LocalizedHomeWidgetCopy extends Equatable implements HomeWidgetCopy {
  const new(this._localization);

  final AppLocalizations _localization;

  @override
  bool get isRightToLeft => Bidi.isRtlLanguage(_localization.localeName);

  @override
  String hijriDate(HijriDate date) => _localization.formatHijri(date);

  @override
  String gregorianDate(DateTime date) =>
      DateFormat.MMMMEEEEd(_localization.localeName).format(date);

  @override
  String nextFast(FastingType type, {required int daysUntil}) => _localization
      .homeWidgetNextFast(daysUntil, _localization.fastingTypeTitle(type));

  @override
  String get noUpcomingFast => _localization.noUpcomingFasting;

  @override
  String get openAppToUpdate => _localization.homeWidgetOpenApp;

  @override
  List<Object> get props => [_localization.localeName];
}
