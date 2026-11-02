import 'dart:async';

import 'package:clock/clock.dart';

/// A tick at the start of every minute, for screens that show the time of
/// day. Ticks stop when the subscription is paused or cancelled.
abstract interface class MinuteTicker {
  /// A new stream of ticks, one as each minute begins.
  Stream<void> ticks();
}

/// [MinuteTicker] on timers, aligned to the minute by [clock].
final class PeriodicMinuteTicker implements MinuteTicker {
  const new(this.clock);

  final Clock clock;

  @override
  Stream<void> ticks() {
    Timer? timer;
    late final StreamController<void> controller;

    void scheduleNext() {
      final now = clock.now();
      final nextMinute = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute + 1,
      );
      timer = Timer(nextMinute.difference(now), () {
        controller.add(null);
        scheduleNext();
      });
    }

    void stop() => timer?.cancel();

    controller = StreamController<void>(
      onListen: scheduleNext,
      onPause: stop,
      onResume: scheduleNext,
      onCancel: () {
        stop();
        return controller.close();
      },
    );
    return controller.stream;
  }
}
