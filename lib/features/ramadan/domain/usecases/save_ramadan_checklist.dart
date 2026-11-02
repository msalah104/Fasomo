import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';
import 'package:fasomo/features/ramadan/domain/repositories/ramadan_checklist_repository.dart';

/// Saves one day's checklist.
class SaveRamadanChecklist
    implements UseCase<Future<Result<void, StorageFailure>>, RamadanChecklist> {
  const new(this.repository);

  final RamadanChecklistRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(RamadanChecklist checklist) =>
      repository.save(checklist);
}
