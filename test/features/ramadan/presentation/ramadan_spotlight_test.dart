import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/presentation/western_digits.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/ramadan_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/ramadan_spotlight.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mocktail/mocktail.dart';

class _MockRamadanBloc extends MockBloc<RamadanEvent, RamadanState>
    implements RamadanBloc;

final _date = DateTime(2027, 2, 19);
final _fajr = DateTime.utc(2027, 2, 19, 5, 16);
final _maghrib = DateTime.utc(2027, 2, 19, 17, 22);
final _london = GeoPoint.fromCity(CityCatalog.byId('GB:London')!);

RamadanDay _day({FastingMoment? next, GeoPoint? location}) => RamadanDay(
  date: _date,
  hijriDate: const HijriDate(1448, 9, 12),
  daysInMonth: 29,
  times: PrayerTimes(
    date: _date,
    fajr: _fajr,
    sunrise: DateTime.utc(2027, 2, 19, 7, 7),
    dhuhr: DateTime.utc(2027, 2, 19, 12, 14),
    asr: DateTime.utc(2027, 2, 19, 14, 51),
    maghrib: _maghrib,
    isha: DateTime.utc(2027, 2, 19, 19, 8),
  ),
  location: location ?? _london,
  method: CalculationMethod.muslimWorldLeague,
  next: next,
);

final _iftarNext = FastingMoment(
  kind: FastingMomentKind.iftar,
  at: _maghrib,
  remaining: const Duration(hours: 3, minutes: 41, seconds: 30),
);

String _time(DateTime utc, String locale) =>
    DateFormat.jm(locale).format(utc.toLocal());

