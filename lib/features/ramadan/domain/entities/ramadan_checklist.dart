import 'package:equatable/equatable.dart';

/// What the user did on one day of Ramadan, besides fasting (which the
/// tracker's fasting log owns).
final class RamadanChecklist extends Equatable {
  const new({
    required this.date,
    this.prayedTaraweeh = false,
    this.quranPages = 0,
  }) : assert(
         quranPages >= 0 && quranPages <= maxQuranPages,
         'quranPages must be 0..$maxQuranPages',
       );

  /// The pages of a standard (Madinah) mushaf.
  static const int maxQuranPages = 604;

  /// Local midnight of the day.
  final DateTime date;
  final bool prayedTaraweeh;

  /// 0 to [maxQuranPages].
  final int quranPages;

  /// Whether nothing is ticked, so there is nothing to keep.
  bool get isEmpty => !prayedTaraweeh && quranPages == 0;

  RamadanChecklist copyWith({bool? prayedTaraweeh, int? quranPages}) =>
      RamadanChecklist(
        date: date,
        prayedTaraweeh: prayedTaraweeh ?? this.prayedTaraweeh,
        quranPages: (quranPages ?? this.quranPages).clamp(0, maxQuranPages),
      );

  @override
  List<Object> get props => [date, prayedTaraweeh, quranPages];
}
