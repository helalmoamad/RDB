import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/get_user_country_response_model.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:rdb/features/authentication/data/models/passcode_verify_model.dart';
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
  Future<Either<Failure, GetUserCountryResponseModel>> getUserCountry() {
    return handlingExceptionRequest(tryCall: dataSource.getUserCountry);
  }
}
