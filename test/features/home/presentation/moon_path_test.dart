import 'package:fasomo/features/home/presentation/widgets/moon_path.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const r = 10.0;

  test('a full moon fills the disc', () {
    final bounds = moonLitPath(
      radius: r,
      fraction: 1,
      litOnRight: true,
    ).getBounds();
    expect(bounds.left, closeTo(-r, 0.01));
    expect(bounds.right, closeTo(r, 0.01));
  });

  test('a waxing crescent is a sliver on the right', () {
    final bounds = moonLitPath(
      radius: r,
      fraction: 0.2,
      litOnRight: true,
    ).getBounds();
    expect(bounds.right, closeTo(r, 0.01));
    // The terminator bulges to x = r·|2f − 1| = 6.
    expect(bounds.left, greaterThan(-0.01));
  });

  test('a waning gibbous is lit on the left, past the centre line', () {
    final bounds = moonLitPath(
      radius: r,
      fraction: 0.8,
      litOnRight: false,
    ).getBounds();
    expect(bounds.left, closeTo(-r, 0.01));
    expect(bounds.right, closeTo(6, 0.05));
  });
}
