import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/presentation/prayer_text.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';

/// Localized Ramadan text. Values become strings only here.
extension RamadanText on AppLocalizations {
  /// "Iftar in 2 h 15 min" or "Suhoor ends in 45 min".
  String fastingMomentCountdown(FastingMoment moment) {
    final duration = shortDuration(moment.remaining);
    return switch (moment.kind) {
      FastingMomentKind.suhoorEnds => ramadanSuhoorEndsIn(duration),
      FastingMomentKind.iftar => ramadanIftarIn(duration),
    };
  }

  /// The same as [fastingMomentCountdown], in words for a screen reader.
  String fastingMomentCountdownSpoken(FastingMoment moment) {
    final (hours, minutes) = _hoursAndMinutes(moment.remaining);
    final duration = durationSpoken(hours, minutes);
    return switch (moment.kind) {
      FastingMomentKind.suhoorEnds => ramadanSuhoorEndsIn(duration),
      FastingMomentKind.iftar => ramadanIftarIn(duration),
    };
  }

  /// "2 h 05 min" or "45 min", rounded up to the minute so it never says
  /// 0 before the moment.
  String shortDuration(Duration duration) {
    final (hours, minutes) = _hoursAndMinutes(duration);
    return hours == 0
        ? durationMinutes(minutes)
        : durationHoursMinutes(hours, minutes.toString().padLeft(2, '0'));
  }

  /// "Cairo · Egyptian General Authority of Survey", or a note that the
  /// times are for the stand-in location.
  String ramadanTimesSource(GeoPoint location, CalculationMethod method) {
    final place = location.city?.nameFor(localeName) ?? locationMyLocation;
    return location.isApproximate
        ? ramadanTimesApproximate(place)
        : ramadanTimesFor(place, calculationMethodName(method));
  }

  static (int, int) _hoursAndMinutes(Duration duration) {
    final totalMinutes = (duration.inSeconds + 59) ~/ 60;
    return (totalMinutes ~/ 60, totalMinutes % 60);
  }
}
