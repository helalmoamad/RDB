import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyOtpSignInUseCase
    implements
        UseCase<VerifyOtpSignUpAndInResponseModel, VerifyOtpSignInParams> {
  VerifyOtpSignInUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> call(
    VerifyOtpSignInParams params,
  ) async {
    return repository.verifyOtpSignIn(params.map);
  }
}

class VerifyOtpSignInParams {
  String sessionInfo;
  String otp;
  String action;
  String phone;
  int? msegatId;
  String? provider;
  String? platform;
  String? deviceId;
  Map<String, dynamic>? deviceInfo;

  VerifyOtpSignInParams({
    required this.sessionInfo,
    required this.otp,
    required this.phone,
    required this.action,
    this.msegatId,
    this.provider,
    this.platform,
    this.deviceId,
    this.deviceInfo,
  });

  Map<String, dynamic> get map {
    final data = <String, dynamic>{
      "otpCode": otp,
      "phoneNumber": "+$phone",
      "action": action,
      "platform": platform,
      "deviceId": deviceId,
      "deviceInfo": deviceInfo,
    };
    if (provider == "msegat") {
      data["msegatId"] = msegatId;
    } else {
      data["sessionInfo"] = sessionInfo;
    }
    return data;
  }
}
