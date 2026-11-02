import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/onboarding/domain/entities/onboarding_outcome.dart';
import 'package:fasomo/features/onboarding/domain/entities/reminder_plan.dart';
import 'package:fasomo/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fasomo/features/onboarding/presentation/widgets/fasting_interests_step.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'onboarding_mocks.dart';

void main() {
  const phone = Size(390, 844);
  const welcomeTitle = 'Welcome to Fasomo';
  const fastsTitle = 'Which fasts interest you?';
  const timeTitle = 'When should we remind you?';
  const locationTitle = 'Where are you?';
  const notificationsTitle = 'Never miss a fast';

  late OnboardingFakes fakes;
  late List<OnboardingOutcome> outcomes;

  setUpAll(OnboardingFakes.registerFallbacks);

  setUp(() {
    fakes = OnboardingFakes();
    outcomes = [];
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool reduceMotion = false,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: BlocProvider(
          create: (_) => fakes.bloc(),
          child: OnboardingPage(
            languagePicker: const Text('language picker'),
            onDone: outcomes.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('Next and Back move between the steps', (tester) async {
    await pumpPage(tester);
    expect(find.text(welcomeTitle), findsOneWidget);
    expect(find.text('language picker'), findsOneWidget);
    expect(find.text('Back'), findsNothing);

    await tapAndSettle(tester, find.text('Next'));
    expect(find.text(fastsTitle), findsOneWidget);
    expect(find.text(welcomeTitle), findsNothing);

    await tapAndSettle(tester, find.text('Next'));
    expect(find.text(timeTitle), findsOneWidget);

    await tapAndSettle(tester, find.text('Back'));
    expect(find.text(fastsTitle), findsOneWidget);
  });

  testWidgets('system back goes to the previous step', (tester) async {
    await pumpPage(tester);
    await tapAndSettle(tester, find.text('Next'));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text(welcomeTitle), findsOneWidget);
  });

  testWidgets('shows "Step x of 5" and labels it for screen readers', (
    tester,
  ) async {
    await pumpPage(tester);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 1 of 5'), findsOneWidget);

    await tapAndSettle(tester, find.text('Next'));
    expect(find.bySemanticsLabel('Step 2 of 5'), findsOneWidget);
  });

  testWidgets('Skip ends the flow as skipped, keeping the defaults', (
    tester,
  ) async {
    await pumpPage(tester);
    await tapAndSettle(tester, find.text('Skip'));

    expect(outcomes, [OnboardingOutcome.skipped]);
    verify(() => fakes.complete(any())).called(1);
    verifyNever(() => fakes.handoff.applyReminderPlan(any()));
    verifyNever(() => fakes.handoff.requestNotificationPermission());
  });

  testWidgets('applies the chosen fasts and time, then asks permission', (
    tester,
  ) async {
    await pumpPage(tester);
    await tapAndSettle(tester, find.text('Next'));

    // Every type starts out chosen; leave out Ramadan and the special days.
    await tapAndSettle(tester, find.text('Ramadan'));
    await tapAndSettle(tester, find.text('Arafah, Ashura and Tasua'));
    await tapAndSettle(tester, find.text('Next'));

    await tapAndSettle(tester, find.text('Morning of the fast'));
    await tapAndSettle(tester, find.text('Next'));

    expect(find.text(locationTitle), findsOneWidget);
    await tapAndSettle(tester, find.text('Later'));

    expect(find.text(notificationsTitle), findsOneWidget);
    expect(find.text('Skip').hitTestable(), findsNothing);
    await tapAndSettle(tester, find.text('Allow notifications'));

    verifyInOrder([
      () => fakes.handoff.applyReminderPlan(
        const ReminderPlan(
          enabledTypes: {
            FastingType.mondayThursday,
            FastingType.whiteDays,
            FastingType.shawwal,
          },
          timing: ReminderTiming.morningOf,
        ),
      ),
      () => fakes.handoff.requestNotificationPermission(),
      () => fakes.complete(any()),
    ]);
    expect(outcomes, [OnboardingOutcome.completed]);
  });

  testWidgets('"Not now" finishes without asking for permission', (
    tester,
  ) async {
    await pumpPage(tester);
    for (var i = 0; i < 3; i++) {
      await tapAndSettle(tester, find.text('Next'));
    }
    await tapAndSettle(tester, find.text('Later'));
    await tapAndSettle(tester, find.text('Not now'));

    verify(
      () => fakes.handoff.applyReminderPlan(ReminderPlan.defaults),
    ).called(1);
    verifyNever(() => fakes.handoff.requestNotificationPermission());
    expect(outcomes, [OnboardingOutcome.completed]);
  });

  testWidgets('a failed save says so and stays on the step', (tester) async {
    when(() => fakes.handoff.applyReminderPlan(any())).thenAnswer(
      (_) async => const Err(StorageWriteFailed('reminders')),
    );
    await pumpPage(tester);
    for (var i = 0; i < 3; i++) {
      await tapAndSettle(tester, find.text('Next'));
    }
    await tapAndSettle(tester, find.text('Later'));
    await tapAndSettle(tester, find.text('Not now'));

    expect(
      find.text("Couldn't save your choices. Try again, or skip."),
      findsOneWidget,
    );
    expect(find.text(notificationsTitle), findsOneWidget);
    expect(outcomes, isEmpty);
  });

  testWidgets('a custom time offers the day and the time', (tester) async {
    await pumpPage(tester);
    await tapAndSettle(tester, find.text('Next'));
    await tapAndSettle(tester, find.text('Next'));

    await tapAndSettle(tester, find.text('Custom Time'));
    await tapAndSettle(tester, find.text('Same day'));

    expect(find.text('Same day · at 9:00 PM'), findsOneWidget);
    expect(find.text('9:00 PM'), findsOneWidget);
  });

  group('location', () {
    testWidgets('explains why the device location was not used', (
      tester,
    ) async {
      when(() => fakes.useDeviceLocation(any())).thenAnswer(
        (_) async => const Err(LocationPermissionDenied(permanently: false)),
      );
      await pumpPage(tester);
      for (var i = 0; i < 3; i++) {
        await tapAndSettle(tester, find.text('Next'));
      }

      await tapAndSettle(tester, find.text('Use my location'));

      expect(
        find.text(
          "Location permission wasn't given. You can choose a city instead.",
        ),
        findsOneWidget,
      );
      expect(find.text('Later'), findsOneWidget);
    });

    testWidgets('a chosen city is confirmed and "Later" becomes "Next"', (
      tester,
    ) async {
      final cairo = CityCatalog.byId('EG:Cairo')!;
      when(
        () => fakes.chooseCity(cairo),
      ).thenAnswer((_) async => GeoPoint.fromCity(cairo));
      await pumpPage(tester);
      for (var i = 0; i < 3; i++) {
        await tapAndSettle(tester, find.text('Next'));
      }

      await tapAndSettle(tester, find.text('Choose a city'));
      await tester.enterText(find.byType(TextField), 'Cairo');
      await tester.pumpAndSettle();
      await tapAndSettle(tester, find.widgetWithText(ListTile, 'Cairo'));

      expect(find.text('Location set: Cairo'), findsOneWidget);
      expect(find.text('Later'), findsNothing);
      await tapAndSettle(tester, find.text('Next'));
      expect(find.text(notificationsTitle), findsOneWidget);
    });
  });

  testWidgets('fasting chips report their checked state', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpPage(tester);
    await tapAndSettle(tester, find.text('Next'));
    await tapAndSettle(tester, find.text('White Days'));

    expect(
      tester.getSemantics(find.byType(FastingInterestChip).at(1)),
      isSemantics(
        label: 'White Days',
        hasCheckedState: true,
        isChecked: false,
        hasTapAction: true,
      ),
    );
    expect(
      tester.getSemantics(find.byType(FastingInterestChip).first),
      isSemantics(
        label: 'Monday & Thursday',
        hasCheckedState: true,
        isChecked: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('in Arabic the layout and the page turns follow RTL', (
    tester,
  ) async {
    await pumpPage(tester, locale: const Locale('ar'));
    final center = phone.width / 2;

    expect(
      Directionality.of(tester.element(find.text('أهلًا بك في فاصومو'))),
      TextDirection.rtl,
    );
    // Skip sits on the end side, which is the left.
    expect(tester.getCenter(find.text('تخطي')).dx, lessThan(center));
    expect(tester.getCenter(find.text('التالي')).dx, lessThan(center));

    await tester.tap(find.text('التالي'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    // Half-way through the turn, the next step comes in from the left.
    expect(
      tester.getTopRight(find.text('أيّ أيام الصيام تهمّك؟')).dx,
      lessThan(center),
    );
    await tester.pumpAndSettle();
    expect(find.text('السابق'), findsOneWidget);
    expect(tester.getCenter(find.text('السابق')).dx, greaterThan(center));
  });

  testWidgets('in English the next step comes in from the right', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 160));
    expect(
      tester.getTopLeft(find.text(fastsTitle)).dx,
      greaterThan(phone.width / 2),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('with reduced motion the next step appears at once', (
    tester,
  ) async {
    await pumpPage(tester, reduceMotion: true);
    final start = tester.getTopLeft(find.text(welcomeTitle)).dx;

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump();

    expect(tester.getTopLeft(find.text(fastsTitle)).dx, start);
    expect(find.text(welcomeTitle), findsNothing);
  });

  testWidgets('every step fits at 200% text without overflow', (
    tester,
  ) async {
    await pumpPage(tester, textScale: 2);
    for (final title in [fastsTitle, timeTitle, locationTitle]) {
      await tapAndSettle(tester, find.text('Next').last);
      expect(find.text(title), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tapAndSettle(tester, find.text('Later'));
    expect(find.text(notificationsTitle), findsOneWidget);
    expect(find.text('Allow notifications'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
