import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/repositories/dua_repository.dart';

/// The hadith on the virtue of one kind of fast, or `null` if the collection
/// has none for it.
class GetFastingHadith implements UseCase<Dua?, FastingType> {
  const new(this.repository);

  final DuaRepository repository;

  @override
  Dua? call(FastingType type) {
    for (final dua in repository.getAll()) {
      if (dua.category == DuaCategory.virtue &&
          dua.fastingTypes.contains(type)) {
        return dua;
      }
    }
    return null;
  }
}
