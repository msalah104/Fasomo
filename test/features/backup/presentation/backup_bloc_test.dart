import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/backup/domain/usecases/export_backup.dart';
import 'package:fasomo/features/backup/domain/usecases/restore_backup.dart';
import 'package:fasomo/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockExportBackup extends Mock implements ExportBackup;

class MockRestoreBackup extends Mock implements RestoreBackup;

void main() {
  late MockExportBackup exportBackup;
  late MockRestoreBackup restoreBackup;

  final report = RestoreReport(
    restoredSections: const ['settings', 'tracker'],
    skippedSections: const ['location'],
    exportedAtUtc: DateTime.utc(2026, 11, 2),
  );

  setUpAll(() => registerFallbackValue(const NoParams()));

  setUp(() {
    exportBackup = MockExportBackup();
    restoreBackup = MockRestoreBackup();
    when(() => exportBackup(any())).thenAnswer((_) async => const Ok(null));
    when(() => restoreBackup(any())).thenAnswer((_) async => Ok(report));
  });

  BackupBloc build() =>
      BackupBloc(exportBackup: exportBackup, restoreBackup: restoreBackup);

  test('starts idle', () {
    expect(build().state, const BackupState());
    expect(build().state.isBusy, isFalse);
  });

  group('export', () {
    blocTest<BackupBloc, BackupState>(
      'shows progress, then done',
      build: build,
      act: (bloc) => bloc.add(const BackupExportRequested()),
      expect: () => const [
        BackupState(status: BackupStatus.exporting),
        BackupState(status: BackupStatus.exported),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'a dismissed share sheet goes quietly back to idle',
      setUp: () => when(
        () => exportBackup(any()),
      ).thenAnswer((_) async => const Err(BackupCancelled())),
      build: build,
      act: (bloc) => bloc.add(const BackupExportRequested()),
      expect: () => const [
        BackupState(status: BackupStatus.exporting),
        BackupState(),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'reports why it failed',
      setUp: () => when(
        () => exportBackup(any()),
      ).thenAnswer((_) async => const Err(BackupFileFailed('write'))),
      build: build,
      act: (bloc) => bloc.add(const BackupExportRequested()),
      expect: () => const [
        BackupState(status: BackupStatus.exporting),
        BackupState(
          status: BackupStatus.exportFailed,
          failure: BackupFileFailed('write'),
        ),
      ],
    );
  });

  group('restore', () {
    blocTest<BackupBloc, BackupState>(
      'shows progress, then what was restored',
      build: build,
      act: (bloc) => bloc.add(const BackupRestoreRequested()),
      expect: () => [
        const BackupState(status: BackupStatus.restoring),
        BackupState(status: BackupStatus.restored, report: report),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'a closed picker goes quietly back to idle',
      setUp: () => when(
        () => restoreBackup(any()),
      ).thenAnswer((_) async => const Err(BackupCancelled())),
      build: build,
      act: (bloc) => bloc.add(const BackupRestoreRequested()),
      expect: () => const [
        BackupState(status: BackupStatus.restoring),
        BackupState(),
      ],
    );

    blocTest<BackupBloc, BackupState>(
      'reports a refused file',
      setUp: () => when(() => restoreBackup(any())).thenAnswer(
        (_) async => const Err(BackupFormatTooNew(found: 2, supported: 1)),
      ),
      build: build,
      act: (bloc) => bloc.add(const BackupRestoreRequested()),
      expect: () => const [
        BackupState(status: BackupStatus.restoring),
        BackupState(
          status: BackupStatus.restoreFailed,
          failure: BackupFormatTooNew(found: 2, supported: 1),
        ),
      ],
    );

    final picking = Completer<Result<RestoreReport, BackupFailure>>();
    blocTest<BackupBloc, BackupState>(
      'ignores taps while one operation runs',
      setUp: () =>
          when(() => restoreBackup(any())).thenAnswer((_) => picking.future),
      build: build,
      act: (bloc) async {
        bloc.add(const BackupRestoreRequested());
        await Future<void>.delayed(Duration.zero);
        bloc
          ..add(const BackupRestoreRequested())
          ..add(const BackupExportRequested());
        await Future<void>.delayed(Duration.zero);
        picking.complete(Ok(report));
      },
      expect: () => [
        const BackupState(status: BackupStatus.restoring),
        BackupState(status: BackupStatus.restored, report: report),
      ],
      verify: (_) {
        verify(() => restoreBackup(any())).called(1);
        verifyNever(() => exportBackup(any()));
      },
    );
  });
}
