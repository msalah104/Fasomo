import 'package:fasomo/core/presentation/numerals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ar'));

  test('Arabic dates and times use Western digits', () {
    pinWesternDigits();

    final date = DateTime(2026, 11, 2, 15, 43);
    expect(DateFormat.MMMd('ar').format(date), '2 نوفمبر');
    expect(DateFormat.jm('ar').format(date), contains('3:43'));
  });
}
