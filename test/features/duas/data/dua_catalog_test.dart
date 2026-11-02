import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/duas/data/datasources/dua_catalog.dart';
import 'package:fasomo/features/duas/data/repositories/dua_repository_impl.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const all = DuaCatalog.all;

  test('the repository serves the bundled catalog', () {
    expect(const DuaRepositoryImpl().getAll(), same(all));
  });

  test('every text appears once, with a source', () {
    expect(all.map((dua) => dua.id).toSet(), DuaId.values.toSet());
    expect(all, hasLength(DuaId.values.length));
    for (final dua in all) {
      expect(dua.sources, isNotEmpty, reason: '${dua.id}');
      expect(dua.translation.trim(), isNotEmpty, reason: '${dua.id}');
    }
  });

  test('the Arabic is Arabic script only, with tashkeel', () {
    // Arabic letters, harakat, Arabic punctuation and spaces; no Latin or
    // digits slipped into the original text.
    final arabicOnly = RegExp(r'^[؀-ۿ\s،]+$');
    final harakat = RegExp('[ً-ْ]');
    for (final dua in all) {
      expect(dua.arabic, matches(arabicOnly), reason: '${dua.id}');
      expect(dua.arabic, contains(harakat), reason: '${dua.id}');
    }
  });

  test('every kind of fast has exactly one hadith on its virtue', () {
    for (final type in FastingType.values) {
      final virtues = all.where(
        (dua) =>
            dua.category == DuaCategory.virtue &&
            dua.fastingTypes.contains(type),
      );
      expect(virtues, hasLength(1), reason: '$type');
    }
  });

  test('transliterations use only letters the bundled fonts draw', () {
    final drawable = RegExp(r"^[A-Za-z ,.'\-āīūĀĪŪ]+$");
    for (final dua in all) {
      if (dua.transliteration case final text?) {
        expect(text, matches(drawable), reason: '${dua.id}');
      }
    }
  });

  test('the duas meant to be recited have a transliteration', () {
    for (final id in [DuaId.iftar, DuaId.iftarAsGuest, DuaId.laylatAlQadr]) {
      final dua = all.singleWhere((dua) => dua.id == id);
      expect(dua.transliteration, isNotNull, reason: '$id');
    }
  });

  test('texts are listed section by section', () {
    final categories = all.map((dua) => dua.category.index).toList();
    expect(categories, orderedEquals([...categories]..sort()));
  });
}
