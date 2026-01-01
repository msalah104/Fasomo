import '../../../../core/usecases/usecase.dart';
import '../entities/hijri_date_info.dart';
import '../repositories/fasting_repository.dart';

class GetCurrentHijriDate implements UseCase<HijriDateInfo, String> {
  final FastingRepository repository;

  GetCurrentHijriDate(this.repository);

  @override
  HijriDateInfo call(String languageCode) {
    return repository.getCurrentHijriDate(languageCode);
  }
}
