import 'package:fasomo/core/theme/sky_art.dart';
import 'package:fasomo/features/home/presentation/sky_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('day runs from 06:00 to 17:59', () {
    expect(skyArtAt(DateTime(2026, 10, 28, 6)), SkyArt.day);
    expect(skyArtAt(DateTime(2026, 10, 28, 12, 30)), SkyArt.day);
    expect(skyArtAt(DateTime(2026, 10, 28, 17, 59)), SkyArt.day);
  });

  test('night covers the evening and early morning', () {
    expect(skyArtAt(DateTime(2026, 10, 28, 18)), SkyArt.night);
    expect(skyArtAt(DateTime(2026, 10, 28, 23, 59)), SkyArt.night);
    expect(skyArtAt(DateTime(2026, 10, 28, 5, 59)), SkyArt.night);
  });
}
