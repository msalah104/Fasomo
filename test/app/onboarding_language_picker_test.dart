import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/app/app_onboarding.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLanguageBloc extends MockBloc<LanguageEvent, LanguageState>
    implements LanguageBloc;

void main() {
  late MockLanguageBloc languageBloc;

  setUpAll(
    () => registerFallbackValue(const LanguageChanged(AppLanguage.system)),
  );

  setUp(() {
    languageBloc = MockLanguageBloc();
    when(
      () => languageBloc.state,
    ).thenReturn(const LanguageState(language: AppLanguage.system));
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      BlocProvider<LanguageBloc>.value(
        value: languageBloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: OnboardingLanguagePicker()),
        ),
      ),
    );
  }

  testWidgets('offers English, Arabic and the device language', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(
      tester
          .widget<RadioGroup<AppLanguage>>(
            find.byType(RadioGroup<AppLanguage>),
          )
          .groupValue,
      AppLanguage.system,
    );
  });

  testWidgets('a choice changes the app language at once', (tester) async {
    await pump(tester);
    await tester.tap(find.text('العربية'));
    await tester.pump();

    verify(
      () => languageBloc.add(const LanguageChanged(AppLanguage.arabic)),
    ).called(1);
  });
}
