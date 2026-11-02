import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/calendar_days.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/time/minute_ticker.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_overview.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/usecases/get_ramadan_overview.dart';
import 'package:fasomo/features/ramadan/domain/usecases/save_ramadan_checklist.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ramadan_event.dart';
part 'ramadan_state.dart';

/// The Ramadan card on Home: the countdown before Ramadan, and during it
/// today's times, the next suhoor end or iftar and the daily checklist.
///
/// Recomputed every minute while the card can be seen, at once when it is
/// back in view, and on [RamadanRefreshed] (the location, the prayer
/// settings or the Hijri adjustment changed).
class RamadanBloc extends Bloc<RamadanEvent, RamadanState> {
  new({
    required this.getOverview,
    required this.getChecklist,
    required this.saveChecklist,
    required this.ticker,
  }) : super(_load(getOverview, getChecklist, null)) {
    on<RamadanResumed>(_onResumed);
    on<RamadanPaused>(_onPaused);
    on<RamadanTicked>((event, emit) => emit(_reload()));
    on<RamadanRefreshed>((event, emit) => emit(_reload()));
    // Checklist changes are saved in order, so they never overtake.
    on<RamadanChecklistEvent>(_onChecklist, transformer: sequential());
  }

  final GetRamadanOverview getOverview;
  final GetRamadanChecklist getChecklist;
  final SaveRamadanChecklist saveChecklist;
  final MinuteTicker ticker;

  StreamSubscription<void>? _ticks;

  RamadanState _reload() => _load(getOverview, getChecklist, state);

  /// The state for now. The checklist is read again only when the day
  /// changed, so a tick never undoes a change still being saved.
  static RamadanState _load(
    GetRamadanOverview getOverview,
    GetRamadanChecklist getChecklist,
    RamadanState? previous,
  ) {
    final overview = getOverview(const NoParams());
    final day = switch (overview) {
      RamadanDay(:final date) => date,
      RamadanCountdown() || RamadanNotNear() => null,
    };
    if (day == null) return RamadanState(overview: overview);
    final current = previous?.checklist;
    if (previous != null &&
        current != null &&
        CalendarDays.isSameDay(current.date, day)) {
      return previous.copyWith(overview: overview);
    }
    return switch (getChecklist(day)) {
      Ok(:final value) => RamadanState(overview: overview, checklist: value),
      Err(:final failure) => RamadanState(
        overview: overview,
        loadFailure: failure,
      ),
    };
  }

  void _onResumed(RamadanResumed event, Emitter<RamadanState> emit) {
    emit(_reload());
    _ticks ??= ticker.ticks().listen((_) => add(const RamadanTicked()));
  }

  Future<void> _onPaused(
    RamadanPaused event,
    Emitter<RamadanState> emit,
  ) async {
    final ticks = _ticks;
    _ticks = null;
    await ticks?.cancel();
  }

  Future<void> _onChecklist(
    RamadanChecklistEvent event,
    Emitter<RamadanState> emit,
  ) async {
    final before = state.checklist;
    if (before == null) return;
    final after = switch (event) {
      TaraweehToggled() => before.copyWith(
        prayedTaraweeh: !before.prayedTaraweeh,
      ),
      QuranPagesChanged(:final pages) => before.copyWith(quranPages: pages),
    };
    if (after == before) return;
    // Show the change at once; put it back if it can't be kept.
    emit(state.copyWith(checklist: after));
    if (await saveChecklist(after) case Err(:final failure)) {
      emit(state.copyWith(checklist: before, saveFailure: failure));
    }
  }

  @override
  Future<void> close() async {
    await _ticks?.cancel();
    await super.close();
  }
}
