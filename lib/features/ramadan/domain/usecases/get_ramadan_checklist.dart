import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/repositories/ramadan_checklist_repository.dart';

/// The checklist of one local day.
class GetRamadanChecklist
    implements UseCase<Result<RamadanChecklist, StorageFailure>, DateTime> {
  const new(this.repository);

  final RamadanChecklistRepository repository;

  @override
  Result<RamadanChecklist, StorageFailure> call(DateTime date) =>
      repository.checklistFor(date);
}
