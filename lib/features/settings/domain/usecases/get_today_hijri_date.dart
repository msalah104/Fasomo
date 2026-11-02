import 'package:clock/clock.dart';
import 'package:fasomo/core/calendar/hijri_converter.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/usecases/usecase.dart';

/// Today's Hijri date as the app currently shows it, with the user's
/// adjustment applied; `null` outside the supported range.
///
/// Lets the adjustment setting preview its effect.
class GetTodayHijriDate implements UseCase<HijriDate?, NoParams> {
  const new({required this.converter, required this.clock});

  final HijriConverter converter;
  final Clock clock;

  @override
  HijriDate? call(NoParams params) {
    final today = clock.now();
    return converter.supportsGregorian(today) ? converter.toHijri(today) : null;
  }
}
