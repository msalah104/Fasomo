import '../../../../core/usecases/usecase.dart';
import '../entities/fasting_day.dart';
import '../repositories/fasting_repository.dart';

class GetUpcomingFastingDays implements UseCase<List<FastingDay>, String> {
  final FastingRepository repository;

  GetUpcomingFastingDays(this.repository);

  @override
  List<FastingDay> call(String languageCode) {
    return repository.getUpcomingFastingDays(languageCode);
  }
}
