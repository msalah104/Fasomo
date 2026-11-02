import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:fasomo/core/widget/home_widget_contract.dart';
import 'package:fasomo/core/widget/home_widget_gateway.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

/// The only file that imports `home_widget`, used as a data bridge only: the
/// widgets themselves are native (an `AppWidgetProvider` on Android, a
/// WidgetKit extension on iOS).
class HomeWidgetPluginGateway implements HomeWidgetGateway {
  /// The App Group the iOS app and its widget extension share. Must match
  /// both `.entitlements` files and `FasomoWidgetContract.swift`.
  static const appGroupId = 'group.app.fasomo.fasomo';

  /// The Android `AppWidgetProvider`'s class name.
  static const androidProvider =
      'app.fasomo.fasomo.widget.FasomoWidgetProvider';

  /// The iOS widget's `kind`.
  static const iOSKind = 'FasomoWidget';

  /// Points the plugin at the shared App Group (a no-op on Android). Before
  /// the first [publish].
  Future<void> initialize() async {
    await _guard('setAppGroupId', () => HomeWidget.setAppGroupId(appGroupId));
  }

  @override
  Future<Result<void, HomeWidgetFailure>> publish(
    HomeWidgetSnapshot snapshot,
  ) async {
    final steps = <String, Future<Object?> Function()>{
      'save': () => HomeWidget.saveWidgetData<String>(
        HomeWidgetContract.storageKey,
        HomeWidgetContract.encode(snapshot),
      ),
      'update': () => HomeWidget.updateWidget(
        qualifiedAndroidName: androidProvider,
        iOSName: iOSKind,
      ),
      // Android only; iOS builds its timeline from the stored entries.
      'schedule': () => HomeWidget.scheduleWidgetUpdates(
        HomeWidgetContract.refreshTimes(snapshot),
        qualifiedAndroidName: androidProvider,
      ),
    };
    for (final MapEntry(key: operation, value: step) in steps.entries) {
      final result = await _guard(operation, step);
      if (result is Err) return result;
    }
    return const Ok(null);
  }

  @override
  Stream<void> get opened => HomeWidget.widgetClicked
      .map<void>((_) {})
      .handleError(
        (Object error, StackTrace stackTrace) =>
            AppLog.error('homeWidget.opened', error, stackTrace),
        test: (error) => error is PlatformException,
      );

  Future<Result<void, HomeWidgetFailure>> _guard(
    String operation,
    Future<Object?> Function() call,
  ) async {
    try {
      await call();
      return const Ok(null);
    } on PlatformException catch (e, st) {
      AppLog.error('homeWidget.$operation', e, st);
      return Err(HomeWidgetPlatformFailed(operation));
    } on MissingPluginException catch (e, st) {
      AppLog.error('homeWidget.$operation', e, st);
      return Err(HomeWidgetPlatformFailed(operation));
    }
  }
}
