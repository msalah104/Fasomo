import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/fasting_calendar.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:fasomo/features/calendar/presentation/pages/calendar_page.dart';
import 'package:fasomo/features/calendar/presentation/widgets/calendar_month_pager.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCalendarBloc extends MockBloc<CalendarEvent, CalendarState>
    implements CalendarBloc;

void main() {
  // Wednesday 28 October 2026 is 17 Jumada al-Ula 1448.
  const current = HijriMonth(1448, 5);
  final repository = CalendarRepositoryImpl(
    calendar: const FastingCalendar(UmmAlQuraHijriConverter()),
    clock: Clock.fixed(DateTime(2026, 10, 28, 10)),
  );

  List<CalendarDay> daysOf(HijriMonth month) => (repository.getMonth(
    month,
  ) as Ok<List<CalendarDay>, CalendarFailure>).value;

  CalendarState shown(HijriMonth month, {bool showGregorianDays = false}) =>
      CalendarState(
        status: CalendarStatus.success,
        days: daysOf(month),
        previousDays: daysOf(month.previous),
        nextDays: daysOf(month.next),
        month: month,
        currentMonth: current,
        showGregorianDays: showGregorianDays,
      );

  late MockCalendarBloc bloc;

  setUpAll(() => registerFallbackValue(const LoadCalendar()));

  Future<void> pumpPage(
    WidgetTester tester,
    CalendarState state, {
    Locale locale = const Locale('en'),
    bool reduceMotion = false,
    Stream<CalendarState>? updates,
  }) async {
    tester.view
      ..physicalSize = const Size(1200, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    bloc = MockCalendarBloc();
    if (updates != null) {
      whenListen(bloc, updates, initialState: state);
    } else {
      when(() => bloc.state).thenReturn(state);
    }
    await tester.pumpWidget(
      BlocProvider<CalendarBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduceMotion),
            child: child ?? const SizedBox.shrink(),
          ),
          home: const Scaffold(body: CalendarPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double? pagerPage(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView)).controller?.page;

  group('Today button', () {
    testWidgets('is hidden on the current month', (tester) async {
      await pumpPage(tester, shown(current));
      expect(find.text('Today'), findsNothing);
    });

    testWidgets('appears away from the current month and goes back', (
      tester,
    ) async {
      await pumpPage(tester, shown(const HijriMonth(1448, 7)));

      await tester.tap(find.text('Today'));

      verify(() => bloc.add(const GoToToday())).called(1);
    });
  });

  group('Gregorian toggle', () {
    // The Gregorian number is read out as the full date.
    Finder gregorianDay() => find.bySemanticsLabel(RegExp('October 28, 2026'));

    testWidgets('is off by default and asks the bloc to turn it on', (
      tester,
    ) async {
      await pumpPage(tester, shown(current));

      expect(gregorianDay(), findsNothing);
      expect(
        tester.widget<FilterChip>(find.byType(FilterChip)).selected,
        false,
      );

      await tester.tap(find.byType(FilterChip));
      verify(() => bloc.add(const ToggleGregorianDays())).called(1);
    });

    testWidgets('when on, shows the Gregorian day under the Hijri one', (
      tester,
    ) async {
      await pumpPage(tester, shown(current, showGregorianDays: true));

      expect(gregorianDay(), findsOneWidget);
      expect(tester.widget<FilterChip>(find.byType(FilterChip)).selected, true);
    });

    testWidgets('a failed save shows a snackbar', (tester) async {
      await pumpPage(
        tester,
        shown(current),
        updates: Stream.value(
          shown(current).copyWith(
            preferenceFailure: const StorageWriteFailed('key'),
          ),
        ),
      );

      expect(find.text('Could not save the calendar setting'), findsOneWidget);
    });
  });

  group('swiping', () {
    testWidgets('right to left opens the next month', (tester) async {
      await pumpPage(tester, shown(current));

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();

      verify(() => bloc.add(ChangeMonth(current.next))).called(1);
    });

    testWidgets('left to right opens the previous month', (tester) async {
      await pumpPage(tester, shown(current));

      await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
      await tester.pumpAndSettle();

      verify(() => bloc.add(ChangeMonth(current.previous))).called(1);
    });

    testWidgets('follows reading direction in Arabic', (tester) async {
      await pumpPage(tester, shown(current), locale: const Locale('ar'));
      expect(
        Directionality.of(tester.element(find.byType(PageView))),
        TextDirection.rtl,
      );

      // The next month lies to the left, so it is pulled in to the right.
      await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
      await tester.pumpAndSettle();
      verify(() => bloc.add(ChangeMonth(current.next))).called(1);
    });

    testWidgets('under reduced motion a fling changes month in place', (
      tester,
    ) async {
      await pumpPage(tester, shown(current), reduceMotion: true);
      final pageView = tester.widget<PageView>(find.byType(PageView));
      expect(pageView.physics, isA<NeverScrollableScrollPhysics>());

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pump();

      verify(() => bloc.add(ChangeMonth(current.next))).called(1);
      // Nothing slid: the pager waits for the bloc's month.
      expect(pagerPage(tester), current.pageIndex);
    });

    testWidgets(
      'under reduced motion in Arabic, a fling to the right is next',
      (
        tester,
      ) async {
        await pumpPage(
          tester,
          shown(current),
          locale: const Locale('ar'),
          reduceMotion: true,
        );

        await tester.fling(find.byType(PageView), const Offset(300, 0), 1000);
        await tester.pump();

        verify(() => bloc.add(ChangeMonth(current.next))).called(1);
      },
    );

    testWidgets('the pager follows a month changed by the arrows', (
      tester,
    ) async {
      await pumpPage(
        tester,
        shown(current),
        updates: Stream.value(shown(current.next)),
      );

      expect(pagerPage(tester), current.next.pageIndex);
      // The turn the bloc asked for is not reported back as a swipe.
      verifyNever(() => bloc.add(any()));
    });

    testWidgets('the arrows send previous and next', (tester) async {
      await pumpPage(tester, shown(current));

      await tester.tap(find.byTooltip('Next month'));
      await tester.tap(find.byTooltip('Previous month'));

      verify(() => bloc.add(const NextMonth())).called(1);
      verify(() => bloc.add(const PreviousMonth())).called(1);
    });
  });
}
