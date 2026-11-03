import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/app/home_widget_sync.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/widget/sync_home_widget.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_home_widget_gateway.dart';

class MockHijriAdjustmentBloc
    extends MockBloc<HijriAdjustmentEvent, HijriAdjustmentState>
    implements HijriAdjustmentBloc;

void main() {
  const initial = HijriAdjustmentState(
    offset: HijriOffset.none,
    today: HijriDate(1448, 6, 10),
  );

  late FakeHomeWidgetGateway gateway;
  late MockHijriAdjustmentBloc hijriBloc;
  late StreamController<HijriAdjustmentState> hijriStates;

  setUp(() {
    gateway = FakeHomeWidgetGateway();
    hijriBloc = MockHijriAdjustmentBloc();
    hijriStates = StreamController<HijriAdjustmentState>();
    whenListen(hijriBloc, hijriStates.stream, initialState: initial);
  });

  tearDown(() async {
    await hijriStates.close();
    await gateway.dispose();
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
  }) => tester.pumpWidget(
    BlocProvider<HijriAdjustmentBloc>.value(
      value: hijriBloc,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: HomeWidgetSync(
          sync: SyncHomeWidget(
            calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
            gateway: gateway,
            clock: Clock.fixed(DateTime(2026, 11, 20, 9)),
          ),
          child: const SizedBox(),
        ),
      ),
    ),
  );

  testWidgets('publishes once when the app starts', (tester) async {
    await pump(tester);
    await tester.pump();

    expect(gateway.published, hasLength(1));
    expect(
      gateway.published.single.days.first.nextFastText,
      'White Days in 3 days',
    );
  });

  testWidgets('republishes in the new language, and only then', (
    tester,
  ) async {
    await pump(tester);
    await pump(tester);
    expect(gateway.published, hasLength(1));

    await pump(tester, locale: const Locale('ar'));
    await tester.pump();

    expect(gateway.published, hasLength(2));
    expect(gateway.published.last.isRightToLeft, isTrue);
    expect(
      gateway.published.last.days.first.nextFastText,
      'الأيام البيض بعد 3 أيام',
    );
  });

  testWidgets('republishes when the Hijri adjustment changes', (
    tester,
  ) async {
    await pump(tester);

    hijriStates.add(initial);
    await tester.pump();
    expect(gateway.published, hasLength(1));

    hijriStates.add(
      const HijriAdjustmentState(
        offset: HijriOffset.plusOne,
        today: HijriDate(1448, 6, 11),
      ),
    );
    await tester.pump();

    expect(gateway.published, hasLength(2));
  });

  testWidgets('republishes when the app resumes', (tester) async {
    await pump(tester);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(gateway.published, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(gateway.published, hasLength(2));
  });

  testWidgets('a failed publish is retried by the next trigger', (
    tester,
  ) async {
    gateway.failure = const HomeWidgetPlatformFailed('save');
    await pump(tester);
    expect(gateway.published, isEmpty);

    gateway.failure = null;
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(gateway.published, hasLength(1));
  });
}
