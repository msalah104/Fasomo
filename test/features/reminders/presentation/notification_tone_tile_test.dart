import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/reminders/presentation/bloc/notification_tone_bloc.dart';
import 'package:fasomo/features/reminders/presentation/widgets/notification_tone_tile.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationToneBloc
    extends MockBloc<NotificationToneEvent, NotificationToneState>
    implements NotificationToneBloc;

void main() {
  late MockNotificationToneBloc bloc;

  setUpAll(() {
    registerFallbackValue(
      const NotificationToneChanged(NotificationTone.systemDefault),
    );
  });

  setUp(() {
    bloc = MockNotificationToneBloc();
    when(
      () => bloc.state,
    ).thenReturn(const NotificationToneState(tone: NotificationTone.bell));
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    TargetPlatform platform = TargetPlatform.android,
  }) async {
    await tester.pumpWidget(
      BlocProvider<NotificationToneBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: buildAppTheme(Brightness.light).copyWith(platform: platform),
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const Scaffold(body: NotificationToneTile()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the current sound', (tester) async {
    await pump(tester);
    expect(find.text('Reminder sound'), findsOneWidget);
    expect(find.text('Bell'), findsOneWidget);
  });

  testWidgets('the picker lists every sound with the current one ticked, '
      'and choosing one sends it', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Reminder sound'));
    await tester.pumpAndSettle();

    for (final name in [
      'System default',
      'Soft chime',
      'Bell',
      'Gentle',
      'Vibrate only',
    ]) {
      expect(
        find.descendant(of: find.byType(Dialog), matching: find.text(name)),
        findsOneWidget,
      );
    }
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Bell').last,
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Gentle'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
    verify(
      () => bloc.add(const NotificationToneChanged(NotificationTone.gentle)),
    ).called(1);
  });

  testWidgets('the play button previews a sound without choosing it', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Reminder sound'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Try Soft chime'));
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(
        const NotificationTonePreviewRequested(
          NotificationTone.softChime,
          title: 'This is how reminders will sound',
          body: 'Reminder sound: Soft chime',
        ),
      ),
    ).called(1);
    verifyNever(() => bloc.add(any(that: isA<NotificationToneChanged>())));
    expect(find.byType(Dialog), findsOneWidget);
  });

  testWidgets('says when a choice could not be saved', (tester) async {
    whenListen(
      bloc,
      Stream.value(
        const NotificationToneState(
          tone: NotificationTone.bell,
          failure: StorageWriteFailed('notification_tone'),
        ),
      ),
      initialState: const NotificationToneState(tone: NotificationTone.bell),
    );
    await pump(tester);
    expect(
      find.text(
        'Could not save this setting. It applies until the app is closed.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says when a preview could not be played', (tester) async {
    whenListen(
      bloc,
      Stream.value(
        const NotificationToneState(
          tone: NotificationTone.bell,
          failure: NotificationPlatformFailed('preview'),
        ),
      ),
      initialState: const NotificationToneState(tone: NotificationTone.bell),
    );
    await pump(tester);
    expect(find.text('Could not play the sound.'), findsOneWidget);
  });

  testWidgets('vibrate only is honestly called silent on iOS', (tester) async {
    when(() => bloc.state).thenReturn(
      const NotificationToneState(tone: NotificationTone.vibrateOnly),
    );
    await pump(tester, platform: TargetPlatform.iOS);
    expect(find.text('Silent'), findsOneWidget);
  });

  testWidgets('reads right to left in Arabic', (tester) async {
    await pump(tester, locale: const Locale('ar'));
    expect(find.text('صوت التذكير'), findsOneWidget);
    expect(find.text('جرس'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.byType(ListTile))),
      TextDirection.rtl,
    );
  });
}
