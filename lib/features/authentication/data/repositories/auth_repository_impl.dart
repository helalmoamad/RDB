import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/features/authentication/data/models/get_user_country_response_model.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:rdb/features/authentication/data/models/send_otp_response_model.dart';
import 'package:rdb/features/authentication/data/models/verify_otp_sign_up_and_in_response_model.dart';
import '../../../../core/api/handling_exception.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository with HandlingExceptionRequest {
  AuthRepositoryImpl(this.dataSource);

  final AuthRemoteDatasource dataSource;

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
  Future<Either<Failure, VerifyOtpSignUpAndInResponseModel>> verifyOtpSignUp(
    Map<String, dynamic> params,
  ) {
    return handlingExceptionRequest(
      tryCall: () => dataSource.verifyOtpSignUp(params),
    );
  }

  @override
  Future<Either<Failure, GetUserCountryResponseModel>> getUserCountry() {
    return handlingExceptionRequest(tryCall: dataSource.getUserCountry);
  }
}
