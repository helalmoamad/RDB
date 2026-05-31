import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

@injectable
class SetPasscodeUseCase {
  final AuthRepository repository;
  SetPasscodeUseCase(this.repository);

  Future<Either<Failure, bool>> call(String passcode) async {
    return repository.setPasscode(passcode);
  }
}
