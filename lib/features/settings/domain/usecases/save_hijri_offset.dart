import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

class SaveHijriOffset
    implements UseCase<Future<Result<void, StorageFailure>>, HijriOffset> {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  Future<Result<void, StorageFailure>> call(HijriOffset offset) =>
      repository.saveHijriOffset(offset);
}
