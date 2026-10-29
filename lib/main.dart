import 'package:fasomo/app/app.dart';
import 'package:fasomo/core/di/injection_container.dart' as di;
import 'package:fasomo/core/services/time_zone_setup.dart';
import 'package:fasomo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Before any notification is scheduled.
  await setUpLocalTimeZone();

  // Before di.init, which wires push messaging.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.init();

  runApp(const FasomoApp());
}
