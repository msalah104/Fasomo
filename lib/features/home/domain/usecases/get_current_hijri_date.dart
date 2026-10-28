import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/hijri_date_info.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class GetCurrentHijriDate implements UseCase<HijriDateInfo, String> {
  new(this.repository);
  final FastingRepository repository;

  @override
  HijriDateInfo call(String languageCode) {
    return repository.getCurrentHijriDate(languageCode);
  }
}
