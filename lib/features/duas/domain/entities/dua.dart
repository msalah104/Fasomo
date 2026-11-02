import 'package:equatable/equatable.dart';
import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/duas/domain/entities/hadith_reference.dart';

/// Stable identity of each bundled text; the presentation layer maps it to a
/// localized title.
enum DuaId {
  intention,
  iftar,
  iftarAsGuest,
  laylatAlQadr,
  ramadanVirtue,
  arafahVirtue,
  ashuraVirtue,
  tasuaVirtue,
  shawwalVirtue,
  whiteDaysVirtue,
  mondayThursdayVirtue,
}

/// The section a text is listed under, in display order.
enum DuaCategory { intention, breakingTheFast, laylatAlQadr, virtue }

/// A dua, or a hadith about a fast, with its sources.
///
/// The Arabic is the original wording; [translation] and [transliteration]
/// are English renderings of it.
class Dua extends Equatable {
  const new({
    required this.id,
    required this.category,
    required this.arabic,
    required this.translation,
    required this.sources,
    this.transliteration,
    this.fastingTypes = const {},
  });

  final DuaId id;
  final DuaCategory category;

  /// The Arabic text, with tashkeel.
  final String arabic;

  /// English meaning of [arabic].
  final String translation;

  /// Latin transliteration, for duas meant to be recited; `null` for hadith.
  final String? transliteration;

  /// Never empty.
  final List<HadithReference> sources;

  /// The fasts this text belongs to; empty when it applies to every fast.
  final Set<FastingType> fastingTypes;

  /// Whether the text belongs on a page about [type]. A text for every fast
  /// belongs everywhere.
  bool appliesTo(FastingType type) =>
      fastingTypes.isEmpty || fastingTypes.contains(type);

  @override
  List<Object?> get props => [
    id,
    category,
    arabic,
    translation,
    transliteration,
    sources,
    fastingTypes,
  ];
}
