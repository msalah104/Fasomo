import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';

/// The port to the home-screen widget. The widget only ever shows the last
/// published [HomeWidgetSnapshot]; it computes nothing itself.
abstract interface class HomeWidgetGateway {
  /// Stores [snapshot] where the widget reads it, redraws the widget, and
  /// asks the OS to redraw it again at each upcoming midnight so it moves on
  /// to the next day's entry without the app.
  Future<Result<void, HomeWidgetFailure>> publish(HomeWidgetSnapshot snapshot);

  /// Fires each time the user taps the widget while the app is running.
  Stream<void> get opened;
}
