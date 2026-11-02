import 'package:fasomo/core/notifications/qada_pace_rate.dart';
import 'package:fasomo/core/presentation/localized_notification_copy.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
