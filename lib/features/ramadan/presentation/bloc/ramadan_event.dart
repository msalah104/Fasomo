part of 'ramadan_bloc.dart';

sealed class RamadanEvent extends Equatable {
  const new();

  @override
  List<Object> get props => [];
}

/// The card is in view: recompute now and then every minute.
final class RamadanResumed extends RamadanEvent {
  const new();
}

/// The card went out of view: stop the minute ticks.
final class RamadanPaused extends RamadanEvent {
  const new();
}

/// A new minute began.
final class RamadanTicked extends RamadanEvent {
  const new();
}

/// Something the times depend on changed: the location, the prayer
/// settings or the Hijri adjustment.
final class RamadanRefreshed extends RamadanEvent {
  const new();
}

/// A change to today's checklist.
sealed class RamadanChecklistEvent extends RamadanEvent {
  const new();
}

/// Ticks Taraweeh for today, or clears it.
final class TaraweehToggled extends RamadanChecklistEvent {
  const new();
}

/// Sets today's Quran pages (clamped to 0..604).
final class QuranPagesChanged extends RamadanChecklistEvent {
  const new(this.pages);

  final int pages;

  @override
  List<Object> get props => [pages];
}
