import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/domain/usecases/save_suhoor_iftar_settings.dart';
import 'package:fasomo/features/ramadan/presentation/bloc/suhoor_iftar_bloc.dart';
import 'package:fasomo/features/ramadan/presentation/widgets/suhoor_iftar_reminders.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGet extends Mock implements GetSuhoorIftarSettings;

class _MockSave extends Mock implements SaveSuhoorIftarSettings;

class _MockSuhoorIftarBloc extends MockBloc<SuhoorIftarEvent, SuhoorIftarState>
    implements SuhoorIftarBloc;

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(SuhoorIftarSettings.defaults);
    registerFallbackValue(
      const SuhoorIftarSettingsChanged(SuhoorIftarSettings.defaults),
    );
  });

  group('SuhoorIftarBloc', () {
    late _MockGet get;
    late _MockSave save;

    setUp(() {
      get = _MockGet();
      save = _MockSave();
      when(() => get(any())).thenReturn(const Ok(SuhoorIftarSettings.defaults));
      when(() => save(any())).thenAnswer((_) async => const Ok(null));
    });

    SuhoorIftarBloc build() =>
        SuhoorIftarBloc(getSettings: get, saveSettings: save);

    test('starts from the saved settings, or the defaults', () {
      when(() => get(any())).thenReturn(
        const Ok(SuhoorIftarSettings(iftarMinutesBeforeMaghrib: 5)),
      );
      expect(build().state.settings.iftarMinutesBeforeMaghrib, 5);

      when(
        () => get(any()),
      ).thenReturn(const Err(StorageReadFailed('ramadan.reminders')));
      expect(build().state.settings, SuhoorIftarSettings.defaults);
    });

    blocTest<SuhoorIftarBloc, SuhoorIftarState>(
      'a change shows at once and is saved',
      build: build,
      act: (bloc) => bloc.add(
        const SuhoorIftarSettingsChanged(
          SuhoorIftarSettings(suhoorMinutesBeforeFajr: 30),
        ),
      ),
      expect: () => [
        const SuhoorIftarState(
          settings: SuhoorIftarSettings(suhoorMinutesBeforeFajr: 30),
        ),
      ],
      verify: (_) => verify(
        () => save(const SuhoorIftarSettings(suhoorMinutesBeforeFajr: 30)),
      ).called(1),
    );

    blocTest<SuhoorIftarBloc, SuhoorIftarState>(
      'a change that cannot be saved is undone and reported',
      build: build,
      setUp: () => when(
        () => save(any()),
      ).thenAnswer((_) async => const Err(StorageWriteFailed('x'))),
      act: (bloc) => bloc.add(
        const SuhoorIftarSettingsChanged(
          SuhoorIftarSettings(iftarEnabled: false),
        ),
      ),
      expect: () => [
        const SuhoorIftarState(
          settings: SuhoorIftarSettings(iftarEnabled: false),
        ),
        const SuhoorIftarState(
          settings: SuhoorIftarSettings.defaults,
          failure: StorageWriteFailed('x'),
        ),
      ],
    );

    blocTest<SuhoorIftarBloc, SuhoorIftarState>(
      'the same settings save nothing',
      build: build,
      act: (bloc) => bloc.add(
        const SuhoorIftarSettingsChanged(SuhoorIftarSettings.defaults),
      ),
      expect: () => <SuhoorIftarState>[],
      verify: (_) => verifyNever(() => save(any())),
    );
  });

  group('the Reminders tab card and sheet', () {
    late _MockSuhoorIftarBloc bloc;

    setUp(() {
      bloc = _MockSuhoorIftarBloc();
      when(
        () => bloc.state,
      ).thenReturn(
        const SuhoorIftarState(settings: SuhoorIftarSettings.defaults),
      );
    });

    Future<void> pump(WidgetTester tester, {String language = 'en'}) async {
      await tester.pumpWidget(
        BlocProvider<SuhoorIftarBloc>.value(
          value: bloc,
          child: MaterialApp(
            theme: buildAppTheme(Brightness.light),
            locale: Locale(language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const Scaffold(body: SuhoorIftarReminderCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('summarises what is on', (tester) async {
      await pump(tester);
      expect(find.text('Suhoor and iftar'), findsOneWidget);
      expect(
        find.text('Suhoor: 45 min before Fajr · Iftar: At Maghrib'),
        findsOneWidget,
      );
    });

    testWidgets('says Off when both are off', (tester) async {
      when(() => bloc.state).thenReturn(
        const SuhoorIftarState(
          settings: SuhoorIftarSettings(
            suhoorEnabled: false,
            iftarEnabled: false,
          ),
        ),
      );
      await pump(tester);
      expect(find.text('Off'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    });

    testWidgets('the sheet changes lead times and switches', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Suhoor and iftar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Fajr and Maghrib'), findsOneWidget);
      await tester.tap(find.text('30 min before Fajr'));
      await tester.tap(find.text('5 min before Maghrib'));
      await tester.tap(find.text('Also on other fasting days'));
      await tester.tap(find.text('Iftar'));
      await tester.pump();

      verify(
        () => bloc.add(
          const SuhoorIftarSettingsChanged(
            SuhoorIftarSettings(suhoorMinutesBeforeFajr: 30),
          ),
        ),
      ).called(1);
      verify(
        () => bloc.add(
          const SuhoorIftarSettingsChanged(
            SuhoorIftarSettings(iftarMinutesBeforeMaghrib: 5),
          ),
        ),
      ).called(1);
      verify(
        () => bloc.add(
          const SuhoorIftarSettingsChanged(
            SuhoorIftarSettings(onOtherFastingDays: true),
          ),
        ),
      ).called(1);
      verify(
        () => bloc.add(
          const SuhoorIftarSettingsChanged(
            SuhoorIftarSettings(iftarEnabled: false),
          ),
        ),
      ).called(1);
    });

    testWidgets('reports a change that could not be saved', (tester) async {
      whenListen(
        bloc,
        Stream.value(
          const SuhoorIftarState(
            settings: SuhoorIftarSettings.defaults,
            failure: StorageWriteFailed('x'),
          ),
        ),
        initialState: const SuhoorIftarState(
          settings: SuhoorIftarSettings.defaults,
        ),
      );
      await pump(tester);
      expect(find.textContaining('Could not save this setting'), findsOne);
    });

    testWidgets('in Arabic, right to left', (tester) async {
      await pump(tester, language: 'ar');
      expect(find.text('السحور والإفطار'), findsOneWidget);
      expect(
        find.text('السحور: قبل الفجر بـ45 د · الإفطار: عند المغرب'),
        findsOneWidget,
      );
      expect(
        Directionality.of(tester.element(find.text('السحور والإفطار'))),
        TextDirection.rtl,
      );

      await tester.tap(find.text('السحور والإفطار'));
      await tester.pumpAndSettle();
      expect(find.text('في أيام الصيام الأخرى أيضًا'), findsOneWidget);
      expect(find.text('قبل المغرب بـ10 د'), findsOneWidget);
    });
  });
}
