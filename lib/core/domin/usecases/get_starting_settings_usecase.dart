import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/domin/repositories/common_use_repository.dart';
import 'package:rdb/core/error/failures.dart';
import 'package:rdb/core/use_case/use_case.dart';

/// `GET api/v1/mobile/home/startingSettings` — الجسم الخام بلا تخزين مؤقت.
@injectable
class GetStartingSettingsUseCase extends UseCase<Object?, NoParams> {
  final CommonUseRepository repository;

  GetStartingSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, Object?>> call(NoParams params) {
    return repository.getStartingSettings();
  }
}
