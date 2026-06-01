import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/core/error/failures.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/data/models/passkey_model.dart';
import 'package:rdb/features/authentication/domain/repositories/auth_repository.dart';

@injectable
class GetPasskeyListUseCase implements UseCase<List<PasskeyModel>, NoParams> {
  final AuthRepository repository;

  GetPasskeyListUseCase(this.repository);

  @override
  Future<Either<Failure, List<PasskeyModel>>> call(NoParams params) {
    return repository.getPasskeyList();
  }
}
