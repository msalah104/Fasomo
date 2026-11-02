import 'package:fasomo/core/calendar/fasting_type.dart';

/// A choice on the "which fasts interest you" step. The three special days
/// are offered together, so each choice maps to one or more [FastingType]s.
enum FastingInterest {
  mondayThursday([FastingType.mondayThursday]),
  whiteDays([FastingType.whiteDays]),
  ramadan([FastingType.ramadan]),
  shawwal([FastingType.shawwal]),
  specialDays([FastingType.arafah, FastingType.ashura, FastingType.tasua]);

  new(this.types);

  /// The fasting types this choice turns reminders on for.
  final List<FastingType> types;

  /// The type whose colour and icon stand for this choice.
  FastingType get representative => types.first;
}
