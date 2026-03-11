import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/send_otp_response_model.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/use_case/use_case.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendOtpUseCase implements UseCase<SendOtpResponseModel, SendOtpParams> {
  SendOtpUseCase(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, SendOtpResponseModel>> call(
    SendOtpParams params,
  ) async {
    return repository.sendOtp(params.map);
  }
}

class SendOtpParams {
  int isViaWhatsApp;
  bool isResend;
  bool isSignUp;
  String phone; // start with +

  SendOtpParams({
    required this.phone,
    required this.isSignUp,
    required this.isViaWhatsApp,
    required this.isResend,
  });
  Map<String, dynamic> get map => {
    "phoneNumber": "+$phone",
    "channel": (isViaWhatsApp == 1) ? "whatsapp" : "sms",
    "isResend": isResend,
    "type": (isSignUp) ? "signUp" : "signIn",
  };
}
