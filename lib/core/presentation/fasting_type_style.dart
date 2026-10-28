import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:flutter/material.dart';

/// The colour and icon used for each [FastingType] across the app. Colour is
/// always paired with the icon so state is never conveyed by colour alone.
extension FastingTypeStyle on FastingType {
  Color get color => switch (this) {
    FastingType.ramadan => Colors.purple,
    FastingType.arafah ||
    FastingType.ashura ||
    FastingType.tasua => Colors.blue,
    FastingType.shawwal => Colors.teal,
    FastingType.whiteDays => Colors.green,
    FastingType.mondayThursday => Colors.orange,
  };

  IconData get icon => switch (this) {
    FastingType.ramadan => Icons.mosque,
    FastingType.arafah => Icons.terrain,
    FastingType.ashura || FastingType.tasua => Icons.favorite,
    FastingType.shawwal => Icons.star,
    FastingType.whiteDays => Icons.brightness_3,
    FastingType.mondayThursday => Icons.calendar_view_week,
  };
}
