/// The conventions for Fajr and Isha used by the main authorities, as
/// published by each (see `docs/plans/ramadan-mode.md`).
enum CalculationMethod {
  /// Umm al-Qura University, Makkah. Isha is a fixed time after Maghrib,
  /// 120 minutes in Ramadan.
  ummAlQura(
    fajrAngleDegrees: 18.5,
    ishaMinutesAfterMaghrib: 90,
    ishaMinutesInRamadan: 120,
  ),

  /// Egyptian General Authority of Survey.
  egyptian(fajrAngleDegrees: 19.5, ishaAngleDegrees: 17.5),

  /// Muslim World League; the default where no country is known.
  muslimWorldLeague(fajrAngleDegrees: 18, ishaAngleDegrees: 17),

  /// Islamic Society of North America.
  isna(fajrAngleDegrees: 15, ishaAngleDegrees: 15),

  /// University of Islamic Sciences, Karachi.
  karachi(fajrAngleDegrees: 18, ishaAngleDegrees: 18),

  /// Dubai (UAE General Authority of Islamic Affairs).
  dubai(fajrAngleDegrees: 18.2, ishaAngleDegrees: 18.2),

  /// Kuwait Ministry of Awqaf.
  kuwait(fajrAngleDegrees: 18, ishaAngleDegrees: 17.5),

  /// Qatar Ministry of Awqaf: Isha a fixed time after Maghrib.
  qatar(fajrAngleDegrees: 18, ishaMinutesAfterMaghrib: 90),

  /// Majlis Ugama Islam Singapura.
  singapore(fajrAngleDegrees: 20, ishaAngleDegrees: 18),

  /// Diyanet İşleri Başkanlığı, Turkey.
  turkey(fajrAngleDegrees: 18, ishaAngleDegrees: 17),

  /// Institute of Geophysics, University of Tehran: Maghrib when the sun is
  /// 4.5° below the horizon rather than at sunset.
  tehran(
    fajrAngleDegrees: 17.7,
    ishaAngleDegrees: 14,
    maghribAngleDegrees: 4.5,
  );

  new({
    required this.fajrAngleDegrees,
    this.ishaAngleDegrees,
    this.ishaMinutesAfterMaghrib,
    this.ishaMinutesInRamadan,
    this.maghribAngleDegrees,
  }) : assert(
         (ishaAngleDegrees == null) != (ishaMinutesAfterMaghrib == null),
         'Isha is either an angle or minutes after Maghrib',
       );

  /// Depression of the sun below the horizon at Fajr, in degrees.
  final double fajrAngleDegrees;

  /// Depression of the sun at Isha, or `null` when Isha is
  /// [ishaMinutesAfterMaghrib].
  final double? ishaAngleDegrees;

  /// Isha as a fixed time after Maghrib, or `null` when it is an angle.
  final int? ishaMinutesAfterMaghrib;

  /// The fixed Isha interval in Ramadan, when it differs from
  /// [ishaMinutesAfterMaghrib].
  final int? ishaMinutesInRamadan;

  /// Depression of the sun at Maghrib, or `null` for sunset.
  final double? maghribAngleDegrees;

  /// The method customarily used in the country with ISO 3166-1 alpha-2
  /// code [countryCode]; [muslimWorldLeague] when it is unknown or `null`.
  static CalculationMethod forCountry(String? countryCode) =>
      _byCountry[countryCode?.toUpperCase()] ?? muslimWorldLeague;

  static const _byCountry = <String, CalculationMethod>{
    'SA': ummAlQura,
    'YE': ummAlQura,
    'EG': egyptian,
    'SD': egyptian,
    'LY': egyptian,
    'SY': egyptian,
    'LB': egyptian,
    'JO': egyptian,
    'PS': egyptian,
    'IQ': egyptian,
    'US': isna,
    'CA': isna,
    'PK': karachi,
    'IN': karachi,
    'BD': karachi,
    'AF': karachi,
    'AE': dubai,
    'KW': kuwait,
    'QA': qatar,
    'SG': singapore,
    'MY': singapore,
    'ID': singapore,
    'BN': singapore,
    'TR': turkey,
    'IR': tehran,
  };
}

/// How the shadow length for Asr is reckoned.
enum AsrMethod {
  /// Shafi'i, Maliki and Hanbali: the shadow equals the object's height
  /// plus its noon shadow.
  standard(shadowFactor: 1),

  /// Hanafi: twice the height plus the noon shadow, so Asr is later.
  hanafi(shadowFactor: 2);

  new({required this.shadowFactor});

  final int shadowFactor;
}

/// Where the sun never gets low enough for Fajr or Isha, or gets there
/// unreasonably late, the time is capped at a portion of the night counted
/// from sunrise (Fajr) or sunset (Isha).
enum HighLatitudeRule {
  /// Half the night.
  middleOfTheNight,

  /// A seventh of the night.
  seventhOfTheNight,

  /// The angle divided by 60 of the night, e.g. 0.3 for 18°.
  twilightAngle;

  /// The fraction of the night allowed for a twilight of [angleDegrees].
  double nightFraction(double angleDegrees) => switch (this) {
    middleOfTheNight => 1 / 2,
    seventhOfTheNight => 1 / 7,
    twilightAngle => angleDegrees / 60,
  };
}
