import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/passcode_verify_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyStepasscodeUseCase
    implements UseCase<PasscodeVerifyModel, VerifyPasscodeParams> {
  VerifyStepasscodeUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, PasscodeVerifyModel>> call(
    VerifyPasscodeParams params,
  ) async {
    return repository.verifyStepPasscode(params.map);
  }
}

class VerifyPasscodeParams {
  String passcode; // start with +

  VerifyPasscodeParams({required this.passcode});
  Map<String, dynamic> get map => {"passcode": passcode};
}
