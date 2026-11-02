import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/repositories/dua_repository.dart';

/// The texts for one kind of fast, or all of them when the filter is `null`.
/// Texts for every fast (the intention, the iftar duas) are always included.
class GetDuas implements UseCase<List<Dua>, FastingType?> {
  const new(this.repository);

  final DuaRepository repository;

  @override
  List<Dua> call(FastingType? type) => [
    for (final dua in repository.getAll())
      if (type == null || dua.appliesTo(type)) dua,
  ];
}
