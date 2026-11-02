import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_settings.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/settings/presentation/bloc/prayer_settings_bloc.dart';
import 'package:fasomo/features/settings/presentation/widgets/prayer_settings_tiles.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPrayerSettingsBloc
    extends MockBloc<PrayerSettingsEvent, PrayerSettingsState>
    implements PrayerSettingsBloc;

void main() {
  late _MockPrayerSettingsBloc bloc;

  setUpAll(() => registerFallbackValue(const PrayerSettingsRefreshed()));

  void stub(PrayerSettings settings) => when(() => bloc.state).thenReturn(
    PrayerSettingsState(settings: settings, location: GeoPoint.makkah),
  );

  setUp(() {
    bloc = _MockPrayerSettingsBloc();
    stub(PrayerSettings.defaults);
  });

  Future<void> pump(WidgetTester tester, {String language = 'en'}) async {
    await tester.pumpWidget(
      BlocProvider<PrayerSettingsBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: Locale(language),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: ListView(
              children: const [
                PrayerMethodTile(),
                AsrMethodTile(),
                HighLatitudeRuleTile(),
                PrayerAdjustmentsTile(),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('in English', () {
    testWidgets('shows what each setting is now', (tester) async {
      await pump(tester);

      expect(find.text('Calculation method'), findsOneWidget);
      expect(find.text('Automatic: Umm al-Qura, Makkah'), findsOneWidget);
      expect(find.text('Asr'), findsOneWidget);
      expect(find.text("Standard (Shafi'i, Maliki, Hanbali)"), findsOneWidget);
      expect(find.textContaining('Middle of the night'), findsOneWidget);
      expect(find.text('No adjustments'), findsOneWidget);
    });

    testWidgets('a chosen method is named', (tester) async {
      stub(const PrayerSettings(method: CalculationMethod.isna));
      await pump(tester);
      expect(find.text('Islamic Society of North America'), findsOneWidget);
    });

    testWidgets('picking a method from the list changes it', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Calculation method'));
      await tester.pumpAndSettle();
      expect(find.text('Automatic (by country)'), findsOneWidget);
      await tester.tap(find.text('Egyptian General Authority of Survey'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(const PrayerMethodChanged(CalculationMethod.egyptian)),
      ).called(1);
    });

    testWidgets('going back to automatic is not taken as a dismissal', (
      tester,
    ) async {
      stub(const PrayerSettings(method: CalculationMethod.isna));
      await pump(tester);

      await tester.tap(find.text('Calculation method'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Automatic (by country)'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const PrayerMethodChanged(null))).called(1);
    });

    testWidgets('dismissing the list changes nothing', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Calculation method'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      verifyNever(() => bloc.add(any()));
    });

    testWidgets('picking Hanafi changes Asr', (tester) async {
      await pump(tester);

      await tester.tap(find.text('Asr'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hanafi'));
      await tester.pumpAndSettle();

      verify(() => bloc.add(const AsrMethodChanged(AsrMethod.hanafi)))
          .called(1);
    });

    testWidgets('picking a high-latitude rule changes it', (tester) async {
      await pump(tester);

      await tester.tap(find.text('High latitudes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('One-seventh of the night'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(
          const HighLatitudeRuleChanged(HighLatitudeRule.seventhOfTheNight),
        ),
      ).called(1);
    });

    testWidgets('the adjustment steppers move one minute at a time', (
      tester,
    ) async {
      stub(
        const PrayerSettings(adjustments: PrayerAdjustments(maghrib: 3)),
      );
      await pump(tester);
      expect(find.text('Maghrib \u2066+3\u2069 min'), findsOneWidget);

      await tester.tap(find.text('Adjust times'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Maghrib one minute later'));
      await tester.tap(find.byTooltip('Fajr one minute earlier'));
      await tester.tap(find.text('Reset'));
      await tester.pump();

      verify(
        () => bloc.add(const PrayerAdjustmentChanged(Prayer.maghrib, 4)),
      ).called(1);
      verify(
        () => bloc.add(const PrayerAdjustmentChanged(Prayer.fajr, -1)),
      ).called(1);
      verify(() => bloc.add(const PrayerAdjustmentsReset())).called(1);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Reset'), findsNothing);
    });

    testWidgets('a stepper stops at its limit', (tester) async {
      stub(
        const PrayerSettings(adjustments: PrayerAdjustments(isha: 30)),
      );
      await pump(tester);

      await tester.tap(find.text('Adjust times'));
      await tester.pumpAndSettle();
      final later = tester.widget<IconButton>(
        find
            .ancestor(
              of: find.byIcon(Icons.add),
              matching: find.byType(IconButton),
            )
            .last,
      );
      expect(later.onPressed, isNull);
    });
  });

  group('in Arabic', () {
    testWidgets('reads right to left with Arabic names', (tester) async {
      stub(
        const PrayerSettings(adjustments: PrayerAdjustments(fajr: -2)),
      );
      await pump(tester, language: 'ar');

      expect(find.text('طريقة الحساب'), findsOneWidget);
      expect(find.text('تلقائي: أم القرى، مكة المكرمة'), findsOneWidget);
      expect(find.text('الجمهور (الشافعي والمالكي والحنبلي)'), findsOne);
      expect(find.text('الفجر \u2066\u22122\u2069 د'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('طريقة الحساب'))),
        TextDirection.rtl,
      );
    });

    testWidgets('the method list is in Arabic', (tester) async {
      await pump(tester, language: 'ar');

      await tester.tap(find.text('طريقة الحساب'));
      await tester.pumpAndSettle();
      expect(find.text('تلقائي (حسب الدولة)'), findsOneWidget);
      await tester.tap(find.text('الهيئة المصرية العامة للمساحة'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(const PrayerMethodChanged(CalculationMethod.egyptian)),
      ).called(1);
    });
  });
}
