import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/home/domain/entities/fasting_day.dart';
import 'package:fasomo/features/home/domain/repositories/fasting_repository.dart';

class GetUpcomingFastingDays implements UseCase<List<FastingDay>, String> {
  new(this.repository);
  final FastingRepository repository;

  @override
  List<FastingDay> call(String languageCode) {
    return repository.getUpcomingFastingDays(languageCode);
  }
}
