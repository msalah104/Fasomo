import 'package:fasomo/app/app.dart';
import 'package:fasomo/app/app_shell.dart';
import 'package:fasomo/core/backup/backup_envelope.dart';
import 'package:fasomo/core/backup/backup_file_gateway.dart';
import 'package:fasomo/core/di/injection_container.dart' as di;
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/notifications/notification_gateway.dart';
import 'package:fasomo/core/notifications/notification_tone.dart';
import 'package:fasomo/features/reminders/presentation/bloc/notification_tone_bloc.dart';
import 'package:fasomo/features/settings/presentation/bloc/theme_bloc.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';
import 'package:fasomo/features/tracker/presentation/bloc/tracker_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_backup_file_gateway.dart';
import '../helpers/fake_home_widget_gateway.dart';
import '../helpers/fake_notification_gateway.dart';
import '../helpers/fake_push_messaging.dart';

class _GrantedPermission implements NotificationPermission {
  @override
  Future<bool> request() async => true;
}

/// A backup from another phone: Arabic, dark, the bell, and a fasted day.
String _backupFromAnotherPhone() => BackupEnvelope(
  formatVersion: BackupEnvelope.currentFormatVersion,
  appVersion: '1.0.0',
  exportedAtUtc: DateTime.utc(2026, 10, 30),
  sections: {
    'settings': {
      'language': 'arabic',
      'themeMode': 'dark',
      'hijriOffsetDays': 0,
    },
    'reminders': {'notificationTone': 'bell', 'reminders': <Object>[]},
    'tracker': {
      'fastedDays': ['2026-10-20'],
      'makeUpDays': <String>[],
      'missedRamadanDays': <String>[],
      'extraOwed': <Object>[],
      'qadaReminders': QadaReminderSettings.defaults.toJson(),
    },
  },
).encode();

void main() {
  testWidgets(
    'restoring from settings applies the language and theme at once and '
    'reloads the data',
    (tester) async {
      tester.view
        ..physicalSize = const Size(390, 844) * 2
        ..devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'language': 'english'});
      await di.sl.reset();
      final notifications = FakeNotificationGateway();
      await tester.runAsync(
        () => di.init(
          platform: di.PlatformServices(
            notifications: notifications,
            notificationPermission: _GrantedPermission(),
            tonePreview: notifications,
            push: FakePushMessaging(),
            homeWidget: FakeHomeWidgetGateway(),
          ),
        ),
      );
      final files = FakeBackupFileGateway()
        ..pickResult = Ok(_backupFromAnotherPhone());
      di.sl
        ..unregister<BackupFileGateway>()
        ..registerSingleton<BackupFileGateway>(files);

      await tester.pumpWidget(const FasomoApp());
      // Skip the splash.
      await tester.pump(const Duration(seconds: 1));
      await tester.tapAt(const Offset(195, 422));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      await tester.tap(find.byIcon(Icons.settings_outlined).first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Restore from file'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore from file'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose file'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(files.pickCount, 1);
      // The settings page is now in Arabic and dark.
      expect(find.text('الإعدادات'), findsWidgets);
      final context = tester.element(
        find.byType(AppShell, skipOffstage: false),
      );
      expect(Theme.of(context).brightness, Brightness.dark);
      expect(
        context.read<ThemeBloc>().state.themeMode,
        ThemeMode.dark,
      );
      expect(
        context.read<NotificationToneBloc>().state.tone,
        NotificationTone.bell,
      );
      expect(
        context.read<TrackerBloc>().state.isFasted(DateTime(2026, 10, 20)),
        isTrue,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    },
  );
}
