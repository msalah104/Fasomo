import 'package:fasomo/core/prayer/calculation_method.dart';
import 'package:fasomo/core/prayer/prayer_time_calculator.dart';
import 'package:fasomo/core/prayer/prayer_times.dart';
import 'package:flutter_test/flutter_test.dart';

// Reference times (UTC) are from an independent implementation of the
// PrayTimes.org v2.3 algorithm (Hamid Zarrabi-Zadeh's praytimes.js), with
// its own low-precision sun, its default single iteration and its
// high-latitude rules. Ours refines the sun's position at each estimate,
// so the two agree to within a minute or two.

typedef _Place = ({double lat, double lng});

const _Place _makkah = (lat: 21.42, lng: 39.83);
const _Place _cairo = (lat: 30.04, lng: 31.24);
const _Place _london = (lat: 51.51, lng: -0.13);
const _Place _karachi = (lat: 24.86, lng: 67.01);
const _Place _tehran = (lat: 35.69, lng: 51.39);
const _Place _newYork = (lat: 40.71, lng: -74.01);
const _Place _tromso = (lat: 69.65, lng: 18.96);

/// Fajr, sunrise, Dhuhr, Asr, Maghrib, Isha as `HH:mm` UTC on the day,
/// with `+1` for the next day, or `null` where undefined.
typedef _Expected = List<String?>;

PrayerTimes _compute(
  _Place place,
  DateTime date,
  CalculationMethod method, {
  AsrMethod asr = AsrMethod.standard,
  HighLatitudeRule rule = HighLatitudeRule.middleOfTheNight,
  PrayerAdjustments adjustments = PrayerAdjustments.none,
  bool inRamadan = false,
}) => PrayerTimeCalculator.compute(
  date,
  latitude: place.lat,
  longitude: place.lng,
  method: method,
  asrMethod: asr,
  highLatitudeRule: rule,
  adjustments: adjustments,
  inRamadan: inRamadan,
);

void _expectTimes(PrayerTimes times, _Expected expected) {
  const tolerance = Duration(minutes: 2);
  for (final (index, prayer) in Prayer.values.indexed) {
    final want = expected[index];
    final actual = times[prayer];
    if (want == null) {
      expect(actual, isNull, reason: prayer.name);
      continue;
    }
    final date = times.date;
    final nextDay = want.endsWith('+1');
    final parts = want.replaceAll('+1', '').split(':').map(int.parse).toList();
    final reference = DateTime.utc(
      date.year,
      date.month,
      date.day + (nextDay ? 1 : 0),
      parts[0],
      parts[1],
    );
    expect(actual, isNotNull, reason: prayer.name);
    expect(actual!.isUtc, isTrue, reason: prayer.name);
    expect(
      actual.difference(reference).abs(),
      lessThanOrEqualTo(tolerance),
      reason: '${prayer.name}: $actual vs $reference',
    );
  }
}

