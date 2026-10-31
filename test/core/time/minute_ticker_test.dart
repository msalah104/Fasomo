import 'dart:async';

import 'package:clock/clock.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets runs timers on fake time, advanced by tester.pump.
  testWidgets('ticks on the next minute boundary, then every minute', (
    tester,
  ) async {
    var ticks = 0;
    final subscription = withClock(
      Clock.fixed(DateTime(2026, 10, 31, 9, 15, 40)),
      () => const PeriodicMinuteTicker().ticks.listen((_) => ticks++),
    );

    await tester.pump(const Duration(seconds: 19));
    expect(ticks, 0);
    await tester.pump(const Duration(seconds: 1));
    expect(ticks, 1);
    await tester.pump(const Duration(minutes: 2));
    expect(ticks, 3);

    // Not awaited: in a widget test the cancel future only completes on a
    // later pump.
    unawaited(subscription.cancel());
    await tester.pump(const Duration(minutes: 5));
    expect(ticks, 3);
  });
}
