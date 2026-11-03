// Tests the adapter itself, so this is the one test that sees the plugin's
// method channel.
import 'dart:convert';

import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/services/home_widget/home_widget_plugin_gateway.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('home_widget');
  late List<MethodCall> calls;
  String? failingMethod;

  final snapshot = HomeWidgetSnapshot(
    generatedFor: DateTime(2026, 11, 2),
    isRightToLeft: false,
    staleText: 'Open Fasomo to update',
    days: [
      HomeWidgetDay(
        date: DateTime(2026, 11, 2),
        hijriText: '21 Jumada al-Awwal 1448 AH',
        gregorianText: 'Monday, November 2',
        nextFastText: 'Today: Monday & Thursday',
        isFastingDay: true,
      ),
    ],
  );

  setUp(() {
    calls = [];
    failingMethod = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == failingMethod) {
            throw PlatformException(code: '-3', message: 'no provider');
          }
          return true;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  test('initialize points the plugin at the shared App Group', () async {
    await HomeWidgetPluginGateway().initialize();

    expect(calls.single.method, 'setAppGroupId');
    expect(calls.single.arguments, {'groupId': 'group.app.fasomo.fasomo'});
  });

  test('publish saves the snapshot, redraws the widget and schedules the '
      'midnight refreshes', () async {
    final result = await HomeWidgetPluginGateway().publish(snapshot);

    expect(result, isA<Ok<void, HomeWidgetFailure>>());
    expect(calls.map((call) => call.method), [
      'saveWidgetData',
      'updateWidget',
      'scheduleWidgetUpdates',
    ]);

    final save = calls[0].arguments as Map<Object?, Object?>;
    expect(save['id'], 'fasomo_widget_snapshot');
    final json = jsonDecode(save['data']! as String) as Map<String, Object?>;
    expect(json['v'], 1);
    expect(json['days'], contains('2026-11-02'));

    final update = calls[1].arguments as Map<Object?, Object?>;
    expect(
      update['qualifiedAndroidName'],
      'app.fasomo.fasomo.widget.FasomoWidgetProvider',
    );
    expect(update['ios'], 'FasomoWidget');

    final schedule = calls[2].arguments as Map<Object?, Object?>;
    expect(schedule['updateTimes'], [
      DateTime(2026, 11, 3).millisecondsSinceEpoch,
    ]);
    expect(
      schedule['qualifiedAndroidName'],
      'app.fasomo.fasomo.widget.FasomoWidgetProvider',
    );
  });

  test(
    'a platform error becomes a typed failure and stops the publish',
    () async {
      failingMethod = 'updateWidget';

      final result = await HomeWidgetPluginGateway().publish(snapshot);

      expect(
        result,
        isA<Err<void, HomeWidgetFailure>>().having(
          (err) => err.failure,
          'failure',
          isA<HomeWidgetPlatformFailed>().having(
            (failure) => failure.operation,
            'operation',
            'update',
          ),
        ),
      );
      expect(calls.map((call) => call.method), [
        'saveWidgetData',
        'updateWidget',
      ]);
    },
  );

  test('a missing plugin becomes a typed failure', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);

    final result = await HomeWidgetPluginGateway().publish(snapshot);

    expect(result, isA<Err<void, HomeWidgetFailure>>());
  });
}
