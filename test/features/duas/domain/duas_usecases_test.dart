import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/duas/data/repositories/dua_repository_impl.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/entities/hadith_reference.dart';
import 'package:fasomo/features/duas/domain/repositories/dua_repository.dart';
import 'package:fasomo/features/duas/domain/usecases/get_duas.dart';
import 'package:fasomo/features/duas/domain/usecases/get_fasting_hadith.dart';
import 'package:flutter_test/flutter_test.dart';

class _EmptyRepository implements DuaRepository {
  @override
  List<Dua> getAll() => const [];
}

void main() {
  const repository = DuaRepositoryImpl();

  group('GetDuas', () {
    const getDuas = GetDuas(repository);

    test('with no filter returns everything in order', () {
      expect(getDuas(null), repository.getAll());
    });

    test('for Arafah keeps the general duas and the Arafah hadith', () {
      final ids = getDuas(FastingType.arafah).map((dua) => dua.id);
      expect(ids, [
        DuaId.intention,
        DuaId.iftar,
        DuaId.iftarAsGuest,
        DuaId.arafahVirtue,
      ]);
    });

    test('for Ramadan adds the Laylat al-Qadr dua', () {
      final ids = getDuas(FastingType.ramadan).map((dua) => dua.id);
      expect(ids, contains(DuaId.laylatAlQadr));
      expect(ids, contains(DuaId.ramadanVirtue));
      expect(ids, isNot(contains(DuaId.shawwalVirtue)));
    });
  });

  group('GetFastingHadith', () {
    test('finds the hadith of each kind of fast', () {
      const getHadith = GetFastingHadith(repository);
      final arafah = getHadith(FastingType.arafah);
      expect(arafah?.id, DuaId.arafahVirtue);
      expect(arafah?.sources, const [
        HadithReference(HadithCollection.muslim, 1162),
      ]);
      for (final type in FastingType.values) {
        expect(getHadith(type), isNotNull, reason: '$type');
      }
    });

    test('is null when the collection has none', () {
      expect(GetFastingHadith(_EmptyRepository())(FastingType.ashura), isNull);
    });
  });
}
