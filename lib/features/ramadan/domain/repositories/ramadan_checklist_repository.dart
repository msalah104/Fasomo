import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/features/ramadan/domain/entities/ramadan_checklist.dart';

/// The daily Ramadan checklists, kept on the device: the single place they
/// are read and saved.
abstract interface class RamadanChecklistRepository {
  /// The checklist of the local day [date]; an empty one when nothing was
  /// saved for it.
  Result<RamadanChecklist, StorageFailure> checklistFor(DateTime date);

  /// Saves [checklist] for its day, replacing what was there.
  Future<Result<void, StorageFailure>> save(RamadanChecklist checklist);
}
