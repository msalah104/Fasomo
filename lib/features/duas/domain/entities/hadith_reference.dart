import 'package:equatable/equatable.dart';

/// The hadith collections the bundled texts are cited from.
enum HadithCollection { bukhari, muslim, abuDawud, tirmidhi, nasai, ibnMajah }

/// Where a text is found: a collection and its hadith number in the
/// numbering used by sunnah.com.
class HadithReference extends Equatable {
  const new(this.collection, this.number);

  final HadithCollection collection;
  final int number;

  @override
  List<Object> get props => [collection, number];
}
