import 'package:clock/clock.dart';
import 'package:fasomo/core/location/location_repository.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/sky_scene.dart';
import 'package:fasomo/features/home/domain/sky_scene_builder.dart';

/// The sky right now over the saved location (or Makkah). Synchronous and
/// cheap, so it runs every minute and on every resume.
class GetSkyScene implements UseCase<SkyScene, NoParams> {
  const new({required this.clock, required this.locationRepository});

  final Clock clock;
  final LocationRepository locationRepository;

  @override
  SkyScene call(NoParams params) =>
      buildSkyScene(clock.now(), locationRepository.current());
}
