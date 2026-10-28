import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/splash/presentation/pages/splash_page.dart';
import 'package:fasomo/features/splash/presentation/splash_timeline.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late int finishedCount;

  Future<void> pumpSplash(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    bool reduceMotion = false,
  }) async {
    finishedCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: reduceMotion),
          child: child!,
        ),
        home: SplashPage(onFinished: () => finishedCount++),
      ),
    );
  }

  testWidgets('types the name and finishes once at the end', (tester) async {
    await pumpSplash(tester);
    expect(find.text('Fasomo'), findsOneWidget, reason: 'sizing copy only');

    await tester.pump(SplashTimeline.total * 0.95);
    expect(find.text('Fasomo'), findsNWidgets(2));
    expect(finishedCount, 0);

    await tester.pump(SplashTimeline.total * 0.1);
    await tester.pump(SplashTimeline.total);
    expect(finishedCount, 1);
  });

  testWidgets('types the Arabic name in Arabic', (tester) async {
    await pumpSplash(tester, locale: const Locale('ar'));
    await tester.pump(SplashTimeline.total * 0.95);

    expect(find.text('فاصومو'), findsNWidgets(2));
  });

  testWidgets('a tap skips straight to the end', (tester) async {
    await pumpSplash(tester);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byType(SplashPage));
    await tester.pump(SplashTimeline.total);

    expect(finishedCount, 1);
  });

  testWidgets('reduced motion shows the finished scene, then finishes', (
    tester,
  ) async {
    await pumpSplash(tester, reduceMotion: true);
    await tester.pump();

    expect(find.text('Fasomo'), findsNWidgets(2));
    expect(finishedCount, 0);

    await tester.pump(const Duration(seconds: 1));
    expect(finishedCount, 1);
  });
}
