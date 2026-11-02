import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/calendar/hijri_date.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/share/share_service.dart';
import 'package:fasomo/core/share/share_widget_image.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/share_day/presentation/shareable_fasting_day.dart';
import 'package:fasomo/features/share_day/presentation/widgets/fasting_day_share_card.dart';
import 'package:fasomo/features/share_day/presentation/widgets/share_day_button.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_share.dart';

const _hadith = SharedHadith(
  arabic: 'صِيَامُ يَوْمِ عَرَفَةَ',
  translation: 'Fasting the Day of Arafah',
  reference: 'Sahih Muslim 1162',
);

final _arafah = ShareableFastingDay(
  type: FastingType.arafah,
  hijriDate: const HijriDate(1448, 12, 9),
  gregorianDate: DateTime(2027, 5, 16),
  daysUntil: 1,
  hadith: _hadith,
);

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  theme: buildAppTheme(Brightness.dark),
  locale: locale,
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('FastingDayShareCard', () {
    Future<void> pumpCard(
      WidgetTester tester,
      ShareableFastingDay day, {
      Locale locale = const Locale('en'),
    }) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: ShareWidgetImage.width,
            child: FastingDayShareCard(day: day),
          ),
          locale: locale,
        ),
      );
    }

    testWidgets('in English shows the headline, both dates and the hadith', (
      tester,
    ) async {
      await pumpCard(tester, _arafah);

      expect(tester.takeException(), isNull);
      expect(find.text('Fasomo'), findsOneWidget);
      expect(find.text('Fasting tomorrow: Day of Arafah'), findsOneWidget);
      expect(find.text('9 Dhul Hijjah 1448 AH'), findsOneWidget);
      expect(find.text('May 16, 2027'), findsOneWidget);
      expect(find.text(_hadith.arabic), findsOneWidget);
      expect(find.text(_hadith.translation), findsOneWidget);
      expect(find.text('Sahih Muslim 1162'), findsOneWidget);
    });

    testWidgets('in Arabic lays out right-to-left without the translation', (
      tester,
    ) async {
      await pumpCard(tester, _arafah, locale: const Locale('ar'));

      expect(tester.takeException(), isNull);
      expect(find.text('صيام الغد: يوم عرفة'), findsOneWidget);
      expect(find.text(_hadith.arabic), findsOneWidget);
      expect(find.text(_hadith.translation), findsNothing);
      final headline = tester.getTopRight(find.text('صيام الغد: يوم عرفة'));
      final card = tester.getTopRight(find.byType(FastingDayShareCard));
      // Starts from the right edge, past the type's icon.
      expect(card.dx - headline.dx, lessThan(120));
    });

    testWidgets('headlines today, later days and past days', (tester) async {
      ShareableFastingDay inDays(int days) => ShareableFastingDay(
        type: FastingType.mondayThursday,
        hijriDate: const HijriDate(1448, 5, 18),
        gregorianDate: DateTime(2026, 10, 29),
        daysUntil: days,
      );

      await pumpCard(tester, inDays(0));
      expect(find.text('Fasting today: Monday & Thursday'), findsOneWidget);
      await pumpCard(tester, inDays(5));
      expect(find.text('Fasting in 5 days: Monday & Thursday'), findsOneWidget);
      await pumpCard(tester, inDays(-2));
      expect(find.text('Monday & Thursday'), findsOneWidget);
      await pumpCard(tester, inDays(3), locale: const Locale('ar'));
      expect(find.text('صيام بعد 3 أيام: الاثنين والخميس'), findsOneWidget);
    });
  });

  group('ShareDayButton', () {
    testWidgets('shares the card with the day as text and a dated name', (
      tester,
    ) async {
      final renderer = FakeWidgetImageRenderer();
      final service = FakeShareService();
      await tester.pumpWidget(
        _app(
          ShareDayButton(
            day: _arafah,
            share: ShareWidgetImage(renderer: renderer, shareService: service),
          ),
        ),
      );

      await tester.tap(find.text('Share'));
      await tester.pumpAndSettle();

      final shared = service.shared.single;
      expect(
        shared.text,
        'Fasting tomorrow: Day of Arafah, 9 Dhul Hijjah 1448 AH '
        '(May 16, 2027). Shared from Fasomo.',
      );
      expect(shared.fileName, 'fasomo-arafah-2027-05-16.png');
      expect(shared.bytes, FakeWidgetImageRenderer.bytes);
      expect(shared.origin, isNotNull);
      expect(find.byTooltip('Share Day of Arafah as an image'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('shares Arabic text in Arabic', (tester) async {
      final service = FakeShareService();
      await tester.pumpWidget(
        _app(
          ShareDayButton(
            day: _arafah,
            share: ShareWidgetImage(
              renderer: FakeWidgetImageRenderer(),
              shareService: service,
            ),
          ),
          locale: const Locale('ar'),
        ),
      );

      await tester.tap(find.text('مشاركة'));
      await tester.pumpAndSettle();

      expect(service.shared.single.text, startsWith('صيام الغد: يوم عرفة، '));
      expect(service.shared.single.text, endsWith('مشاركة من تطبيق فاصومو.'));
    });

    testWidgets('a failure shows a message', (tester) async {
      final service = FakeShareService(
        result: const Err<ShareOutcome, ShareFailure>(SharePlatformFailed()),
      );
      await tester.pumpWidget(
        _app(
          ShareDayButton(
            day: _arafah,
            share: ShareWidgetImage(
              renderer: FakeWidgetImageRenderer(),
              shareService: service,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Share'));
      await tester.pump();

      expect(
        find.text("Couldn't share this day. Please try again."),
        findsOneWidget,
      );
    });
  });
}
