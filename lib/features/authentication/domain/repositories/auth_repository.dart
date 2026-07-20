import 'package:dartz/dartz.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:rdb/features/authentication/data/models/passcode_verify_model.dart';
import 'package:rdb/features/authentication/data/models/passkey_model.dart';
import 'package:rdb/features/authentication/data/models/user_profile_model.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/get_user_country_response_model.dart';

import '../../data/models/send_otp_response_model.dart';

import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../../data/models/reset_passcode_models.dart';

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

  /// إرسال توكن FCM للباك.
  Future<Either<Failure, bool>> sendFcmToken(Map<String, dynamic> params);
  Future<Either<Failure, bool>> removeFcmToken(Map<String, dynamic> params);
  // ── إعادة تعيين رمز المرور ──
  Future<Either<Failure, ResetInitResponse>> resetPasscodeInit({
    required bool midLogin,
  });
  Future<Either<Failure, ResetSendOtpResponse>> resetPasscodeSendOtp(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, ResetVerifyOtpResponse>> resetPasscodeVerifyOtp(
    Map<String, dynamic> params,
  );
  Future<Either<Failure, ResetQuestionsResponse>> resetPasscodeQuestions({
    required bool midLogin,
  });
  Future<Either<Failure, ResetAnswersResponse>> resetPasscodeAnswers(
    Map<String, dynamic> params, {
    required bool midLogin,
  });
  Future<Either<Failure, ResetCompleteResponse>> resetPasscodeComplete(
    Map<String, dynamic> params, {
    required bool midLogin,
    String? faceStepToken,
  });
  Future<Either<Failure, ReverifyStartResponse>> reverifyFaceStart(
    String challengeId, {
    required bool midLogin,
  });
  Future<Either<Failure, ReverifyVerifyResponse>> reverifyFaceVerify({
    required String challengeId,
    required String liveFaceImageData,
    required bool midLogin,
  });
  /*Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(
    Map<String, dynamic> params,
  );*/
}
