import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class ChangePasscodeUseCase {
  final AuthRepository repository;
  ChangePasscodeUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    String currentPasscode,
    String newPasscode,
  ) async {
    return repository.changePasscode(currentPasscode, newPasscode);
  }
}
