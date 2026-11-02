import 'package:fasomo/core/calendar/fasting_type.dart';
import 'package:fasomo/core/theme/app_theme.dart';
import 'package:fasomo/features/about/presentation/pages/about_page.dart';
import 'package:fasomo/features/duas/data/datasources/dua_catalog.dart';
import 'package:fasomo/features/duas/data/repositories/dua_repository_impl.dart';
import 'package:fasomo/features/duas/domain/entities/dua.dart';
import 'package:fasomo/features/duas/domain/usecases/get_duas.dart';
import 'package:fasomo/features/duas/presentation/bloc/duas_bloc.dart';
import 'package:fasomo/features/duas/presentation/pages/duas_page.dart';
import 'package:fasomo/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// The page's list, not the filter bar or a selectable text's own scroller.
final Finder _verticalList = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

Dua _dua(DuaId id) => DuaCatalog.all.singleWhere((dua) => dua.id == id);

void main() {
  late DuasBloc bloc;

  Future<void> pumpDuas(
    WidgetTester tester, {
    FastingType? filter,
    Locale locale = const Locale('en'),
  }) async {
    bloc = DuasBloc(getDuas: const GetDuas(DuaRepositoryImpl()))
      ..add(DuasFilterChanged(filter));
    addTearDown(bloc.close);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider.value(value: bloc, child: const DuasPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('in English shows the Arabic right-to-left, its meaning and '
      'its source', (tester) async {
    await pumpDuas(tester, filter: FastingType.arafah);

    final iftar = _dua(DuaId.iftar);
    expect(find.text('Duas and intentions'), findsOneWidget);
    expect(find.text('When breaking the fast'), findsOneWidget);
    expect(find.text(iftar.arabic), findsOneWidget);
    expect(find.text(iftar.translation), findsOneWidget);
    expect(find.text(iftar.transliteration!), findsOneWidget);
    expect(find.text('Source: Sunan Abi Dawud 2357'), findsOneWidget);

    final direction = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text(iftar.arabic),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(direction.textDirection, TextDirection.rtl);

    // Narrowed to Arafah: its hadith is there, another fast's is not.
    await tester.scrollUntilVisible(
      find.text('Source: Sahih Muslim 1162'),
      200,
      scrollable: _verticalList,
    );
    expect(find.text(_dua(DuaId.arafahVirtue).arabic), findsOneWidget);
    expect(
      find.text(_dua(DuaId.shawwalVirtue).arabic, skipOffstage: false),
      findsNothing,
    );
  });

  testWidgets('in Arabic shows the original only, with Arabic sources', (
    tester,
  ) async {
    await pumpDuas(tester, locale: const Locale('ar'));

    final intention = _dua(DuaId.intention);
    expect(find.text('الأدعية والنية'), findsOneWidget);
    expect(find.text(intention.arabic), findsOneWidget);
    expect(find.text(intention.translation), findsNothing);
    expect(
      find.text('المصدر: صحيح البخاري 1؛ صحيح مسلم 1907'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a filter chip narrows the list', (tester) async {
    await pumpDuas(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Ramadan'));
    await tester.pumpAndSettle();

    expect(bloc.state.filter, FastingType.ramadan);
    expect(
      bloc.state.duas.map((dua) => dua.id),
      contains(DuaId.laylatAlQadr),
    );
  });

  testWidgets('the copy button copies the text and confirms', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          final args = call.arguments as Map<Object?, Object?>;
          copied.add(args['text']! as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpDuas(tester, filter: FastingType.arafah);

    await tester.tap(find.byTooltip('Copy When breaking the fast'));
    await tester.pump();

    final iftar = _dua(DuaId.iftar);
    final expected =
        '${iftar.arabic}\n\n${iftar.transliteration}\n\n${iftar.translation}'
        '\n\nSource: Sunan Abi Dawud 2357';
    expect(copied, [expected]);
    expect(find.text('Copied'), findsOneWidget);
  });

  testWidgets('the About tab links to the duas', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(Brightness.light),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: AboutPage(onOpenDuas: () => opened++)),
      ),
    );

    await tester.scrollUntilVisible(find.text('Duas and intentions'), 200);
    await tester.ensureVisible(find.text('Duas and intentions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Duas and intentions'));
    expect(opened, 1);
  });
}
