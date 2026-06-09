import 'package:dartz/dartz.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:rdb/features/authentication/data/models/passcode_verify_model.dart';
import 'package:rdb/features/authentication/data/models/passkey_model.dart';
import 'package:rdb/features/authentication/data/models/user_profile_model.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/get_user_country_response_model.dart';

import '../../data/models/send_otp_response_model.dart';

import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserProfileModel>> getUserProfile();
  Future<Either<Failure, GetUserCountryResponseModel>> getUserCountry();

  Future<Either<Failure, bool>> updateUserProfile(Map<String, dynamic> params);

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

  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> completeSession(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> refreshToken(
    String refreshToken,
  );
  Future<Either<Failure, bool>> switchToApp();
  Future<Either<Failure, List<PasskeyModel>>> getPasskeyList();
  Future<Either<Failure, PasscodeVerifyModel>> verifyStepPasscode(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, bool>> sessionsPasscodeVerify(String passcode);
  Future<Either<Failure, bool>> setPasscode(String passcode);
  Future<Either<Failure, bool>> changePasscode(
    String currentPasscode,
    String newPasscode,
  );
  /*Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(
    Map<String, dynamic> params,
  );*/
}
