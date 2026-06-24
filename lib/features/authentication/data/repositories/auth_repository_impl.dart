import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/get_user_country_response_model.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:rdb/features/authentication/data/models/passcode_verify_model.dart';
import 'package:rdb/features/authentication/data/models/passkey_model.dart';
import 'package:rdb/features/authentication/data/models/reset_passcode_models.dart';
import 'package:rdb/features/authentication/data/models/send_otp_response_model.dart';
import 'package:rdb/features/authentication/data/models/user_profile_model.dart';
import 'package:rdb/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../../../../core/api/handling_exception.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository with HandlingExceptionRequest {
  @override
  Future<Either<Failure, UserProfileModel>> getUserProfile() {
    return handlingExceptionRequest(tryCall: () => dataSource.getUserProfile());
  }

  AuthRepositoryImpl(this.dataSource);

  final AuthRemoteDatasource dataSource;

  @override
  Future<Either<Failure, bool>> sendFcmToken(String token) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.sendFcmToken(token),
    );
  }

  @override
  Future<Either<Failure, bool>> updateUserProfile(Map<String, dynamic> params) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.updateUserProfile(params),
    );
  }

  @override
  Future<Either<Failure, LoginToWalletModel>> loginToWallet(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.loginToWallet(params),
    );
  }

  @override
  Future<Either<Failure, bool>> createWallet() {
    return handlingExceptionRequest(tryCall: () => dataSource.createWallet());
  }

  @override
  Future<Either<Failure, SendOtpResponseModel>> sendOtp(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(tryCall: () => dataSource.sendOtp(params));
  }

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignIn(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.verifyOtpSignIn(params),
    );
  }

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> completeSession(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.completeSession(params),
    );
  }

  @override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> refreshToken(
    String refreshToken,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.refreshToken(refreshToken),
    );
  }

  @override
  Future<Either<Failure, bool>> switchToApp() {
    return handlingExceptionRequest(tryCall: () => dataSource.switchToApp());
  }

  @override
  Future<Either<Failure, PasscodeVerifyModel>> verifyStepPasscode(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.sessionsStepPasscodeVerify(params),
    );
  }

  @override
  Future<Either<Failure, bool>> sessionsPasscodeVerify(String passcode) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.sessionsPasscodeVerify(passcode),
    );
  }

  @override
  Future<Either<Failure, bool>> setPasscode(String passcode) async {
    return handlingExceptionRequest(
      tryCall: () => dataSource.setPasscode(passcode),
    );
  }

  @override
  Future<Either<Failure, bool>> changePasscode(
    String currentPasscode,
    String newPasscode,
  ) async {
    return handlingExceptionRequest(
      tryCall: () => dataSource.changePasscode(currentPasscode, newPasscode),
    );
  }

  /*@override
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.verifyOtpSignUp(params),
    );
  }
*/
  @override
  Future<Either<Failure, List<PasskeyModel>>> getPasskeyList() {
    return handlingExceptionRequest(tryCall: () => dataSource.getPasskeyList());
  }

  @override
  Future<Either<Failure, GetUserCountryResponseModel>> getUserCountry() {
    return handlingExceptionRequest(tryCall: dataSource.getUserCountry);
  }

  // ── إعادة تعيين رمز المرور ──
  @override
  Future<Either<Failure, ResetInitResponse>> resetPasscodeInit({
    required bool midLogin,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.resetPasscodeInit(midLogin: midLogin),
    );
  }

  @override
  Future<Either<Failure, ResetSendOtpResponse>> resetPasscodeSendOtp(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.resetPasscodeSendOtp(params),
    );
  }

  @override
  Future<Either<Failure, ResetVerifyOtpResponse>> resetPasscodeVerifyOtp(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.resetPasscodeVerifyOtp(params),
    );
  }

  @override
  Future<Either<Failure, ResetQuestionsResponse>> resetPasscodeQuestions({
    required bool midLogin,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.resetPasscodeQuestions(midLogin: midLogin),
    );
  }

  @override
  Future<Either<Failure, ResetAnswersResponse>> resetPasscodeAnswers(
    Map<String, dynamic> params, {
    required bool midLogin,
  }) {
    return handlingExceptionRequest(
      tryCall: () =>
          dataSource.resetPasscodeAnswers(params, midLogin: midLogin),
    );
  }

  @override
  Future<Either<Failure, ResetCompleteResponse>> resetPasscodeComplete(
    Map<String, dynamic> params, {
    required bool midLogin,
  }) {
    return handlingExceptionRequest(
      tryCall: () =>
          dataSource.resetPasscodeComplete(params, midLogin: midLogin),
    );
  }

  @override
  Future<Either<Failure, ReverifyStartResponse>> reverifyFaceStart(
    String challengeId,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.reverifyFaceStart(challengeId),
    );
  }

  @override
  Future<Either<Failure, ReverifyVerifyResponse>> reverifyFaceVerify({
    required String challengeId,
    required String liveFaceImageData,
  }) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.reverifyFaceVerify(
        challengeId: challengeId,
        liveFaceImageData: liveFaceImageData,
      ),
    );
  }
}
