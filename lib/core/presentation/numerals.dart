import 'package:intl/intl.dart';

/// Pins one numbering system for the whole app: Western digits (0–9) in
/// every language.
///
/// Hijri day numbers, counts and percentages are plain Western digits, while
/// `intl` would draw Arabic dates and times in Arabic-Indic digits (٠–٩).
/// Mixing both on one screen reads as a bug, so dates follow the rest. Call
/// once at startup, before the first frame.
void pinWesternDigits() {
  DateFormat.useNativeDigitsByDefaultFor('ar', false);
}
