import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_ramadan_overview.dart';
import 'package:fasomo/features/ramadan/domain/usecases/save_ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/ramadan_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_minute_ticker.dart';

class _MockGetOverview extends Mock implements GetRamadanOverview;

class _MockGetChecklist extends Mock implements GetRamadanChecklist;

class _MockSaveChecklist extends Mock implements SaveRamadanChecklist;

RamadanDay ramadanDay(DateTime date, {int day = 12}) => RamadanDay(
  date: date,
  hijriDate: HijriDate(1448, 9, day),
  daysInMonth: 29,
  times: PrayerTimes(date: date, dhuhr: date.add(const Duration(hours: 12))),
  location: GeoPoint.makkah,
  method: CalculationMethod.ummAlQura,
);

void main() {
  late _MockGetOverview getOverview;
  late _MockGetChecklist getChecklist;
  late _MockSaveChecklist saveChecklist;
  late FakeMinuteTicker ticker;

  final today = DateTime(2027, 2, 19);
  final emptyToday = RamadanChecklist(date: today);

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(RamadanChecklist(date: DateTime(2000)));
  });

  setUp(() {
    getOverview = _MockGetOverview();
    getChecklist = _MockGetChecklist();
    saveChecklist = _MockSaveChecklist();
    ticker = FakeMinuteTicker();
    when(() => getOverview(any())).thenReturn(ramadanDay(today));
    when(() => getChecklist(any())).thenReturn(Ok(emptyToday));
    when(() => saveChecklist(any())).thenAnswer((_) async => const Ok(null));
  });

  tearDown(() => ticker.dispose());

  RamadanBloc build() => RamadanBloc(
    getOverview: getOverview,
    getChecklist: getChecklist,
    saveChecklist: saveChecklist,
    ticker: ticker,
  );

  test('starts with the overview and today checklist, before any event', () {
    final bloc = build();
    expect(bloc.state.overview, ramadanDay(today));
    expect(bloc.state.checklist, emptyToday);
    verify(() => getChecklist(today)).called(1);
  });

  test('outside Ramadan there is no checklist to read', () {
    when(() => getOverview(any())).thenReturn(const RamadanNotNear());
    final bloc = build();
    expect(bloc.state, const RamadanState(overview: RamadanNotNear()));
    verifyNever(() => getChecklist(any()));
  });

  test('an unreadable checklist is reported, not shown as empty', () {
    when(
      () => getChecklist(any()),
    ).thenReturn(const Err(StorageReadFailed('ramadan.checklist')));
    final bloc = build();
    expect(bloc.state.checklist, isNull);
    expect(bloc.state.loadFailure, isA<StorageReadFailed>());
  });

  blocTest<RamadanBloc, RamadanState>(
    'ticks while resumed and stops when paused',
    build: build,
    act: (bloc) async {
      bloc.add(const RamadanResumed());
      await Future<void>.delayed(Duration.zero);
      expect(ticker.listeners, 1);
      ticker.tick();
      await Future<void>.delayed(Duration.zero);
      bloc.add(const RamadanPaused());
      await Future<void>.delayed(Duration.zero);
      expect(ticker.listeners, 0);
    },
    // Resume + one tick recompute the overview; the checklist is read once
    // at the start since the day did not change.
    verify: (_) {
      verify(() => getOverview(any())).called(3);
      verify(() => getChecklist(any())).called(1);
    },
  );

  blocTest<RamadanBloc, RamadanState>(
    'a new day reads that day checklist',
    build: build,
    act: (bloc) {
      final tomorrow = DateTime(2027, 2, 20);
      when(
        () => getOverview(any()),
      ).thenReturn(ramadanDay(tomorrow, day: 13));
      when(() => getChecklist(tomorrow)).thenReturn(
        Ok(RamadanChecklist(date: tomorrow, quranPages: 4)),
      );
      bloc.add(const RamadanRefreshed());
    },
    expect: () => [
      RamadanState(
        overview: ramadanDay(DateTime(2027, 2, 20), day: 13),
        checklist: RamadanChecklist(date: DateTime(2027, 2, 20), quranPages: 4),
      ),
    ],
  );

  blocTest<RamadanBloc, RamadanState>(
    'Taraweeh and Quran pages are shown at once and saved',
    build: build,
    act: (bloc) => bloc
      ..add(const TaraweehToggled())
      ..add(const QuranPagesChanged(5)),
    expect: () => [
      RamadanState(
        overview: ramadanDay(today),
        checklist: emptyToday.copyWith(prayedTaraweeh: true),
      ),
      RamadanState(
        overview: ramadanDay(today),
        checklist: emptyToday.copyWith(prayedTaraweeh: true, quranPages: 5),
      ),
    ],
    verify: (_) {
      verify(
        () => saveChecklist(emptyToday.copyWith(prayedTaraweeh: true)),
      ).called(1);
      verify(
        () => saveChecklist(
          emptyToday.copyWith(prayedTaraweeh: true, quranPages: 5),
        ),
      ).called(1);
    },
  );

  blocTest<RamadanBloc, RamadanState>(
    'a failed save puts the checklist back and reports it once',
    build: build,
    setUp: () => when(
      () => saveChecklist(any()),
    ).thenAnswer((_) async => const Err(StorageWriteFailed('x'))),
    act: (bloc) => bloc.add(const QuranPagesChanged(3)),
    expect: () => [
      RamadanState(
        overview: ramadanDay(today),
        checklist: emptyToday.copyWith(quranPages: 3),
      ),
      RamadanState(
        overview: ramadanDay(today),
        checklist: emptyToday,
        saveFailure: const StorageWriteFailed('x'),
      ),
    ],
  );

  blocTest<RamadanBloc, RamadanState>(
    'the checklist cannot change outside Ramadan',
    build: build,
    setUp: () =>
        when(() => getOverview(any())).thenReturn(const RamadanNotNear()),
    act: (bloc) => bloc.add(const TaraweehToggled()),
    expect: () => <RamadanState>[],
    verify: (_) => verifyNever(() => saveChecklist(any())),
  );

  blocTest<RamadanBloc, RamadanState>(
    'the same page count saves nothing',
    build: build,
    act: (bloc) => bloc.add(const QuranPagesChanged(0)),
    expect: () => <RamadanState>[],
  );

  test('closing stops the ticks', () async {
    final bloc = build()..add(const RamadanResumed());
    await Future<void>.delayed(Duration.zero);
    expect(ticker.listeners, 1);
    await bloc.close();
    expect(ticker.listeners, 0);
  });
}
