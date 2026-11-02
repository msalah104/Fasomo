import 'package:equatable/equatable.dart';

/// The suhoor and iftar reminders: whether each is on, how long before Fajr
/// or Maghrib it fires, and whether it also runs on voluntary fasting days.
final class SuhoorIftarSettings extends Equatable {
  const new({
    this.suhoorEnabled = true,
    this.suhoorMinutesBeforeFajr = 45,
    this.iftarEnabled = true,
    this.iftarMinutesBeforeMaghrib = 0,
    this.onOtherFastingDays = false,
  });

  /// Both on in Ramadan: suhoor 45 minutes before Fajr, iftar at Maghrib.
  static const defaults = SuhoorIftarSettings();

  /// The lead times offered before Fajr.
  static const suhoorOptions = [15, 30, 45, 60, 90];

  /// The lead times offered before Maghrib; 0 is at Maghrib.
  static const iftarOptions = [0, 5, 10, 15];

  final bool suhoorEnabled;

  /// One of [suhoorOptions].
  final int suhoorMinutesBeforeFajr;
  final bool iftarEnabled;

  /// One of [iftarOptions].
  final int iftarMinutesBeforeMaghrib;

  /// Whether they also fire on every recommended fasting day, not only in
  /// Ramadan.
  final bool onOtherFastingDays;

  bool get anyEnabled => suhoorEnabled || iftarEnabled;

  SuhoorIftarSettings copyWith({
    bool? suhoorEnabled,
    int? suhoorMinutesBeforeFajr,
    bool? iftarEnabled,
    int? iftarMinutesBeforeMaghrib,
    bool? onOtherFastingDays,
  }) => SuhoorIftarSettings(
    suhoorEnabled: suhoorEnabled ?? this.suhoorEnabled,
    suhoorMinutesBeforeFajr:
        suhoorMinutesBeforeFajr ?? this.suhoorMinutesBeforeFajr,
    iftarEnabled: iftarEnabled ?? this.iftarEnabled,
    iftarMinutesBeforeMaghrib:
        iftarMinutesBeforeMaghrib ?? this.iftarMinutesBeforeMaghrib,
    onOtherFastingDays: onOtherFastingDays ?? this.onOtherFastingDays,
  );

  @override
  List<Object> get props => [
    suhoorEnabled,
    suhoorMinutesBeforeFajr,
    iftarEnabled,
    iftarMinutesBeforeMaghrib,
    onOtherFastingDays,
  ];
}
