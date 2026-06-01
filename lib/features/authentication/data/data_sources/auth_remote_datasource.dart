import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/common/constant/configuration/wallet_url_routes.dart';
import 'package:rdb/core/api/methods/detect_server.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import 'package:rdb/features/authentication/data/models/passcode_verify_model.dart';
import 'package:rdb/features/authentication/data/models/passkey_model.dart';
import 'package:rdb/features/authentication/data/models/user_profile_model.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/patch.dart';
import '../../../../core/api/methods/post.dart';

import '../models/get_user_country_response_model.dart';

import '../models/send_otp_response_model.dart';
import '../models/verify_otp_sign_up_and_in_response_model.dart';

@injectable
class AuthRemoteDatasource {
  Future<UserProfileModel> getUserProfile() {
    GetClient<UserProfileModel> getUserProfile = GetClient<UserProfileModel>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<UserProfileModel>(
        endpoint: WalletEndPoints.updateProfileEP,
        response: ResponseValue<UserProfileModel>(
          fromJson: (response) => UserProfileModel.fromJson(response),
        ),
      ),
    );
    return getUserProfile();
  }

  Future<bool> updateUserProfile(Map<String, dynamic> params) {
    PatchClient<bool> updateUserProfile = PatchClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.updateProfileEP,
        data: params,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return updateUserProfile();
  }

  Future<SendOtpResponseModel> sendOtp(Map<String, dynamic> params) {
    bool isResend = params['isResend'] ?? false;
    Map<String, dynamic> param = params;
    param.removeWhere((key, value) => key == 'isResend');
    PostClient<SendOtpResponseModel> sendOtp = PostClient<SendOtpResponseModel>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<SendOtpResponseModel>(
        endpoint: isResend
            ? WalletEndPoints.reSendOtpEP
            : WalletEndPoints.sendOtpEP,
        data: param,
        response: ResponseValue<SendOtpResponseModel>(
          fromJson: (response) => SendOtpResponseModel.fromJson(response),
        ),
      ),
    );
    return sendOtp();
  }

  /*Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignUp =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: WalletEndPoints.registerEP,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return verifyOtpSignUp();
  }
*/
  Future<List<PasskeyModel>> getPasskeyList() {
    GetClient<List<PasskeyModel>> getPasskeyList = GetClient<List<PasskeyModel>>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<List<PasskeyModel>>(
        endpoint: WalletEndPoints.passkeyListEP,
        response: ResponseValue<List<PasskeyModel>>(
          fromJson: (response) => (response as List<dynamic>)
              .map((item) => PasskeyModel.fromJson(item))
              .toList(),
        ),
      ),
    );
    return getPasskeyList();
  }

  Future<GetUserCountryResponseModel> getUserCountry() {
    ///// for test /////

    ////////////////////
    GetClient<GetUserCountryResponseModel> getUserCountry =
        GetClient<GetUserCountryResponseModel>(
          serverName: ServerName.location,
          requestPrams: RequestConfig<GetUserCountryResponseModel>(
            endpoint: '',
            response: ResponseValue<GetUserCountryResponseModel>(
              fromJson: (response) =>
                  GetUserCountryResponseModel.fromJson(response),
            ),
          ),
        );
    return getUserCountry();
  }

  Future<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> verifyOtpSignIn =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: WalletEndPoints.verifyEP,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return verifyOtpSignIn();
  }

  Future<LoginToWalletModel> loginToWallet(Map<String, dynamic> params) {
    PostClient<LoginToWalletModel> loginToWallet =
        PostClient<LoginToWalletModel>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<LoginToWalletModel>(
            endpoint: WalletEndPoints.loginWithIdTokenEP,
            data: params,
            extraHeaders: {
              'x-merchant-api-key': dotenv.env['Public_Api_Key'] ?? '',
            },
            response: ResponseValue<LoginToWalletModel>(
              fromJson: (response) => LoginToWalletModel.fromJson(response),
            ),
          ),
        );
    return loginToWallet();
  }

  Future<bool> createWallet() {
    PostClient<bool> createWallet = PostClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.createWalletEP,
        data: {"name": "Primary Funding Wallet"},
        queryParameters: {"subtype": "MAIN"},
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return createWallet();
  }

  Future<VerifyOtpSignUpAndInResponseModel> completeSession(
    Map<String, dynamic> params,
  ) {
    PostClient<VerifyOtpSignUpAndInResponseModel> completeSession =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: WalletEndPoints.completeSession,
            data: params,
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return completeSession();
  }

  Future<PasscodeVerifyModel> sessionsStepPasscodeVerify(
    Map<String, dynamic> params,
  ) {
    PostClient<PasscodeVerifyModel> sessionsStepPasscodeVerify =
        PostClient<PasscodeVerifyModel>(
          serverName: ServerName.passcode,
          requestPrams: RequestConfig<PasscodeVerifyModel>(
            endpoint: WalletEndPoints.sessionsStepPasscodeVerifyEP,
            data: params,
            response: ResponseValue<PasscodeVerifyModel>(
              fromJson: (response) => PasscodeVerifyModel.fromJson(response),
            ),
          ),
        );
    return sessionsStepPasscodeVerify();
  }

  Future<bool> setPasscode(String passcode) async {
    PostClient<bool> setPasscode = PostClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.setPasscodeEP,
        data: {"passcode": passcode},
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return setPasscode();
  }

  Future<bool> sessionsPasscodeVerify(String passcode) async {
    PostClient<bool> sessionsPasscodeVerify = PostClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.sessionsPasscodeVerifyEP,
        data: {"passcode": passcode},
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return sessionsPasscodeVerify();
  }

  Future<bool> changePasscode(
    String currentPasscode,
    String newPasscode,
  ) async {
    PostClient<bool> changePasscode = PostClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.changePasscodeEP,
        data: {"currentPasscode": currentPasscode, "newPasscode": newPasscode},
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return changePasscode();
  }
}
