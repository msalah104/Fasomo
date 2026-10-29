import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/tracker/domain/entities/qada_reminder_settings.dart';

abstract interface class QadaReminderRepository {
  /// The saved settings, or [QadaReminderSettings.defaults] (everything on)
  /// when the user hasn't changed them.
  Result<QadaReminderSettings, StorageFailure> getSettings();

  Future<Result<void, StorageFailure>> saveSettings(
    QadaReminderSettings settings,
  );
}
