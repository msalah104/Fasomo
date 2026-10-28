import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/usecases/get_language.dart';
import 'package:fasomo/features/settings/domain/usecases/save_language.dart';
import 'package:fasomo/features/settings/presentation/bloc/language_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetLanguage extends Mock implements GetLanguage;

class MockSaveLanguage extends Mock implements SaveLanguage;

void main() {
  late MockGetLanguage getLanguage;
  late MockSaveLanguage saveLanguage;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(AppLanguage.system);
  });

  setUp(() {
    getLanguage = MockGetLanguage();
    saveLanguage = MockSaveLanguage();
    when(() => getLanguage(any())).thenReturn(const Ok(AppLanguage.arabic));
    when(() => saveLanguage(any())).thenAnswer((_) async => const Ok(null));
  });

  LanguageBloc build() =>
      LanguageBloc(getLanguage: getLanguage, saveLanguage: saveLanguage);

  test('starts from the saved language', () {
    final bloc = build();
    expect(bloc.state.language, AppLanguage.arabic);
    expect(bloc.state.locale, const Locale('ar'));
  });

  test(
    'falls back to the system language when the saved value is unreadable',
    () {
      when(() => getLanguage(any()))
          .thenReturn(const Err(StorageReadFailed('language')));
      final bloc = build();
      expect(bloc.state.language, AppLanguage.system);
      expect(bloc.state.locale, isNull);
    },
  );

  blocTest<LanguageBloc, LanguageState>(
    'LanguageChanged switches and saves the choice',
    build: build,
    act: (bloc) => bloc.add(const LanguageChanged(AppLanguage.english)),
    expect: () => [const LanguageState(language: AppLanguage.english)],
    verify: (_) => verify(() => saveLanguage(AppLanguage.english)).called(1),
  );

  blocTest<LanguageBloc, LanguageState>(
    'a failed save keeps the new language and reports the failure',
    setUp: () => when(() => saveLanguage(any())).thenAnswer(
      (_) async => const Err(StorageWriteFailed('language')),
    ),
    build: build,
    act: (bloc) => bloc.add(const LanguageChanged(AppLanguage.english)),
    expect: () => [
      const LanguageState(language: AppLanguage.english),
      const LanguageState(
        language: AppLanguage.english,
        failure: StorageWriteFailed('language'),
      ),
    ],
  );
}
