/// The light of the sky, from the sun's altitude.
enum DayPhase {
  /// Sun below −18°: full dark.
  night,

  /// −18° to −12°: the first light of Fajr, the last of Isha.
  astronomicalTwilight,

  /// −12° to −6°.
  nauticalTwilight,

  /// −6° to sunrise or after sunset.
  civilTwilight,

  /// From the horizon to 6°: low, warm sun.
  goldenHour,

  /// Sun above 6°.
  day;

  /// The phase for a sun at [altitudeDegrees] (geometric, centre).
  static DayPhase fromSunAltitude(double altitudeDegrees) {
    if (altitudeDegrees < -18) return night;
    if (altitudeDegrees < -12) return astronomicalTwilight;
    if (altitudeDegrees < -6) return nauticalTwilight;
    if (altitudeDegrees < -0.833) return civilTwilight;
    if (altitudeDegrees < 6) return goldenHour;
    return day;
  }

  /// Whether the sun is up, its upper limb above the horizon.
  bool get isSunUp => this == goldenHour || this == day;

  /// Whether it is dawn or dusk rather than full night or full day.
  bool get isTwilight =>
      this == astronomicalTwilight ||
      this == nauticalTwilight ||
      this == civilTwilight;
}
