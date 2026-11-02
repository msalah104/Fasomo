import 'package:fasomo/core/constants/app_constants.dart';
import 'package:fasomo/core/error/storage_write_exception.dart';
import 'package:fasomo/core/location/location_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads and writes the onboarding flag in shared preferences.
///
/// Throws [FormatException] when the stored flag has the wrong type and
/// [StorageWriteException] when the platform refuses a write; the repository
/// converts both into typed failures.
abstract interface class OnboardingLocalDataSource {
  /// The saved flag: `false` while the flow is under way, `true` once it is
  /// done, `null` when this install never recorded one.
  bool? getCompleted();

  /// Whether a version of the app from before onboarding existed left any
  /// data on this device.
  bool hasDataFromEarlierVersion();

  Future<void> setCompleted({required bool completed});
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  const new({required this.sharedPreferences});

  /// Owned by the onboarding feature, so it lives here rather than in the
  /// shared constants.
  static const String completedKey = 'onboarding_completed';

  /// What earlier versions saved. Every one of them asked for notification
  /// permission on the first launch, so [AppConstants.permissionAskedKey]
  /// alone covers almost every existing install; the rest catch the others.
  static const List<String> earlierVersionKeys = [
    AppConstants.permissionAskedKey,
    AppConstants.remindersKey,
    AppConstants.languageKey,
    AppConstants.themeModeKey,
    AppConstants.hijriOffsetKey,
    AppConstants.notificationToneKey,
    AppConstants.fastLogKey,
    AppConstants.makeUpDaysKey,
    AppConstants.missedRamadanKey,
    AppConstants.extraOwedKey,
    AppConstants.qadaRemindersKey,
    LocationRepositoryImpl.storageKey,
  ];

  final SharedPreferences sharedPreferences;

  @override
  bool? getCompleted() {
    final stored = sharedPreferences.get(completedKey);
    return switch (stored) {
      null => null,
      final bool completed => completed,
      _ => throw FormatException('Not a bool', stored),
    };
  }

  @override
  bool hasDataFromEarlierVersion() =>
      earlierVersionKeys.any(sharedPreferences.containsKey);

  @override
  Future<void> setCompleted({required bool completed}) async {
    final saved = await sharedPreferences.setBool(completedKey, completed);
    if (!saved) throw const StorageWriteException(completedKey);
  }
}
