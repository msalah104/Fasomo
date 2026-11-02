import 'package:fasomo/core/backup/backup_snapshot_store.dart';
import 'package:fasomo/core/logging/app_log.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [BackupSnapshotStore] on [SharedPreferences], where every feature keeps
/// its data.
final class PreferencesSnapshotStore implements BackupSnapshotStore {
  const new(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  @override
  Map<String, Object?> capture(Set<String> keys) => {
    for (final key in keys) key: _copy(sharedPreferences.get(key)),
  };

  @override
  Future<bool> putBack(Map<String, Object?> snapshot) async {
    var restored = true;
    for (final MapEntry(:key, :value) in snapshot.entries) {
      try {
        final ok = switch (value) {
          null => await sharedPreferences.remove(key),
          final bool flag => await sharedPreferences.setBool(key, flag),
          final int number => await sharedPreferences.setInt(key, number),
          final double number => await sharedPreferences.setDouble(key, number),
          final String text => await sharedPreferences.setString(key, text),
          final List<Object?> list => await sharedPreferences.setStringList(
            key,
            list.whereType<String>().toList(),
          ),
          _ => false,
        };
        restored = restored && ok;
      } on PlatformException catch (e, st) {
        AppLog.error('backup.rollback.$key', e, st);
        restored = false;
      }
    }
    return restored;
  }

  /// A copy of a string list, so later writes cannot change the snapshot.
  static Object? _copy(Object? value) =>
      value is List<Object?> ? value.whereType<String>().toList() : value;
}
