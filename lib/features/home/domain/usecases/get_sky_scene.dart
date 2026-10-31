import 'package:clock/clock.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/services/sky_calculator.dart';

/// The sky right now over the user's location. Cheap and pure apart from
/// reading the clock and the saved location, so it can run every minute.
class GetSkyScene implements UseCase<SkyScene, NoParams> {
  const new({
    required this.location,
    required this.calculator,
    required this.clock,
  });

  final LocationRepository location;
  final SkyCalculator calculator;
  final Clock clock;

  @override
  SkyScene call(NoParams params) {
    final now = clock.now();
    final at = location.current();
    return SkyScene(
      now: now,
      location: at,
      sun: calculator.sun(now, at),
      moon: calculator.moon(now, at),
      moonPhase: calculator.moonPhase(now),
    );
  }
}
