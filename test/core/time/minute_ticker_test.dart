import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ticks as each minute begins, aligned to the clock', () {
    fakeAsync((async) {
      // Start 20 seconds into a minute.
      async.elapse(const Duration(seconds: 20));
      final ticker = PeriodicMinuteTicker(async.getClock(DateTime(2026)));
      var ticks = 0;
      final subscription = ticker.ticks().listen((_) => ticks++);

      async.elapse(const Duration(seconds: 39));
      expect(ticks, 0);
      async.elapse(const Duration(seconds: 1));
      expect(ticks, 1);
      async.elapse(const Duration(minutes: 3));
      expect(ticks, 4);

      unawaited(subscription.cancel());
      async.elapse(const Duration(minutes: 5));
      expect(ticks, 4);
      expect(async.pendingTimers, isEmpty);
    });
  });

  test('pausing stops the ticks and resuming realigns them', () {
    fakeAsync((async) {
      final ticker = PeriodicMinuteTicker(async.getClock(DateTime(2026)));
      var ticks = 0;
      final subscription = ticker.ticks().listen((_) => ticks++)..pause();

      async.elapse(const Duration(minutes: 3, seconds: 30));
      expect(ticks, 0);
      expect(async.pendingTimers, isEmpty);

      subscription.resume();
      async.elapse(const Duration(seconds: 30));
      expect(ticks, 1);

      unawaited(subscription.cancel());
      async.flushMicrotasks();
    });
  });
}
