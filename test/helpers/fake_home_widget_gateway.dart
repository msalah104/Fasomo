import 'dart:async';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/widget/home_widget_gateway.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';

/// Records every published snapshot; [openedController] simulates widget taps.
class FakeHomeWidgetGateway implements HomeWidgetGateway {
  final List<HomeWidgetSnapshot> published = [];

  /// When set, every publish fails with this failure.
  HomeWidgetFailure? failure;

  final StreamController<void> openedController =
      StreamController<void>.broadcast();

  @override
  Future<Result<void, HomeWidgetFailure>> publish(
    HomeWidgetSnapshot snapshot,
  ) async {
    final failure = this.failure;
    if (failure != null) return Err(failure);
    published.add(snapshot);
    return const Ok(null);
  }

  @override
  Stream<void> get opened => openedController.stream;

  Future<void> dispose() => openedController.close();
}
