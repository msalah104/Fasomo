import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/usecases/get_theme_mode.dart';
import 'package:fasomo/features/settings/domain/usecases/save_theme_mode.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetThemeMode extends Mock implements GetThemeMode;

class MockSaveThemeMode extends Mock implements SaveThemeMode;

void main() {
  late MockGetThemeMode getThemeMode;
  late MockSaveThemeMode saveThemeMode;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(AppThemeMode.system);
  });

  setUp(() {
    getThemeMode = MockGetThemeMode();
    saveThemeMode = MockSaveThemeMode();
    when(() => getThemeMode(any())).thenReturn(const Ok(AppThemeMode.dark));
    when(() => saveThemeMode(any())).thenAnswer((_) async => const Ok(null));
  });

  ThemeBloc build() =>
      ThemeBloc(getThemeMode: getThemeMode, saveThemeMode: saveThemeMode);

  test('starts from the saved mode, before any event', () {
    final bloc = build();
    expect(bloc.state.mode, AppThemeMode.dark);
    expect(bloc.state.themeMode, ThemeMode.dark);
  });

  test('follows the system when the saved value is unreadable', () {
    when(
      () => getThemeMode(any()),
    ).thenReturn(const Err(StorageReadFailed('theme_mode')));
    final bloc = build();
    expect(bloc.state.mode, AppThemeMode.system);
    expect(bloc.state.themeMode, ThemeMode.system);
  });

  test('maps every mode onto the matching MaterialApp mode', () {
    expect(
      [
        for (final mode in AppThemeMode.values)
          ThemeState(mode: mode).themeMode,
      ],
      [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
    );
  });

  blocTest<ThemeBloc, ThemeState>(
    'ThemeModeChanged switches and saves the choice',
    build: build,
    act: (bloc) => bloc.add(const ThemeModeChanged(AppThemeMode.light)),
    expect: () => [const ThemeState(mode: AppThemeMode.light)],
    verify: (_) => verify(() => saveThemeMode(AppThemeMode.light)).called(1),
  );

  blocTest<ThemeBloc, ThemeState>(
    'a failed save keeps the new mode and reports the failure',
    setUp: () => when(() => saveThemeMode(any())).thenAnswer(
      (_) async => const Err(StorageWriteFailed('theme_mode')),
    ),
    build: build,
    act: (bloc) => bloc.add(const ThemeModeChanged(AppThemeMode.light)),
    expect: () => [
      const ThemeState(mode: AppThemeMode.light),
      const ThemeState(
        mode: AppThemeMode.light,
        failure: StorageWriteFailed('theme_mode'),
      ),
    ],
  );

  blocTest<ThemeBloc, ThemeState>(
    'ThemeReloaded reads the saved mode again, e.g. after a restore',
    build: build,
    setUp: () =>
        when(() => getThemeMode(any()))
            .thenReturn(const Ok(AppThemeMode.light)),
    seed: () => const ThemeState(mode: AppThemeMode.dark),
    act: (bloc) => bloc.add(const ThemeReloaded()),
    expect: () => [const ThemeState(mode: AppThemeMode.light)],
    verify: (_) => verifyNever(() => saveThemeMode(any())),
  );
}
