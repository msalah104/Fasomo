import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/presentation/fasting_type_text.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/entities/hadith_reference.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';

/// Localized labels for the bundled texts. The texts themselves are not
/// translated here: the Arabic is the original and the English rendering
/// ships with it.
extension DuaText on AppLocalizations {
  String duaTitle(DuaId id) => switch (id) {
    DuaId.intention => duaIntentionTitle,
    DuaId.iftar => duaIftarTitle,
    DuaId.iftarAsGuest => duaIftarAsGuestTitle,
    DuaId.laylatAlQadr => duaLaylatAlQadrTitle,
    DuaId.ramadanVirtue => fastingTypeTitle(FastingType.ramadan),
    DuaId.arafahVirtue => fastingTypeTitle(FastingType.arafah),
    DuaId.ashuraVirtue => fastingTypeTitle(FastingType.ashura),
    DuaId.tasuaVirtue => fastingTypeTitle(FastingType.tasua),
    DuaId.shawwalVirtue => fastingTypeTitle(FastingType.shawwal),
    DuaId.whiteDaysVirtue => fastingTypeTitle(FastingType.whiteDays),
    DuaId.mondayThursdayVirtue => fastingTypeTitle(FastingType.mondayThursday),
  };

  /// A note shown under the text, or `null` for none.
  String? duaNote(DuaId id) => id == DuaId.intention ? duaIntentionNote : null;

  String duaSectionTitle(DuaCategory category) => switch (category) {
    DuaCategory.intention => duaSectionIntention,
    DuaCategory.breakingTheFast => duaSectionBreakingTheFast,
    DuaCategory.laylatAlQadr => duaSectionLaylatAlQadr,
    DuaCategory.virtue => duaSectionVirtue,
  };

  /// One reference, e.g. "Sahih Muslim 1162".
  String hadithReference(HadithReference reference) {
    final number = '${reference.number}';
    return switch (reference.collection) {
      HadithCollection.bukhari => hadithSourceBukhari(number),
      HadithCollection.muslim => hadithSourceMuslim(number),
      HadithCollection.abuDawud => hadithSourceAbuDawud(number),
      HadithCollection.tirmidhi => hadithSourceTirmidhi(number),
      HadithCollection.nasai => hadithSourceNasai(number),
      HadithCollection.ibnMajah => hadithSourceIbnMajah(number),
    };
  }

  /// Every reference of a text, joined, without the "Source:" prefix.
  String hadithReferences(List<HadithReference> references) =>
      references.map(hadithReference).join(duaSourceSeparator);
}
