import 'package:fasomo/app/app.dart';
import 'package:fasomo/core/di/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Time zone data for scheduled notifications.
  tz.initializeTimeZones();

  await di.init();

  runApp(const FasomoApp());
}
