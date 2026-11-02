/// How many days the app's Hijri dates are moved from the Umm al-Qura table,
/// for places that start months by local moon sighting.
///
/// A positive offset moves every Hijri date forward: with [plusOne], the day
/// the table calls 9 Ramadan shows as 10 Ramadan, so each month starts one
/// day earlier. A negative offset does the opposite.
enum HijriOffset {
  minusTwo(-2),
  minusOne(-1),
  none(0),
  plusOne(1),
  plusTwo(2);

  new(this.days);

  /// Days added to the Hijri date, −2..2.
  final int days;

  /// The offset of [days], or `null` outside −2..2.
  static HijriOffset? fromDays(int days) {
    for (final offset in values) {
      if (offset.days == days) return offset;
    }
    return null;
  }
}

/// Where the Hijri converter reads the current [HijriOffset] from.
///
/// Read on every conversion, so a change applies to the next conversion
/// without rebuilding the converter; callers reload their data to see it.
abstract interface class HijriOffsetSource {
  HijriOffset get hijriOffset;
}

/// A [HijriOffsetSource] that never changes, for tests and previews.
final class FixedHijriOffset implements HijriOffsetSource {
  const new(this.hijriOffset);

  @override
  final HijriOffset hijriOffset;
}
