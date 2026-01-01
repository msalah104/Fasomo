import '../../domain/entities/calendar_day.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_data_source.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource localDataSource;

  CalendarRepositoryImpl({required this.localDataSource});

  @override
  List<CalendarDay> getHijriMonth(int month, int year) {
    return localDataSource.getHijriMonth(month, year);
  }
}
