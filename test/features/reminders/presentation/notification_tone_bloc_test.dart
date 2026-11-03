import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/reminders/domain/usecases/get_notification_tone.dart';
import 'package:fasomo/features/reminders/domain/usecases/save_notification_tone.dart';
import 'package:fasomo/features/reminders/presentation/bloc/notification_tone_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_notification_gateway.dart';

class MockGetNotificationTone extends Mock implements GetNotificationTone;

class MockSaveNotificationTone extends Mock implements SaveNotificationTone;

class MockNotificationPermission extends Mock implements NotificationPermission;

void main() {
  late MockGetNotificationTone getTone;
  late MockSaveNotificationTone saveTone;
  late MockNotificationPermission permission;
  late FakeNotificationGateway preview;

  const writeFailed = StorageWriteFailed('notification_tone');
  const previewFailed = NotificationPlatformFailed('preview');

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(NotificationTone.systemDefault);
  });

  setUp(() {
    getTone = MockGetNotificationTone();
    saveTone = MockSaveNotificationTone();
    permission = MockNotificationPermission();
    preview = FakeNotificationGateway();
    when(() => getTone(any())).thenReturn(const Ok(NotificationTone.bell));
    when(() => saveTone(any())).thenAnswer((_) async => const Ok(null));
    when(() => permission.request()).thenAnswer((_) async => true);
  });

  NotificationToneBloc build() => NotificationToneBloc(
    getNotificationTone: getTone,
    saveNotificationTone: saveTone,
    permission: permission,
    tonePreview: preview,
  );

  const previewChime = NotificationTonePreviewRequested(
    NotificationTone.softChime,
    title: 'This is how reminders will sound',
    body: 'Reminder sound: Soft chime',
  );

  test('starts from the saved tone, before any event', () {
    expect(
      build().state,
      const NotificationToneState(tone: NotificationTone.bell),
    );
  });

  test('starts from the system default when the saved tone is unreadable', () {
    when(
      () => getTone(any()),
    ).thenReturn(const Err(StorageReadFailed('notification_tone')));
    expect(build().state.tone, NotificationTone.systemDefault);
  });

  blocTest<NotificationToneBloc, NotificationToneState>(
    'a new tone is saved, then shown',
    build: build,
    act: (bloc) =>
        bloc.add(const NotificationToneChanged(NotificationTone.vibrateOnly)),
    expect: () => [
      const NotificationToneState(tone: NotificationTone.vibrateOnly),
    ],
    verify: (_) =>
        verify(() => saveTone(NotificationTone.vibrateOnly)).called(1),
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'choosing the current tone again saves nothing',
    build: build,
    act: (bloc) =>
        bloc.add(const NotificationToneChanged(NotificationTone.bell)),
    expect: () => <NotificationToneState>[],
    verify: (_) => verifyNever(() => saveTone(any())),
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'a failed save keeps the old tone, so the reminders keep matching it',
    setUp: () => when(
      () => saveTone(any()),
    ).thenAnswer((_) async => const Err(writeFailed)),
    build: build,
    act: (bloc) =>
        bloc.add(const NotificationToneChanged(NotificationTone.gentle)),
    expect: () => [
      const NotificationToneState(
        tone: NotificationTone.bell,
        failure: writeFailed,
      ),
    ],
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'the same failure twice is reported twice',
    setUp: () => when(
      () => saveTone(any()),
    ).thenAnswer((_) async => const Err(writeFailed)),
    build: build,
    act: (bloc) => bloc
      ..add(const NotificationToneChanged(NotificationTone.gentle))
      ..add(const NotificationToneChanged(NotificationTone.gentle)),
    expect: () => [
      const NotificationToneState(
        tone: NotificationTone.bell,
        failure: writeFailed,
      ),
      const NotificationToneState(tone: NotificationTone.bell),
      const NotificationToneState(
        tone: NotificationTone.bell,
        failure: writeFailed,
      ),
    ],
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'a preview plays the tone without choosing it',
    build: build,
    act: (bloc) => bloc.add(previewChime),
    expect: () => <NotificationToneState>[],
    verify: (bloc) {
      expect(preview.previewed, [NotificationTone.softChime]);
      expect(bloc.state.tone, NotificationTone.bell);
      verifyNever(() => saveTone(any()));
    },
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'a preview without notification permission says so and plays nothing',
    setUp: () =>
        when(() => permission.request()).thenAnswer((_) async => false),
    build: build,
    act: (bloc) => bloc.add(previewChime),
    expect: () => [
      const NotificationToneState(
        tone: NotificationTone.bell,
        permissionDenied: true,
      ),
    ],
    verify: (_) => expect(preview.previewed, isEmpty),
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'a preview the platform rejects reports the failure',
    setUp: () => preview.failWith = previewFailed,
    build: build,
    act: (bloc) => bloc.add(previewChime),
    expect: () => [
      const NotificationToneState(
        tone: NotificationTone.bell,
        failure: previewFailed,
      ),
    ],
  );

  blocTest<NotificationToneBloc, NotificationToneState>(
    'NotificationToneReloaded reads the saved tone again',
    build: build,
    setUp: () => when(
      () => getTone(any()),
    ).thenReturn(const Ok(NotificationTone.gentle)),
    act: (bloc) => bloc.add(const NotificationToneReloaded()),
    expect: () => [const NotificationToneState(tone: NotificationTone.gentle)],
    verify: (_) => verifyNever(() => saveTone(any())),
  );
}
