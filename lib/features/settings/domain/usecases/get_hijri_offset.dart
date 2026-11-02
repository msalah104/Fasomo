import 'package:fasomo/core/calendar/hijri_offset.dart';
import 'package:fasomo/core/error/failures.dart';
import 'package:fasomo/core/error/result.dart';
import 'package:fasomo/core/usecases/usecase.dart';
import 'package:fasomo/features/settings/domain/repositories/settings_repository.dart';

class GetHijriOffset
    implements UseCase<Result<HijriOffset, StorageFailure>, NoParams> {
  const new(this.repository);

  final SettingsRepository repository;

  @override
  Result<HijriOffset, StorageFailure> call(NoParams params) =>
      repository.getHijriOffset();
}
