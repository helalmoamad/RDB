import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpSignUpUseCase
    implements
        UseCase<VerifyOtpSignUpAndInResponseModel, VerifyOtpSignUpParams> {
  VerifyOtpSignUpUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
    VerifyOtpSignUpParams params,
  ) async {
    return repository.verifyOtpSignUp(params.map);
  }
}

class VerifyOtpSignUpParams {
  String sessionInfo;
  String otp;
  String phone;

  VerifyOtpSignUpParams({
    required this.sessionInfo,
    required this.otp,
    required this.phone,
  });
  Map<String, dynamic> get map => {
    "otpCode": otp,
    "phoneNumber": "+$phone",
    "sessionInfo": sessionInfo,
  };
}
