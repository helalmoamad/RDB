import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import 'package:rdb/common/constant/configuration/wallet_url_routes.dart';
import 'package:rdb/core/api/methods/detect_server.dart';
import 'package:rdb/features/authentication/data/models/login_to_wallet_model.dart';
import '../../../../core/api/client_config.dart';
import '../../../../core/api/methods/get.dart';
import '../../../../core/api/methods/post.dart';

import '../models/get_user_country_response_model.dart';

import '../models/send_otp_response_model.dart';
import '../models/verify_otp_sign_up_and_in_response_model.dart';

@injectable
class AuthRemoteDatasource {
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
}
