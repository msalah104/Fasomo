part of 'hijri_adjustment_bloc.dart';

sealed class HijriAdjustmentEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The user picked [offset]; it is saved and applied.
final class HijriOffsetChanged extends HijriAdjustmentEvent {
  const new(this.offset);

  final HijriOffset offset;

  @override
  List<Object> get props => [offset];
}

/// Recomputes today's preview, e.g. when the settings page opens and
/// "today" may have moved on.
final class HijriPreviewRefreshed extends HijriAdjustmentEvent {
  const new();
}

/// The saved offset may have changed outside this bloc, e.g. by a restore:
/// read it again, as the converter already does.
final class HijriOffsetReloaded extends HijriAdjustmentEvent {
  const new();
}