void main() {
  group('matches the PrayTimes.org reference within 2 minutes', () {
    final cases = <(String, PrayerTimes, _Expected)>[
      (
        'Makkah, Umm al-Qura, in Ramadan (Isha 120 min)',
        _compute(
          _makkah,
          DateTime(2027, 2, 15),
          CalculationMethod.ummAlQura,
          inRamadan: true,
        ),
        ['02:34', '03:52', '09:35', '12:52', '15:18', '17:18'],
      ),
      (
        'Makkah, Umm al-Qura, outside Ramadan (Isha 90 min)',
        _compute(_makkah, DateTime(2026, 6, 21), CalculationMethod.ummAlQura),
        ['01:11', '02:39', '09:22', '12:42', '16:06', '17:36'],
      ),
      (
        'Cairo, Egyptian, February',
        _compute(_cairo, DateTime(2027, 2, 15), CalculationMethod.egyptian),
        ['03:08', '04:35', '10:09', '13:19', '15:43', '17:02'],
      ),
      (
        'Cairo, Egyptian, June',
        _compute(_cairo, DateTime(2026, 6, 21), CalculationMethod.egyptian),
        ['01:08', '02:54', '09:57', '13:32', '16:59', '18:33'],
      ),
      (
        'London, MWL, December',
        _compute(
          _london,
          DateTime(2026, 12, 21),
          CalculationMethod.muslimWorldLeague,
        ),
        ['05:59', '08:04', '11:59', '13:38', '15:53', '17:51'],
      ),
      (
        'London, MWL, June, middle of the night',
        _compute(
          _london,
          DateTime(2026, 6, 21),
          CalculationMethod.muslimWorldLeague,
        ),
        ['00:02', '03:43', '12:02', '16:25', '20:22', '00:02+1'],
      ),
      (
        'London, MWL, June, one-seventh of the night',
        _compute(
          _london,
          DateTime(2026, 6, 21),
          CalculationMethod.muslimWorldLeague,
          rule: HighLatitudeRule.seventhOfTheNight,
        ),
        ['02:40', '03:43', '12:02', '16:25', '20:22', '21:25'],
      ),
      (
        'London, MWL, June, twilight angle',
        _compute(
          _london,
          DateTime(2026, 6, 21),
          CalculationMethod.muslimWorldLeague,
          rule: HighLatitudeRule.twilightAngle,
        ),
        ['01:31', '03:43', '12:02', '16:25', '20:22', '22:27'],
      ),
      (
        'Karachi, Karachi, Hanafi Asr',
        _compute(
          _karachi,
          DateTime(2027, 2, 15),
          CalculationMethod.karachi,
          asr: AsrMethod.hanafi,
        ),
        ['00:50', '02:06', '07:46', '11:49', '13:26', '14:43'],
      ),
      (
        'Tehran, Tehran (Maghrib at 4.5°)',
        _compute(_tehran, DateTime(2027, 2, 15), CalculationMethod.tehran),
        ['01:58', '03:22', '08:49', '11:51', '14:34', '15:22'],
      ),
      (
        'New York, ISNA',
        _compute(_newYork, DateTime(2027, 2, 15), CalculationMethod.isna),
        ['10:34', '11:50', '17:10', '20:05', '22:31', '23:47'],
      ),
    ];

    for (final (name, times, expected) in cases) {
      test(name, () => _expectTimes(times, expected));
    }
  });

  test('London midnight-rule Isha falls after midnight UTC', () {
    // Isha is half the night after sunset: just past midnight, so on the
    // next calendar day.
    final times = _compute(
      _london,
      DateTime(2026, 6, 21),
      CalculationMethod.muslimWorldLeague,
    );
    expect(times.isha, isNotNull);
    expect(times.isha!.isAfter(times.maghrib!), isTrue);
    expect(times.isha!.day, 22);
  });

  group('invariants', () {
    final places = {
      'Makkah': _makkah,
      'Cairo': _cairo,
      'London': _london,
      'New York': _newYork,
      'Karachi': _karachi,
      'Sydney': (lat: -33.87, lng: 151.21),
    };

    test('the times are in order on every day of a year', () {
      for (final MapEntry(key: name, value: place) in places.entries) {
        for (var day = 0; day < 365; day += 5) {
          final date = DateTime(2027, 1, 1 + day);
          final times = _compute(
            place,
            date,
            CalculationMethod.muslimWorldLeague,
          );
          final ordered = [
            times.fajr!,
            times.sunrise!,
            times.dhuhr,
            times.asr!,
            times.maghrib!,
            times.isha!,
          ];
          for (var i = 1; i < ordered.length; i++) {
            expect(
              ordered[i].isAfter(ordered[i - 1]),
              isTrue,
              reason: '$name $date: ${Prayer.values[i].name}',
            );
          }
        }
      }
    });

    test('every time is on a whole minute', () {
      final times = _compute(
        _cairo,
        DateTime(2027, 3, 3),
        CalculationMethod.egyptian,
      );
      for (final prayer in Prayer.values) {
        final time = times[prayer]!;
        expect(time.second, 0);
        expect(time.millisecond, 0);
      }
    });

    test('Hanafi Asr is later than Standard', () {
      for (final place in places.values) {
        final date = DateTime(2027, 2, 15);
        final standard = _compute(place, date, CalculationMethod.karachi);
        final hanafi = _compute(
          place,
          date,
          CalculationMethod.karachi,
          asr: AsrMethod.hanafi,
        );
        expect(hanafi.asr!.isAfter(standard.asr!), isTrue);
      }
    });

    test('a steeper Fajr angle is earlier', () {
      final date = DateTime(2027, 2, 15);
      final egyptian = _compute(_cairo, date, CalculationMethod.egyptian);
      final isna = _compute(_cairo, date, CalculationMethod.isna);
      expect(egyptian.fajr!.isBefore(isna.fajr!), isTrue);
    });

    test('the Ramadan Isha only changes Umm al-Qura', () {
      final date = DateTime(2027, 2, 15);
      for (final method in CalculationMethod.values) {
        final usual = _compute(_makkah, date, method);
        final ramadan = _compute(_makkah, date, method, inRamadan: true);
        final extra = method == CalculationMethod.ummAlQura ? 30 : 0;
        expect(
          ramadan.isha!.difference(usual.isha!),
          Duration(minutes: extra),
          reason: method.name,
        );
      }
    });

    test('Qatar is 90 minutes after Maghrib all year', () {
      final times = _compute(
        _makkah,
        DateTime(2027, 2, 15),
        CalculationMethod.qatar,
        inRamadan: true,
      );
      expect(times.isha!.difference(times.maghrib!).inMinutes, 90);
    });

    test('the middle-of-the-night and angle rules change nothing in Cairo', () {
      final date = DateTime(2027, 6, 21);
      final results = {
        for (final rule in [
          HighLatitudeRule.middleOfTheNight,
          HighLatitudeRule.twilightAngle,
        ])
          _compute(_cairo, date, CalculationMethod.egyptian, rule: rule),
      };
      expect(results, hasLength(1));
    });

    test('one-seventh caps a long summer twilight even in Cairo', () {
      // As in PrayTimes.org and adhan, the cap applies everywhere: a
      // seventh of a short June night is less than the 19.5° twilight.
      final date = DateTime(2027, 6, 21);
      final middle = _compute(_cairo, date, CalculationMethod.egyptian);
      final seventh = _compute(
        _cairo,
        date,
        CalculationMethod.egyptian,
        rule: HighLatitudeRule.seventhOfTheNight,
      );
      expect(seventh.fajr!.isAfter(middle.fajr!), isTrue);
      expect(seventh.sunrise, middle.sunrise);
    });
  });

  test('adjustments shift each time by exactly their minutes', () {
    final date = DateTime(2027, 2, 15);
    final plain = _compute(_cairo, date, CalculationMethod.egyptian);
    const adjustments = PrayerAdjustments(
      fajr: -2,
      sunrise: 1,
      dhuhr: 3,
      asr: -4,
      maghrib: 5,
      isha: 30,
    );
    final adjusted = _compute(
      _cairo,
      date,
      CalculationMethod.egyptian,
      adjustments: adjustments,
    );
    for (final prayer in Prayer.values) {
      expect(
        adjusted[prayer]!.difference(plain[prayer]!),
        Duration(minutes: adjustments[prayer]),
        reason: prayer.name,
      );
    }
  });

  test('adjustments are clamped to ±30 minutes', () {
    const none = PrayerAdjustments.none;
    expect(none.withMinutes(Prayer.isha, 90).isha, 30);
    expect(none.withMinutes(Prayer.fajr, -45).fajr, -30);
    expect(none.withMinutes(Prayer.asr, 7)[Prayer.asr], 7);
    expect(none.withMinutes(Prayer.asr, 7).isNone, isFalse);
    expect(none.isNone, isTrue);
  });

  group('polar day and night', () {
    test('midsummer in Tromsø has only Dhuhr and Asr', () {
      final times = _compute(
        _tromso,
        DateTime(2027, 6, 21),
        CalculationMethod.muslimWorldLeague,
      );
      expect(times.fajr, isNull);
      expect(times.sunrise, isNull);
      expect(times.maghrib, isNull);
      expect(times.isha, isNull);
      expect(times.asr, isNotNull);
    });

    test('midwinter in Tromsø has only Dhuhr', () {
      final times = _compute(
        _tromso,
        DateTime(2026, 12, 21),
        CalculationMethod.muslimWorldLeague,
      );
      expect(times.fajr, isNull);
      expect(times.sunrise, isNull);
      expect(times.asr, isNull);
      expect(times.maghrib, isNull);
      expect(times.isha, isNull);
    });
  });

  group('CalculationMethod.forCountry', () {
    test('picks each country default', () {
      expect(CalculationMethod.forCountry('SA'), CalculationMethod.ummAlQura);
      expect(CalculationMethod.forCountry('EG'), CalculationMethod.egyptian);
      expect(CalculationMethod.forCountry('us'), CalculationMethod.isna);
      expect(CalculationMethod.forCountry('PK'), CalculationMethod.karachi);
      expect(CalculationMethod.forCountry('AE'), CalculationMethod.dubai);
      expect(CalculationMethod.forCountry('KW'), CalculationMethod.kuwait);
      expect(CalculationMethod.forCountry('QA'), CalculationMethod.qatar);
      expect(CalculationMethod.forCountry('SG'), CalculationMethod.singapore);
      expect(CalculationMethod.forCountry('TR'), CalculationMethod.turkey);
      expect(CalculationMethod.forCountry('IR'), CalculationMethod.tehran);
    });

    test('falls back to the Muslim World League', () {
      expect(
        CalculationMethod.forCountry('GB'),
        CalculationMethod.muslimWorldLeague,
      );
      expect(
        CalculationMethod.forCountry(null),
        CalculationMethod.muslimWorldLeague,
      );
    });

    test('every method has either an Isha angle or an interval', () {
      for (final method in CalculationMethod.values) {
        expect(
          (method.ishaAngleDegrees == null) !=
              (method.ishaMinutesAfterMaghrib == null),
          isTrue,
          reason: method.name,
        );
      }
    });
  });
}
