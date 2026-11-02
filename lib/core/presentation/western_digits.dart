import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Makes every [DateFormat] write Western digits (0-9), as the rest of the
/// app does in Arabic too (the Hijri dates, counts and gen-l10n's numbers).
///
/// intl defaults to Arabic-Indic digits for `ar`, so without this a time
/// such as "5:16" would read "٥:١٦" next to "Day 12 of 29". Call it once
/// at startup, before the first frame; it only sets a default for new
/// formats.
void useWesternDigitsInDates() {
  for (final locale in AppLocalizations.supportedLocales) {
    DateFormat.useNativeDigitsByDefaultFor(locale.toLanguageTag(), false);
  }
}
