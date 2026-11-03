import 'dart:convert';

import 'package:fasomo/core/widget/home_widget_contract.dart';
import 'package:fasomo/core/widget/home_widget_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final snapshot = HomeWidgetSnapshot(
    generatedFor: DateTime(2026, 11, 2),
    isRightToLeft: true,
    staleText: 'stale',
    days: [
      HomeWidgetDay(
        date: DateTime(2026, 11, 2),
        hijriText: 'h1',
        gregorianText: 'g1',
        nextFastText: 'n1',
        isFastingDay: true,
      ),
      HomeWidgetDay(
        date: DateTime(2026, 11, 3),
        hijriText: 'h2',
        gregorianText: 'g2',
        nextFastText: 'n2',
        isFastingDay: false,
      ),
    ],
  );

  test('dateKey is the zero-padded local calendar day', () {
    expect(
      HomeWidgetContract.dateKey(DateTime(2026, 1, 5, 23, 59)),
      '2026-01-05',
    );
    expect(HomeWidgetContract.dateKey(DateTime(987, 12, 31)), '0987-12-31');
  });

  test('encodes the snapshot with the keys the native widgets read', () {
    // Spelled out rather than built from the constants, so renaming a key
    // here without the Kotlin and Swift mirrors fails this test.
    expect(jsonDecode(HomeWidgetContract.encode(snapshot)), {
      'v': 1,
      'generatedFor': '2026-11-02',
      'rtl': true,
      'staleText': 'stale',
      'days': {
        '2026-11-02': {
          'hijri': 'h1',
          'gregorian': 'g1',
          'nextFast': 'n1',
          'fastingDay': true,
        },
        '2026-11-03': {
          'hijri': 'h2',
          'gregorian': 'g2',
          'nextFast': 'n2',
          'fastingDay': false,
        },
      },
    });
    expect(HomeWidgetContract.storageKey, 'fasomo_widget_snapshot');
  });

  test('refreshes at each midnight up to the one that makes it stale', () {
    expect(HomeWidgetContract.refreshTimes(snapshot), [
      DateTime(2026, 11, 3),
      DateTime(2026, 11, 4),
    ]);
  });

  test('refreshTimes stay on local midnight across a month end', () {
    final lastDay = HomeWidgetSnapshot(
      generatedFor: DateTime(2026, 12, 31),
      isRightToLeft: false,
      staleText: '',
      days: [
        HomeWidgetDay(
          date: DateTime(2026, 12, 31),
          hijriText: '',
          gregorianText: '',
          nextFastText: '',
          isFastingDay: false,
        ),
      ],
    );

    expect(HomeWidgetContract.refreshTimes(lastDay), [DateTime(2027)]);
  });
}
