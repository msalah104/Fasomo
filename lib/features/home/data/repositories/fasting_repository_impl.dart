import '../../domain/entities/fasting_day.dart';
import '../../domain/entities/hijri_date_info.dart';
import '../../domain/repositories/fasting_repository.dart';
import '../datasources/fasting_local_data_source.dart';

class FastingRepositoryImpl implements FastingRepository {
  final FastingLocalDataSource localDataSource;

  FastingRepositoryImpl({required this.localDataSource});

  @override
  HijriDateInfo getCurrentHijriDate(String languageCode) {
    return localDataSource.getCurrentHijriDate(languageCode);
  }

  @override
  List<FastingDay> getUpcomingFastingDays(String languageCode) {
    return localDataSource.getUpcomingFastingDays(languageCode);
  }
}
