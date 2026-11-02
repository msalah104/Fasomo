import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/entities/hadith_reference.dart';

/// The bundled texts, in display order.
///
/// Only well-known texts from the six major hadith collections are included,
/// each with its sunnah.com hadith number. Change a text only against its
/// source, and keep the Arabic wording exact.
///
/// Transliterations use ASCII plus long vowels (ā ī ū) only, with an
/// apostrophe for both hamza and 'ayn, because the bundled fonts draw no
/// other Latin diacritics.
abstract final class DuaCatalog {
  static const List<Dua> all = [
    // ----- Intention -----
    Dua(
      id: DuaId.intention,
      category: DuaCategory.intention,
      arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
      translation:
          'Actions are only by intentions, and every person will have only '
          'what they intended.',
      sources: [
        HadithReference(HadithCollection.bukhari, 1),
        HadithReference(HadithCollection.muslim, 1907),
      ],
    ),

    // ----- Breaking the fast -----
    Dua(
      id: DuaId.iftar,
      category: DuaCategory.breakingTheFast,
      arabic: 'ذَهَبَ الظَّمَأُ، وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
      transliteration:
          "Dhahaba al-zama'u, wabtallati al-'urūqu, wa thabata al-ajru "
          "in shā' Allāh.",
      translation:
          'The thirst has gone, the veins are moistened, and the reward is '
          'certain, if Allah wills.',
      sources: [HadithReference(HadithCollection.abuDawud, 2357)],
    ),
    Dua(
      id: DuaId.iftarAsGuest,
      category: DuaCategory.breakingTheFast,
      arabic:
          'أَفْطَرَ عِنْدَكُمُ الصَّائِمُونَ، وَأَكَلَ طَعَامَكُمُ الْأَبْرَارُ، '
          'وَصَلَّتْ عَلَيْكُمُ الْمَلَائِكَةُ',
      transliteration:
          "Aftara 'indakum al-sā'imūn, wa akala ta'āmakum al-abrār, "
          "wa sallat 'alaykum al-malā'ikah.",
      translation:
          'May those who fast break their fast with you, may the righteous '
          'eat your food, and may the angels pray for you.',
      sources: [HadithReference(HadithCollection.abuDawud, 3854)],
    ),

    // ----- Laylat al-Qadr -----
    Dua(
      id: DuaId.laylatAlQadr,
      category: DuaCategory.laylatAlQadr,
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      transliteration:
          "Allāhumma innaka 'afuwwun tuhibbu al-'afwa fa'fu 'annī.",
      translation:
          'O Allah, You are Most Forgiving and You love to forgive, so '
          'forgive me.',
      sources: [
        HadithReference(HadithCollection.tirmidhi, 3513),
        HadithReference(HadithCollection.ibnMajah, 3850),
      ],
      fastingTypes: {FastingType.ramadan},
    ),

    // ----- The virtue of each fast -----
    Dua(
      id: DuaId.ramadanVirtue,
      category: DuaCategory.virtue,
      arabic:
          'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ '
          'مِنْ ذَنْبِهِ',
      translation:
          'Whoever fasts Ramadan out of faith and seeking its reward will '
          'have their past sins forgiven.',
      sources: [HadithReference(HadithCollection.bukhari, 38)],
      fastingTypes: {FastingType.ramadan},
    ),
    Dua(
      id: DuaId.arafahVirtue,
      category: DuaCategory.virtue,
      arabic:
          'صِيَامُ يَوْمِ عَرَفَةَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ '
          'السَّنَةَ الَّتِي قَبْلَهُ وَالسَّنَةَ الَّتِي بَعْدَهُ',
      translation:
          'Fasting the Day of Arafah: I hope from Allah that it expiates the '
          'year before it and the year after it.',
      sources: [HadithReference(HadithCollection.muslim, 1162)],
      fastingTypes: {FastingType.arafah},
    ),
    Dua(
      id: DuaId.ashuraVirtue,
      category: DuaCategory.virtue,
      arabic:
          'صِيَامُ يَوْمِ عَاشُورَاءَ أَحْتَسِبُ عَلَى اللَّهِ أَنْ يُكَفِّرَ '
          'السَّنَةَ الَّتِي قَبْلَهُ',
      translation:
          'Fasting the Day of Ashura: I hope from Allah that it expiates the '
          'year before it.',
      sources: [HadithReference(HadithCollection.muslim, 1162)],
      fastingTypes: {FastingType.ashura},
    ),
    Dua(
      id: DuaId.tasuaVirtue,
      category: DuaCategory.virtue,
      arabic: 'لَئِنْ بَقِيتُ إِلَى قَابِلٍ لَأَصُومَنَّ التَّاسِعَ',
      translation:
          'If I live until next year, I will surely fast the ninth '
          '[of Muharram].',
      sources: [HadithReference(HadithCollection.muslim, 1134)],
      fastingTypes: {FastingType.tasua},
    ),
    Dua(
      id: DuaId.shawwalVirtue,
      category: DuaCategory.virtue,
      arabic:
          'مَنْ صَامَ رَمَضَانَ ثُمَّ أَتْبَعَهُ سِتًّا مِنْ شَوَّالٍ كَانَ '
          'كَصِيَامِ الدَّهْرِ',
      translation:
          'Whoever fasts Ramadan and follows it with six days of Shawwal, it '
          'is as if they fasted for a lifetime.',
      sources: [HadithReference(HadithCollection.muslim, 1164)],
      fastingTypes: {FastingType.shawwal},
    ),
    Dua(
      id: DuaId.whiteDaysVirtue,
      category: DuaCategory.virtue,
      arabic:
          'يَا أَبَا ذَرٍّ، إِذَا صُمْتَ مِنَ الشَّهْرِ ثَلَاثَةَ أَيَّامٍ فَصُمْ '
          'ثَلَاثَ عَشْرَةَ وَأَرْبَعَ عَشْرَةَ وَخَمْسَ عَشْرَةَ',
      translation:
          'O Abu Dharr, if you fast three days of the month, fast the '
          'thirteenth, the fourteenth and the fifteenth.',
      sources: [HadithReference(HadithCollection.tirmidhi, 761)],
      fastingTypes: {FastingType.whiteDays},
    ),
    Dua(
      id: DuaId.mondayThursdayVirtue,
      category: DuaCategory.virtue,
      arabic:
          'تُعْرَضُ الْأَعْمَالُ يَوْمَ الِاثْنَيْنِ وَالْخَمِيسِ، فَأُحِبُّ أَنْ '
          'يُعْرَضَ عَمَلِي وَأَنَا صَائِمٌ',
      translation:
          'Deeds are presented on Monday and Thursday, and I love that my '
          'deeds are presented while I am fasting.',
      sources: [HadithReference(HadithCollection.tirmidhi, 747)],
      fastingTypes: {FastingType.mondayThursday},
    ),
  ];
}
