import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/widget/home_widget_copy.dart';
import 'package:fasomo/core/widget/sync_home_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_home_widget_gateway.dart';

class _TestCopy implements HomeWidgetCopy {
  const new();

  @override
  bool get isRightToLeft => false;

  @override
  String hijriDate(HijriDate date) => '$date';

  @override
  String gregorianDate(DateTime date) => '$date';

  @override
  String nextFast(FastingType type, {required int daysUntil}) =>
      '${type.name}+$daysUntil';

  @override
  String get noUpcomingFast => 'none';

  @override
  String get openAppToUpdate => 'stale';
}

void main() {
  late FakeHomeWidgetGateway gateway;
  late SyncHomeWidget sync;

  setUp(() {
    gateway = FakeHomeWidgetGateway();
    sync = SyncHomeWidget(
      calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
      gateway: gateway,
      clock: Clock.fixed(DateTime(2026, 11, 20, 23, 50)),
    );
  });

  tearDown(() => gateway.dispose());

  test('publishes the snapshot for the clock day', () async {
    final result = await sync(const _TestCopy());

    expect(result, isA<Ok<void, HomeWidgetFailure>>());
    final snapshot = gateway.published.single;
    expect(snapshot.generatedFor, DateTime(2026, 11, 20));
    expect(snapshot.days, hasLength(7));
    expect(snapshot.days.first.nextFastText, 'whiteDays+3');
  });

  test('returns the gateway failure', () async {
    gateway.failure = const HomeWidgetPlatformFailed('save');

    final result = await sync(const _TestCopy());

    expect(
      result,
      isA<Err<void, HomeWidgetFailure>>().having(
        (err) => err.failure,
        'failure',
        isA<HomeWidgetPlatformFailed>(),
      ),
    );
  });
}
