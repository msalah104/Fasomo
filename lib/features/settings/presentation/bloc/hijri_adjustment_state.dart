part of 'hijri_adjustment_bloc.dart';

class HijriAdjustmentState extends Equatable {
  const new({required this.offset, required this.today, this.failure});

  /// The offset the Hijri converter applies.
  final HijriOffset offset;

  /// Today's Hijri date with [offset] applied; `null` outside the supported
  /// range.
  final HijriDate? today;

  /// Set when the last choice could not be saved.
  final StorageFailure? failure;

  @override
  List<Object?> get props => [offset, today, failure];
}
