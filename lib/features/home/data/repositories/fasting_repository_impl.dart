import 'package:fasomo/features/home/data/datasources/fasting_local_data_source.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class FastingRepositoryImpl implements FastingRepository {
  new({required this.localDataSource});
  final FastingLocalDataSource localDataSource;

  @override
  HijriDateInfo getCurrentHijriDate(String languageCode) {
    return localDataSource.getCurrentHijriDate(languageCode);
  }

  @override
  List<FastingDay> getUpcomingFastingDays(String languageCode) {
    return localDataSource.getUpcomingFastingDays(languageCode);
  }
}
