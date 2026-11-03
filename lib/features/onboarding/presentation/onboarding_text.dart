import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/location/geo_point.dart';
import 'package:fasomo/core/notifications/reminder_timing.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/features/onboarding/domain/entities/fasting_interest.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Localized onboarding text. Values become strings only here.
extension OnboardingText on AppLocalizations {
  /// The chip label for [interest].
  String fastingInterestLabel(FastingInterest interest) => switch (interest) {
    FastingInterest.specialDays => onboardingSpecialDays,
    FastingInterest.mondayThursday ||
    FastingInterest.whiteDays ||
    FastingInterest.ramadan ||
    FastingInterest.shawwal => fastingTypeTitle(interest.representative),
  };

  /// "Location set: Cairo", or "Location set: My location" for a fix with
  /// no listed city nearby.
  String locationSetLabel(GeoPoint location) => onboardingLocationSet(
    location.city?.nameFor(localeName) ?? locationMyLocation,
  );

  /// Why the device location could not be used, and what to do instead.
  String locationFailureMessage(LocationFailure failure) => switch (failure) {
    LocationPermissionDenied(permanently: true) => locationDeniedForever,
    LocationPermissionDenied() => locationDenied,
    LocationServiceDisabled() => locationServiceOff,
    LocationUnavailable() => locationUnavailable,
  };

  /// "Day Before · at 9:00 PM", in the clock format of [context].
  String reminderTimingLabel(BuildContext context, ReminderTiming timing) {
    final day = timing.daysBefore == 0 ? sameDay : dayBefore;
    return '$day · ${atTime(wallClockLabel(context, timing.time))}';
  }
}

/// [time] as the device shows times: "9:00 PM" or "21:00".
String wallClockLabel(BuildContext context, WallClockTime time) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: time.hour, minute: time.minute),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
