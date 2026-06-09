import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class SwitchToAppUsecase implements UseCase<bool, NoParams> {
  SwitchToAppUsecase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return repository.switchToApp();
  }
}
