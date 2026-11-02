import 'package:bloc_test/bloc_test.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/duas/data/repositories/dua_repository_impl.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/usecases/get_duas.dart';
import 'package:fasomo/features/duas/presentation/bloc/duas_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const getDuas = GetDuas(DuaRepositoryImpl());

  blocTest<DuasBloc, DuasState>(
    'opens narrowed to a fast, then widens to everything',
    build: () => DuasBloc(getDuas: getDuas),
    act: (bloc) => bloc
      ..add(const DuasFilterChanged(FastingType.arafah))
      ..add(const DuasFilterChanged(null)),
    expect: () => [
      DuasState(
        status: DuasStatus.ready,
        filter: FastingType.arafah,
        duas: getDuas(FastingType.arafah),
      ),
      DuasState(status: DuasStatus.ready, duas: getDuas(null)),
    ],
  );

  test('groups the texts into sections in display order', () {
    final state = DuasState(
      status: DuasStatus.ready,
      duas: getDuas(FastingType.arafah),
    );
    expect(state.sections.map((section) => section.category), [
      DuaCategory.intention,
      DuaCategory.breakingTheFast,
      DuaCategory.virtue,
    ]);
    expect(state.sections[1].duas.map((dua) => dua.id), [
      DuaId.iftar,
      DuaId.iftarAsGuest,
    ]);
  });
}
