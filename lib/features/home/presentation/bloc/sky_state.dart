part of 'sky_bloc.dart';

/// What the Home sky shows. There is always a [scene]: it is computed
/// synchronously, so the first frame already has the real sky.
final class SkyState extends Equatable {
  const new({
    required this.scene,
    this.isLocating = false,
    this.locationFailure,
  });

  final SkyScene scene;

  /// Whether a device fix is being fetched.
  final bool isLocating;

  /// Why the last device fix failed. Transient: cleared by the next change.
  final LocationFailure? locationFailure;

  SkyState copyWith({
    SkyScene? scene,
    bool? isLocating,
    LocationFailure? locationFailure,
  }) {
    return SkyState(
      scene: scene ?? this.scene,
      isLocating: isLocating ?? this.isLocating,
      locationFailure: locationFailure,
    );
  }

  @override
  List<Object?> get props => [scene, isLocating, locationFailure];
}
