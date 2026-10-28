import 'package:fasomo/features/calendar/data/datasources/calendar_local_data_source.dart';
import 'package:fasomo/features/calendar/domain/entities/calendar_day.dart';
import 'package:fasomo/features/calendar/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  new({required this.localDataSource});
  final CalendarLocalDataSource localDataSource;

  @override
  List<CalendarDay> getHijriMonth(int month, int year) {
    return localDataSource.getHijriMonth(month, year);
  }
}
