import 'dart:async';

import 'package:clock/clock.dart';

/// Emits once at the start of every wall-clock minute, so a clock-driven
/// view (the sky) can refresh without a widget-level timer.
abstract interface class MinuteTicker {
  Stream<void> get ticks;
}

/// [MinuteTicker] on real timers: the first tick waits for the next minute
/// boundary, then one per minute.
class PeriodicMinuteTicker implements MinuteTicker {
  const new([this._clock]);

  /// The time source; the zone's `clock` when null, so tests can fix it with
  /// `withClock`.
  final Clock? _clock;

  @override
  Stream<void> get ticks {
    late StreamController<void> controller;
    Timer? timer;
    controller = StreamController<void>(
      onListen: () {
        final now = (_clock ?? clock).now();
        final untilNextMinute = Duration(
          seconds: 60 - now.second,
          milliseconds: -now.millisecond,
        );
        timer = Timer(untilNextMinute, () {
          controller.add(null);
          timer = Timer.periodic(
            const Duration(minutes: 1),
            (_) => controller.add(null),
          );
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }
}
