import 'package:fasomo/core/backup/backup_section.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/location/location_repository_impl.dart';

/// The saved location in a backup, `null` while the sky uses the approximate
/// fallback:
///
/// ```json
/// "location": {"saved": {"latitude": 30.04, "longitude": 31.24,
///              "source": "manual", "city": "EG:Cairo"}}
/// ```
final class LocationBackupSection implements BackupSection {
  const new(this.repository);

  final LocationRepository repository;

  @override
  String get id => 'location';

  @override
  Set<String> get storageKeys => const {LocationRepositoryImpl.storageKey};

  @override
  Result<Map<String, Object?>, BackupFailure> export() => Ok({
    'saved': switch (repository.saved()) {
      null => null,
      final point => {
        'latitude': point.latitude,
        'longitude': point.longitude,
        'source': point.source.name,
        if (point.city case final city?) 'city': city.id,
      },
    },
  });

  @override
  Result<void, BackupFailure> validate(Map<String, Object?> json) =>
      _decode(json) == null
      ? Err(BackupMalformed(sectionId: id))
      : const Ok(null);

  @override
  Future<Result<void, BackupFailure>> restore(Map<String, Object?> json) async {
    final decoded = _decode(json);
    if (decoded == null) return Err(BackupMalformed(sectionId: id));
    final written = await repository.replaceSaved(decoded.point);
    return written ? const Ok(null) : Err(BackupStorageFailed(id));
  }

  /// The point in [json] (itself possibly `null`), or `null` when [json] is
  /// not a valid location section.
  static ({GeoPoint? point})? _decode(Map<String, Object?> json) {
    if (!json.containsKey('saved')) return null;
    return switch (json['saved']) {
      null => (point: null),
      {
                'latitude': final num latitude,
                'longitude': final num longitude,
                'source': final String sourceName,
              } &&
              final Map<String, Object?> saved
          when latitude.abs() <= 90 && longitude.abs() <= 180 =>
        switch (_sourceNamed(sourceName)) {
          null => null,
          final source => (
            point: GeoPoint(
              latitude: latitude.toDouble(),
              longitude: longitude.toDouble(),
              source: source,
              city: switch (saved['city']) {
                final String cityId => CityCatalog.byId(cityId),
                _ => null,
              },
            ),
          ),
        },
      _ => null,
    };
  }

  /// Only a location the user set can be saved; the fallback never is.
  static LocationSource? _sourceNamed(String name) => switch (name) {
    'device' => LocationSource.device,
    'manual' => LocationSource.manual,
    _ => null,
  };
}
