part of 'sky_bloc.dart';

class SkyState extends Equatable {
  const new({this.scene, this.isLocating = false, this.failure});

  /// `null` until the first computation.
  final SkyScene? scene;

  /// A device fix is being fetched.
  final bool isLocating;

  /// Why the last location request failed. Describes one emission only; the
  /// sky keeps its previous location.
  final LocationFailure? failure;

  @override
  List<Object?> get props => [scene, isLocating, failure];
}
