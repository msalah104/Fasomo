/// Kinds of fasting day the app tracks, in display-priority order: when a day
/// has several types, the first one listed here is its primary type.
enum FastingType {
  ramadan(isObligatory: true),
  arafah,
  ashura,
  tasua,
  shawwal,
  whiteDays,
  mondayThursday;

  new({this.isObligatory = false});

  /// Whether fasting is obligatory (Ramadan) rather than recommended.
  final bool isObligatory;
}