void main() {
  late _MockRamadanBloc bloc;

  setUpAll(() {
    useWesternDigitsInDates();
    registerFallbackValue(const RamadanRefreshed());
  });

  setUp(() => bloc = _MockRamadanBloc());

  void stub(RamadanState state) => when(() => bloc.state).thenReturn(state);

  Future<void> pump(
    WidgetTester tester, {
    String language = 'en',
    FastedActionBuilder? fasted,
  }) async {
    await tester.pumpWidget(
      BlocProvider<RamadanBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(
              child: RamadanSpotlight(fastedActionBuilder: fasted),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows nothing when Ramadan is not near', (tester) async {
    stub(const RamadanState(overview: RamadanNotNear()));
    await pump(tester);
    expect(find.byType(Card), findsNothing);
  });

  testWidgets('resumes the ticks when shown', (tester) async {
    stub(const RamadanState(overview: RamadanNotNear()));
    await pump(tester);
    verify(() => bloc.add(const RamadanResumed())).called(1);
  });

  group('before Ramadan', () {
    testWidgets('counts the days down to the expected start', (tester) async {
      stub(
        RamadanState(
          overview: RamadanCountdown(
            daysUntil: 12,
            startDate: DateTime(2027, 2, 8),
          ),
        ),
      );
      await pump(tester);

      expect(find.text('Ramadan in 12 days'), findsOneWidget);
      expect(
        find.text('Expected to start on Monday, February 8'),
        findsOneWidget,
      );
    });

    testWidgets('the day before, says when the first suhoor ends', (
      tester,
    ) async {
      final fajr = DateTime.utc(2027, 2, 8, 5, 34);
      stub(
        RamadanState(
          overview: RamadanCountdown(
            daysUntil: 1,
            startDate: DateTime(2027, 2, 8),
            firstSuhoorEnds: fajr,
          ),
        ),
      );
      await pump(tester);

      expect(find.text('Ramadan is tomorrow'), findsOneWidget);
      expect(
        find.text('The first suhoor ends at ${_time(fajr, 'en')} (Fajr)'),
        findsOneWidget,
      );
    });

    testWidgets('in Arabic, with Western digits', (tester) async {
      stub(
        RamadanState(
          overview: RamadanCountdown(
            daysUntil: 12,
            startDate: DateTime(2027, 2, 8),
          ),
        ),
      );
      await pump(tester, language: 'ar');

      expect(find.text('رمضان بعد 12 يوماً'), findsOneWidget);
      expect(find.textContaining('8 فبراير'), findsOneWidget);
    });
  });

  group('during Ramadan', () {
    final checklist = RamadanChecklist(
      date: _date,
      prayedTaraweeh: true,
      quranPages: 12,
    );

    testWidgets('shows the day, the countdown and the two times', (
      tester,
    ) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          checklist: checklist,
        ),
      );
      await pump(tester);

      expect(find.text('Day 12 of 29'), findsOneWidget);
      expect(find.text('Iftar in 3 h 42 min'), findsOneWidget);
      expect(find.text('Suhoor ends'), findsOneWidget);
      expect(find.text(_time(_fajr, 'en')), findsOneWidget);
      expect(find.text('Iftar'), findsOneWidget);
      expect(find.text(_time(_maghrib, 'en')), findsOneWidget);
      expect(find.text('London · Muslim World League'), findsOneWidget);
    });

    testWidgets('reads the countdown in words', (tester) async {
      final semantics = tester.ensureSemantics();
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          checklist: checklist,
        ),
      );
      await pump(tester);

      expect(
        find.bySemanticsLabel('Iftar in 3 hours 42 minutes'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('12 pages'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('before Fajr counts down to the end of suhoor', (tester) async {
      stub(
        RamadanState(
          overview: _day(
            next: FastingMoment(
              kind: FastingMomentKind.suhoorEnds,
              at: _fajr,
              remaining: const Duration(minutes: 44, seconds: 10),
            ),
          ),
          checklist: checklist,
        ),
      );
      await pump(tester);
      expect(find.text('Suhoor ends in 45 min'), findsOneWidget);
    });

    testWidgets('after the last iftar wishes Eid Mubarak', (tester) async {
      stub(RamadanState(overview: _day(), checklist: checklist));
      await pump(tester);
      expect(find.text('Ramadan is complete. Eid Mubarak!'), findsOneWidget);
    });

    testWidgets('says when the times are for the stand-in location', (
      tester,
    ) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext, location: GeoPoint.makkah),
          checklist: checklist,
        ),
      );
      await pump(tester);
      expect(
        find.text('Times for Makkah until you set your location'),
        findsOneWidget,
      );
    });

    testWidgets('the checklist sends its changes', (tester) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          checklist: checklist,
        ),
      );
      await pump(tester, fasted: (date, hijri) => Text('fasted $date'));

      expect(find.text('fasted $_date'), findsOneWidget);
      expect(find.text('Taraweeh'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.tap(find.text('Taraweeh'));
      await tester.tap(find.byTooltip('Add a page'));
      await tester.tap(find.byTooltip('Remove a page'));

      verify(() => bloc.add(const TaraweehToggled())).called(1);
      verify(() => bloc.add(const QuranPagesChanged(13))).called(1);
      verify(() => bloc.add(const QuranPagesChanged(11))).called(1);
    });

    testWidgets('no pages cannot go lower', (tester) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          checklist: RamadanChecklist(date: _date),
        ),
      );
      await pump(tester);

      final remove = tester.widget<IconButton>(
        find.ancestor(
          of: find.byIcon(Icons.remove),
          matching: find.byType(IconButton),
        ),
      );
      expect(remove.onPressed, isNull);
    });

    testWidgets('an unreadable checklist offers a retry', (tester) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          loadFailure: const StorageReadFailed('ramadan.checklist'),
        ),
      );
      await pump(tester);

      expect(find.text("Couldn't load today's checklist."), findsOneWidget);
      expect(find.text('Taraweeh'), findsNothing);
      await tester.tap(find.text('Retry'));
      verify(() => bloc.add(const RamadanRefreshed())).called(1);
    });

    testWidgets('a failed save is reported', (tester) async {
      final ok = RamadanState(
        overview: _day(next: _iftarNext),
        checklist: checklist,
      );
      whenListen(
        bloc,
        Stream.value(ok.copyWith(saveFailure: const StorageWriteFailed('x'))),
        initialState: ok,
      );
      await pump(tester);
      expect(find.text("Couldn't save today's checklist."), findsOneWidget);
    });

    testWidgets('all prayer times open below', (tester) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          checklist: checklist,
        ),
      );
      await pump(tester);

      await tester.tap(find.text("Today's prayer times"));
      await tester.pumpAndSettle();

      for (final name in ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Isha'), findsOneWidget);
      expect(find.text(_time(_fajr, 'en')), findsNWidgets(2));
    });

    testWidgets('in Arabic, right to left with Western digits', (
      tester,
    ) async {
      stub(
        RamadanState(
          overview: _day(next: _iftarNext),
          checklist: checklist,
        ),
      );
      await pump(tester, language: 'ar');

      expect(find.text('اليوم 12 من 29'), findsOneWidget);
      expect(find.text('الإفطار بعد 3 س 42 د'), findsOneWidget);
      expect(find.text('ينتهي السحور'), findsOneWidget);
      expect(find.text(_time(_fajr, 'ar')), findsOneWidget);
      expect(_time(_fajr, 'ar'), contains(RegExp('[0-9]')));
      expect(find.text('لندن · رابطة العالم الإسلامي'), findsOneWidget);
      expect(find.text('صلاة التراويح'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('صلاة التراويح'))),
        TextDirection.rtl,
      );
    });
  });
}
