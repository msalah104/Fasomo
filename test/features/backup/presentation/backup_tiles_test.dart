import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/backup/backup_service.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/backup/presentation/backup_messages.dart';
import 'package:fasomo/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:fasomo/features/backup/presentation/widgets/backup_tiles.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:fasomo/l10n/generated/app_localizations_ar.dart';
import 'package:fasomo/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBackupBloc extends MockBloc<BackupEvent, BackupState>
    implements BackupBloc;

void main() {
  late MockBackupBloc bloc;

  setUpAll(() => registerFallbackValue(const BackupExportRequested()));

  setUp(() {
    bloc = MockBackupBloc();
    when(() => bloc.state).thenReturn(const BackupState());
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      BlocProvider<BackupBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: BackupTiles()),
        ),
      ),
    );
    // A running progress indicator never settles.
    settle ? await tester.pumpAndSettle() : await tester.pump();
  }

  testWidgets('export starts straight away', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Export backup'));
    verify(() => bloc.add(const BackupExportRequested())).called(1);
  });

  testWidgets('restore asks first, and does nothing when cancelled', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Restore from file'));
    await tester.pumpAndSettle();

    expect(find.text('Restore from a backup?'), findsOneWidget);
    expect(find.textContaining('will be replaced'), findsOneWidget);
    expect(find.textContaining('stays as it is'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Restore from a backup?'), findsNothing);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('restore starts once confirmed', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Restore from file'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();

    expect(find.text('Restore from a backup?'), findsNothing);
    verify(() => bloc.add(const BackupRestoreRequested())).called(1);
  });

  testWidgets('the confirmation reads right to left in Arabic', (
    tester,
  ) async {
    await pump(tester, locale: const Locale('ar'));
    await tester.tap(find.text('الاستعادة من ملف'));
    await tester.pumpAndSettle();
    expect(find.text('الاستعادة من نسخة احتياطية؟'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(AlertDialog))),
      TextDirection.rtl,
    );
  });

  testWidgets('while busy, both tiles are off and progress shows', (
    tester,
  ) async {
    when(
      () => bloc.state,
    ).thenReturn(const BackupState(status: BackupStatus.restoring));
    await pump(tester, settle: false);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .semanticsLabel,
      'Working on the backup…',
    );
    await tester.tap(find.text('Export backup'));
    await tester.tap(find.text('Restore from file'));
    await tester.pump();
    expect(find.text('Restore from a backup?'), findsNothing);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('shows why a restore failed', (tester) async {
    whenListen(
      bloc,
      Stream.fromIterable(const [
        BackupState(status: BackupStatus.restoring),
        BackupState(
          status: BackupStatus.restoreFailed,
          failure: BackupChecksumMismatch(),
        ),
      ]),
      initialState: const BackupState(),
    );
    await pump(tester);
    expect(
      find.text(
        'This backup was changed or damaged after it was made. '
        'Nothing was changed.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says nothing when the user cancelled', (tester) async {
    whenListen(
      bloc,
      Stream.fromIterable(const [
        BackupState(status: BackupStatus.restoring),
        BackupState(),
      ]),
      initialState: const BackupState(),
    );
    await pump(tester);
    expect(find.byType(SnackBar), findsNothing);
  });

  group('messages', () {
    final en = AppLocalizationsEn();
    final ar = AppLocalizationsAr();

    BackupState failed(BackupFailure failure, {bool restoring = true}) =>
        BackupState(
          status: restoring
              ? BackupStatus.restoreFailed
              : BackupStatus.exportFailed,
          failure: failure,
        );

    test('every refusal has its own message', () {
      final messages = [
        for (final failure in const <BackupFailure>[
          BackupFormatTooNew(found: 2, supported: 1),
          BackupMalformed(),
          BackupChecksumMismatch(),
          BackupStorageFailed('tracker'),
          BackupFileFailed('read'),
        ])
          backupMessage(en, failed(failure)),
      ];
      expect(messages, everyElement(isNotNull));
      expect(messages.toSet(), hasLength(messages.length));
      expect(messages.first, contains('newer version'));
    });

    test('cancelling is silent, for export and restore', () {
      expect(backupMessage(en, failed(const BackupCancelled())), isNull);
      expect(
        backupMessage(en, failed(const BackupCancelled(), restoring: false)),
        isNull,
      );
      expect(backupMessage(en, const BackupState()), isNull);
    });

    test('a restore that skipped newer sections says so', () {
      final report = RestoreReport(
        restoredSections: const ['settings'],
        skippedSections: const ['location'],
        exportedAtUtc: DateTime.utc(2026),
      );
      expect(
        backupMessage(
          ar,
          BackupState(status: BackupStatus.restored, report: report),
        ),
        ar.backupRestoredWithSkipped,
      );
    });
  });
}
