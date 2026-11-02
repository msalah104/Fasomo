import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/usecases/get_duas.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'duas_event.dart';
part 'duas_state.dart';

/// The Duas page: the bundled texts, optionally narrowed to one fast.
class DuasBloc extends Bloc<DuasEvent, DuasState> {
  new({required this.getDuas}) : super(const DuasState()) {
    on<DuasFilterChanged>(_onFilterChanged);
  }

  final GetDuas getDuas;

  void _onFilterChanged(DuasFilterChanged event, Emitter<DuasState> emit) {
    emit(
      state.copyWith(
        status: DuasStatus.ready,
        filter: () => event.filter,
        duas: getDuas(event.filter),
      ),
    );
  }
}
