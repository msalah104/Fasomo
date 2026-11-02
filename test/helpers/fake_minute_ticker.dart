import 'dart:async';

import 'package:fasomo/core/time/minute_ticker.dart';

/// A [MinuteTicker] the test ticks by hand; it counts live listeners.
class FakeMinuteTicker implements MinuteTicker {
  final _controller = StreamController<void>.broadcast();

  int get listeners => _listeners;
  int _listeners = 0;

  void tick() => _controller.add(null);

  Future<void> dispose() => _controller.close();

  @override
  Stream<void> ticks() {
    late StreamController<void> own;
    StreamSubscription<void>? source;
    own = StreamController<void>(
      onListen: () {
        _listeners++;
        source = _controller.stream.listen(own.add);
      },
      onCancel: () async {
        _listeners--;
        await source?.cancel();
        await own.close();
      },
    );
    return own.stream;
  }
}
