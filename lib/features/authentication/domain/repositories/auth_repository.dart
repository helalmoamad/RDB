import 'package:dartz/dartz.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/get_user_country_response_model.dart';

import '../../data/models/send_otp_response_model.dart';

import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, GetUserCountryResponseModel>> getUserCountry();

  Future<Either<Failure, LoginToWalletModel>> loginToWallet(
    Map<String, dynamic> params,
  );

  Future<Either<Failure, SendOtpResponseModel>> sendOtp(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, bool>> createWallet();

  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignIn(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(
    Map<String, dynamic> params,
  );
}
