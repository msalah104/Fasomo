import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/adjusted_hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/settings/domain/entities/app_language.dart';
import 'package:fasomo/features/settings/domain/entities/app_theme_mode.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';
import 'package:fasomo/features/settings/domain/usecases/get_hijri_offset.dart';
import 'package:fasomo/features/settings/domain/usecases/get_today_hijri_date.dart';
import 'package:fasomo/features/settings/domain/usecases/save_hijri_offset.dart';
import 'package:fasomo/features/settings/presentation/bloc/hijri_adjustment_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// An in-memory settings store that is also the converter's offset source,
/// as in the app. [failWrites] makes saves fail without storing.
class _FakeSettings implements SettingsRepository, HijriOffsetSource {
  HijriOffset stored = HijriOffset.none;
  bool failWrites = false;
  bool unreadable = false;

  @override
  HijriOffset get hijriOffset => unreadable ? HijriOffset.none : stored;

  @override
  Result<HijriOffset, StorageFailure> getHijriOffset() => unreadable
      ? const Err(StorageReadFailed('hijri_offset_days'))
      : Ok(stored);

  @override
  Future<Result<void, StorageFailure>> saveHijriOffset(
    HijriOffset offset,
  ) async {
    if (failWrites) return const Err(StorageWriteFailed('hijri_offset_days'));
    stored = offset;
    return const Ok(null);
  }

  @override
  Result<AppLanguage, StorageFailure> getLanguage() =>
      const Ok(AppLanguage.system);

  @override
  Future<Result<void, StorageFailure>> saveLanguage(AppLanguage language) =>
      throw UnimplementedError();

  @override
  Result<AppThemeMode, StorageFailure> getThemeMode() =>
      const Ok(AppThemeMode.system);

  @override
  Future<Result<void, StorageFailure>> saveThemeMode(AppThemeMode mode) =>
      throw UnimplementedError();
}

void main() {
  // Saturday 1 March 2025 is 1 Ramadan 1446 in the Umm al-Qura table.
  final clock = Clock.fixed(DateTime(2025, 3, 1, 9));
  late _FakeSettings settings;

  setUp(() => settings = _FakeSettings());

  HijriAdjustmentBloc build({Clock? at}) => HijriAdjustmentBloc(
    getHijriOffset: GetHijriOffset(settings),
    saveHijriOffset: SaveHijriOffset(settings),
    getTodayHijriDate: GetTodayHijriDate(
      converter: AdjustedHijriConverter(
        const UmmAlQuraHijriConverter(),
        settings,
      ),
      clock: at ?? clock,
    ),
  );

  test('starts from the saved offset with today previewed through it', () {
    settings.stored = HijriOffset.plusOne;
    final bloc = build();
    expect(
      bloc.state,
      const HijriAdjustmentState(
        offset: HijriOffset.plusOne,
        today: HijriDate(1446, 9, 2),
      ),
    );
  });

  test('an unreadable offset counts as none, like the converter', () {
    settings.unreadable = true;
    expect(
      build().state,
      const HijriAdjustmentState(
        offset: HijriOffset.none,
        today: HijriDate(1446, 9, 1),
      ),
    );
  });

  test('outside the supported range there is no preview', () {
    expect(build(at: Clock.fixed(DateTime(2090))).state.today, isNull);
  });

  blocTest<HijriAdjustmentBloc, HijriAdjustmentState>(
    'a new offset is saved and today moves with it',
    build: build,
    act: (bloc) => bloc
      ..add(const HijriOffsetChanged(HijriOffset.minusOne))
      ..add(const HijriOffsetChanged(HijriOffset.plusTwo)),
    expect: () => const [
      HijriAdjustmentState(
        offset: HijriOffset.minusOne,
        today: HijriDate(1446, 8, 29),
      ),
      HijriAdjustmentState(
        offset: HijriOffset.plusTwo,
        today: HijriDate(1446, 9, 3),
      ),
    ],
    verify: (_) => expect(settings.stored, HijriOffset.plusTwo),
  );

  blocTest<HijriAdjustmentBloc, HijriAdjustmentState>(
    'picking the current offset does nothing',
    build: build,
    act: (bloc) => bloc.add(const HijriOffsetChanged(HijriOffset.none)),
    expect: () => const <HijriAdjustmentState>[],
  );

  blocTest<HijriAdjustmentBloc, HijriAdjustmentState>(
    'a failed save keeps what the converter uses and reports the failure',
    setUp: () => settings.failWrites = true,
    build: build,
    act: (bloc) => bloc.add(const HijriOffsetChanged(HijriOffset.plusOne)),
    expect: () => const [
      HijriAdjustmentState(
        offset: HijriOffset.none,
        today: HijriDate(1446, 9, 1),
        failure: StorageWriteFailed('hijri_offset_days'),
      ),
    ],
  );

  blocTest<HijriAdjustmentBloc, HijriAdjustmentState>(
    'refreshing the preview picks up a new day',
    build: () => build(at: Clock.fixed(DateTime(2025, 3, 2, 0, 5))),
    seed: () => const HijriAdjustmentState(
      offset: HijriOffset.none,
      today: HijriDate(1446, 9, 1),
    ),
    act: (bloc) => bloc.add(const HijriPreviewRefreshed()),
    expect: () => const [
      HijriAdjustmentState(
        offset: HijriOffset.none,
        today: HijriDate(1446, 9, 2),
      ),
    ],
  );
}
