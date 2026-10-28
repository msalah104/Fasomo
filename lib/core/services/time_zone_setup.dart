import 'package:fasomo/core/logging/app_log.dart';
import 'package:flutter/services.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Loads the time-zone database and points `tz.local` at the device zone.
/// `timezone` defaults to UTC, which would fire every reminder at the wrong
/// local hour.
Future<void> setUpLocalTimeZone() async {
  tz_data.initializeTimeZones();
  try {
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
  } on PlatformException catch (e, st) {
    AppLog.error('timezone.lookup', e, st);
  } on tz.LocationNotFoundException catch (e, st) {
    AppLog.error('timezone.unknown', e, st);
  }
}
