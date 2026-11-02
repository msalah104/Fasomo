import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
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

void main() {
  late MockLanguageBloc languageBloc;
  late MockThemeBloc themeBloc;

  setUpAll(() {
    registerFallbackValue(const LanguageChanged(AppLanguage.system));
    registerFallbackValue(const ThemeModeChanged(AppThemeMode.system));
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
