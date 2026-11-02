import 'package:fasomo/core/location/city.dart';
import 'package:fasomo/core/location/city_catalog.dart';
import 'package:fasomo/core/presentation/location/city_picker_page.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Opens the picker from a button and reports what it returns.
  Future<void> openPicker(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    City? selected,
    ValueChanged<City?>? onPicked,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final city = await CityPickerPage.show(
                context,
                selected: selected,
              );
              onPicked?.call(city);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('search narrows the list and a tap returns the city', (
    tester,
  ) async {
    City? picked;
    await openPicker(tester, onPicked: (city) => picked = city);
    expect(find.text('Choose a city'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cair');
    await tester.pumpAndSettle();
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Egypt'), findsOneWidget);
    expect(find.text('London'), findsNothing);

    await tester.tap(find.text('Cairo'));
    await tester.pumpAndSettle();
    expect(picked, CityCatalog.byId('EG:Cairo'));
    expect(find.text('Choose a city'), findsNothing);
  });

  testWidgets('shows Arabic names, right to left, and marks the selection', (
    tester,
  ) async {
    await openPicker(
      tester,
      locale: const Locale('ar'),
      selected: CityCatalog.byId('SA:Makkah'),
    );

    expect(find.text('اختر مدينة'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'مكة');
    await tester.pumpAndSettle();
    expect(find.text('مكة المكرمة'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('مكة المكرمة'))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('says so when nothing matches, and can clear the search', (
    tester,
  ) async {
    await openPicker(tester);

    await tester.enterText(find.byType(TextField), 'springfield');
    await tester.pumpAndSettle();
    expect(find.textContaining('No city matches'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No city matches'), findsNothing);
    expect(find.byType(ListTile), findsWidgets);
  });

  test('flag emoji come from regional indicator letters', () {
    expect(flagEmoji('EG'), '🇪🇬');
    expect(flagEmoji('sa'), '🇸🇦');
  });
}
