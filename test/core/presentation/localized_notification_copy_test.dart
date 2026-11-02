import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/core/presentation/localized_notification_copy.dart';
import 'package:fasomo/core/presentation/western_digits.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  Future<LocalizedNotificationCopy> copyFor(String language) async =>
      LocalizedNotificationCopy(
        await AppLocalizations.delegate.load(Locale(language)),
      );

  group('suggested pace', () {
    test('in English', () async {
      final copy = await copyFor('en');

      expect(
        copy.qadaPace(const PerWeekPace(1)),
        'To finish before Ramadan, fast 1 make-up day a week.',
      );
      expect(
        copy.qadaPace(const PerWeekPace(2)),
        'To finish before Ramadan, fast 2 make-up days a week.',
      );
      expect(
        copy.qadaPace(const EveryDayPace()),
        'To finish before Ramadan, fast a make-up day on every day you can.',
      );
      expect(
        copy.qadaPace(const NotEnoughDaysPace(3)),
        'Only 3 days are left before Ramadan, fewer than you owe. Fast every '
        'one you can, and the rest stays owed after Ramadan.',
      );
    });

    test('in Arabic, with its plural forms', () async {
      final copy = await copyFor('ar');

      expect(
        copy.qadaPace(const PerWeekPace(1)),
        'لتُتمّ القضاء قبل رمضان، صُم يوم قضاء واحدًا كل أسبوع.',
      );
      expect(
        copy.qadaPace(const PerWeekPace(2)),
        'لتُتمّ القضاء قبل رمضان، صُم يومَي قضاء كل أسبوع.',
      );
      expect(
        copy.qadaPace(const PerWeekPace(4)),
        'لتُتمّ القضاء قبل رمضان، صُم 4 أيام قضاء كل أسبوع.',
      );
      expect(
        copy.qadaPace(const NotEnoughDaysPace(11)),
        startsWith('لم يبقَ قبل رمضان إلا 11 يومًا'),
      );
      expect(
        copy.qadaPace(const NotEnoughDaysPace(0)),
        startsWith('لم يبقَ قبل رمضان يوم تقضي فيه ما عليك'),
      );
    });
  });

  group('suhoor and iftar', () {
    final fajr = DateTime.utc(2027, 2, 19, 5, 16);
    final maghrib = DateTime.utc(2027, 2, 19, 17, 22);

    setUpAll(() async {
      // MaterialApp's localizations load these in the app.
      await initializeDateFormatting();
      useWesternDigitsInDates();
    });

    test('in English', () async {
      final copy = await copyFor('en');
      final fajrTime = DateFormat.jm('en').format(fajr.toLocal());
      final maghribTime = DateFormat.jm('en').format(maghrib.toLocal());

      expect(copy.suhoorTitle(45), 'Suhoor ends in 45 minutes');
      expect(copy.suhoorTitle(1), 'Suhoor ends in 1 minute');
      expect(
        copy.suhoorBody(fajr),
        'Fajr is at $fajrTime. Finish your suhoor and make your intention '
        'to fast.',
      );
      expect(copy.iftarTitle(0), "It's time for iftar");
      expect(copy.iftarTitle(5), 'Iftar in 5 minutes');
      expect(
        copy.iftarBody(maghrib),
        'Maghrib is at $maghribTime. May Allah accept your fast.',
      );
    });

    test('in Arabic, with its plural forms and Western digits', () async {
      final copy = await copyFor('ar');

      expect(copy.suhoorTitle(45), 'ينتهي السحور بعد 45 دقيقة');
      expect(copy.suhoorTitle(2), 'ينتهي السحور بعد دقيقتين');
      expect(copy.suhoorTitle(15), 'ينتهي السحور بعد 15 دقيقة');
      expect(copy.iftarTitle(0), 'حان وقت الإفطار');
      expect(copy.iftarTitle(5), 'الإفطار بعد 5 دقائق');
      expect(copy.iftarTitle(10), 'الإفطار بعد 10 دقائق');
      expect(copy.suhoorBody(fajr), startsWith('يؤذَّن للفجر عند '));
      expect(copy.suhoorBody(fajr), contains(RegExp('[0-9]:[0-9]{2}')));
      expect(copy.iftarBody(maghrib), endsWith('تقبّل الله صيامك.'));
    });
  });
}
