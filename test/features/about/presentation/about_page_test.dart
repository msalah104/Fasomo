import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/about/presentation/pages/about_page.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpAboutPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: AboutPage()),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('fasomo.site'),
      300,
      scrollable: find.byType(Scrollable),
    );
  }

  testWidgets('the contact card shows the email and the website', (
    tester,
  ) async {
    await pumpAboutPage(tester);

    expect(find.text('support@fasomo.site'), findsOneWidget);
    expect(find.text('fasomo.site'), findsOneWidget);
  });

  testWidgets('the contact card has no source code entry', (tester) async {
    await pumpAboutPage(tester);

    expect(find.byIcon(Icons.code), findsNothing);
    expect(find.textContaining('github'), findsNothing);
  });
}
