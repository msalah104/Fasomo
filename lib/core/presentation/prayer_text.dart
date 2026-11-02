import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Localized prayer-time text. Values become strings only here.
extension PrayerText on AppLocalizations {
  String prayerName(Prayer prayer) => switch (prayer) {
    Prayer.fajr => prayerFajr,
    Prayer.sunrise => prayerSunrise,
    Prayer.dhuhr => prayerDhuhr,
    Prayer.asr => prayerAsr,
    Prayer.maghrib => prayerMaghrib,
    Prayer.isha => prayerIsha,
  };

  String calculationMethodName(CalculationMethod method) => switch (method) {
    CalculationMethod.ummAlQura => prayerMethodUmmAlQura,
    CalculationMethod.egyptian => prayerMethodEgyptian,
    CalculationMethod.muslimWorldLeague => prayerMethodMuslimWorldLeague,
    CalculationMethod.isna => prayerMethodIsna,
    CalculationMethod.karachi => prayerMethodKarachi,
    CalculationMethod.dubai => prayerMethodDubai,
    CalculationMethod.kuwait => prayerMethodKuwait,
    CalculationMethod.qatar => prayerMethodQatar,
    CalculationMethod.singapore => prayerMethodSingapore,
    CalculationMethod.turkey => prayerMethodTurkey,
    CalculationMethod.tehran => prayerMethodTehran,
  };

  String asrMethodName(AsrMethod method) => switch (method) {
    AsrMethod.standard => asrMethodStandard,
    AsrMethod.hanafi => asrMethodHanafi,
  };

  String highLatitudeRuleName(HighLatitudeRule rule) => switch (rule) {
    HighLatitudeRule.middleOfTheNight => highLatitudeMiddle,
    HighLatitudeRule.seventhOfTheNight => highLatitudeSeventh,
    HighLatitudeRule.twilightAngle => highLatitudeAngle,
  };

  /// A prayer time in the device's time zone and clock format, e.g. "5:31
  /// AM" or "05:31"; "—" when the time does not exist that day.
  String prayerTime(DateTime? time, {required bool use24HourClock}) {
    if (time == null) return '—';
    final format = use24HourClock
        ? DateFormat.Hm(localeName)
        : DateFormat.jm(localeName);
    return format.format(time.toLocal());
  }

  /// "+3 min", "-2 min" (with a real minus sign) or "0 min", the number
  /// kept left to right in Arabic.
  String adjustmentMinutes(int minutes) {
    final signed = switch (minutes) {
      > 0 => '+$minutes',
      < 0 => '\u2212${-minutes}',
      _ => '0',
    };
    // Isolated so the sign stays in front of the digits in right-to-left
    // text.
    return prayerAdjustmentMinutes('\u2066$signed\u2069');
  }

  /// "Fajr -2 min · Maghrib +3 min", or "No adjustments".
  String adjustmentsSummary(PrayerAdjustments adjustments) {
    final items = [
      for (final prayer in Prayer.values)
        if (adjustments[prayer] != 0)
          prayerAdjustmentItem(
            prayerName(prayer),
            adjustmentMinutes(adjustments[prayer]),
          ),
    ];
    return items.isEmpty ? prayerAdjustmentsNone : items.join(' · ');
  }
}
