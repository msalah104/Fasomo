import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/location/location_backup_section.dart';
import 'package:fasomo/core/location/location_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_device_location_gateway.dart';

void main() {
  final cairo = CityCatalog.byId('EG:Cairo')!;

  Future<LocationRepositoryImpl> repository() async => LocationRepositoryImpl(
    sharedPreferences: await SharedPreferences.getInstance(),
    gateway: FakeDeviceLocationGateway(),
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('exports nothing while the sky uses the fallback', () async {
    final section = LocationBackupSection(await repository());
    final exported = switch (section.export()) {
      Ok(:final value) => value,
      Err() => fail('export failed'),
    };
    expect(exported, {'saved': null});
  });

  test('a chosen city survives export and restore on another phone', () async {
    final phone = await repository();
    await phone.chooseCity(cairo);
    final exported = switch (LocationBackupSection(phone).export()) {
      Ok(:final value) => value,
      Err() => fail('export failed'),
    };

    SharedPreferences.setMockInitialValues({});
    final newPhone = await repository();
    final section = LocationBackupSection(newPhone);
    expect(section.validate(exported), const Ok<void, BackupFailure>(null));
    expect(
      await section.restore(exported),
      const Ok<void, BackupFailure>(null),
    );

    expect(newPhone.current().city, cairo);
    expect(newPhone.current().source, LocationSource.manual);
    // And from storage, as after a restart.
    expect((await repository()).current().city, cairo);
  });

  test('restoring "no location" forgets the saved one', () async {
    final repo = await repository();
    await repo.chooseCity(cairo);

    final result = await LocationBackupSection(repo).restore({'saved': null});

    expect(result, isA<Ok<void, BackupFailure>>());
    expect(repo.current(), GeoPoint.makkah);
    expect((await repository()).current(), GeoPoint.makkah);
  });

  test('rejects malformed sections without writing', () async {
    final repo = await repository();
    await repo.chooseCity(cairo);
    final section = LocationBackupSection(repo);

    for (final bad in <Map<String, Object?>>[
      {},
      {'saved': 'Cairo'},
      {
        'saved': {'latitude': 91, 'longitude': 0, 'source': 'manual'},
      },
      {
        'saved': {'latitude': 30, 'longitude': 31, 'source': 'fallback'},
      },
    ]) {
      expect(section.validate(bad), isA<Err<void, BackupFailure>>());
      expect(await section.restore(bad), isA<Err<void, BackupFailure>>());
    }
    expect(repo.current().city, cairo);
  });
}
