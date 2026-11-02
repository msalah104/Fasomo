import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:fasomo/features/settings/presentation/pages/settings_page.dart';
import 'package:fasomo/features/settings/presentation/widgets/settings_section.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLanguageBloc extends MockBloc<LanguageEvent, LanguageState>
    implements LanguageBloc;

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState>
    implements ThemeBloc;

class MockHijriAdjustmentBloc
    extends MockBloc<HijriAdjustmentEvent, HijriAdjustmentState>
    implements HijriAdjustmentBloc;

void main() {
  late MockLanguageBloc languageBloc;
  late MockThemeBloc themeBloc;
  late MockHijriAdjustmentBloc hijriBloc;

  setUpAll(() {
    registerFallbackValue(const LanguageChanged(AppLanguage.system));
    registerFallbackValue(const ThemeModeChanged(AppThemeMode.system));
    registerFallbackValue(const HijriOffsetChanged(HijriOffset.none));
  });

  Future<void> pump(
    WidgetTester tester, {
    Widget page = const SettingsPage(),
    Locale locale = const Locale('en'),
  }) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LanguageBloc>.value(value: languageBloc),
          BlocProvider<ThemeBloc>.value(value: themeBloc),
          BlocProvider<HijriAdjustmentBloc>.value(value: hijriBloc),
        ],
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: page,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    languageBloc = MockLanguageBloc();
    when(
      () => languageBloc.state,
    ).thenReturn(const LanguageState(language: AppLanguage.english));
    themeBloc = MockThemeBloc();
    when(
      () => themeBloc.state,
    ).thenReturn(const ThemeState(mode: AppThemeMode.system));
    hijriBloc = MockHijriAdjustmentBloc();
    when(() => hijriBloc.state).thenReturn(
      const HijriAdjustmentState(
        offset: HijriOffset.none,
        today: HijriDate(1446, 9, 1),
      ),
    );
  });

  testWidgets('shows the appearance section with the current language', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
  });

  testWidgets('picking a language from the dialog changes it', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();

    verify(
      () => languageBloc.add(const LanguageChanged(AppLanguage.arabic)),
    ).called(1);
  });

  testWidgets('re-picking the current language changes nothing', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    verifyNever(() => languageBloc.add(any()));
  });

  testWidgets('shows the current theme mode', (tester) async {
    await pump(tester);

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.byIcon(Icons.brightness_auto_outlined), findsOneWidget);
  });

  testWidgets('picking Dark from the dialog changes the theme', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    expect(find.text('Light'), findsOneWidget);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    verify(
      () => themeBloc.add(const ThemeModeChanged(AppThemeMode.dark)),
    ).called(1);
    verifyNever(() => languageBloc.add(any()));
  });

  testWidgets('reports a theme that could not be saved', (tester) async {
    whenListen(
      themeBloc,
      Stream.value(
        const ThemeState(
          mode: AppThemeMode.dark,
          failure: StorageWriteFailed('theme_mode'),
        ),
      ),
      initialState: const ThemeState(mode: AppThemeMode.system),
    );
    await pump(tester);

    expect(find.textContaining('Could not save this setting'), findsOneWidget);
  });

  group('Hijri date adjustment', () {
    Finder segment(String label) => find.descendant(
      of: find.byType(SegmentedButton<HijriOffset>),
      matching: find.text(label),
    );

    testWidgets('explains itself and previews today', (tester) async {
      await pump(tester);
      await tester.scrollUntilVisible(find.textContaining('Today:'), 100);

      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Hijri date adjustment'), findsOneWidget);
      expect(find.textContaining('Moon sighting in your country'), findsOne);
      expect(find.text('Today: 1 Ramadan 1446 AH'), findsOneWidget);
      expect(segment('0'), findsOneWidget);
      expect(segment('\u2066+2\u2069'), findsOneWidget);
      expect(segment('\u2066\u22122\u2069'), findsOneWidget);
    });

    testWidgets('picking +1 changes the offset', (tester) async {
      await pump(tester);
      await tester.scrollUntilVisible(segment('\u2066+1\u2069'), 100);

      await tester.tap(segment('\u2066+1\u2069'));
      await tester.pump();

      verify(
        () => hijriBloc.add(const HijriOffsetChanged(HijriOffset.plusOne)),
      ).called(1);
    });

    testWidgets('segments read as words to a screen reader', (tester) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);

      expect(find.bySemanticsLabel(RegExp('Add 2 days')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Subtract 1 day')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('No adjustment')), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('reports an offset that could not be saved', (tester) async {
      whenListen(
        hijriBloc,
        Stream.value(
          const HijriAdjustmentState(
            offset: HijriOffset.none,
            today: HijriDate(1446, 9, 1),
            failure: StorageWriteFailed('hijri_offset_days'),
          ),
        ),
        initialState: const HijriAdjustmentState(
          offset: HijriOffset.none,
          today: HijriDate(1446, 9, 1),
        ),
      );
      await pump(tester);

      expect(find.textContaining('Could not save this setting'), findsOne);
    });
  });

  testWidgets('shows sections contributed by the app shell', (tester) async {
    await pump(
      tester,
      page: const SettingsPage(
        extraSections: [
          SettingsSection(title: 'Extra', children: [Text('Extra tile')]),
        ],
      ),
    );

    expect(find.text('Extra'), findsOneWidget);
    expect(find.text('Extra tile'), findsOneWidget);
  });

  testWidgets('reports a choice that could not be saved', (tester) async {
    whenListen(
      languageBloc,
      Stream.value(
        const LanguageState(
          language: AppLanguage.arabic,
          failure: StorageWriteFailed('language'),
        ),
      ),
      initialState: const LanguageState(language: AppLanguage.english),
    );
    await pump(tester);

    expect(find.textContaining('Could not save this setting'), findsOneWidget);
  });

  testWidgets('lays out right to left in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'));

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('المظهر'))),
      TextDirection.rtl,
    );
  });
}
