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

import '../models/reset_passcode_models.dart';
import '../models/send_otp_response_model.dart';
import '../models/verify_otp_sign_up_and_in_response_model.dart';

/// تبديل mock تدفّق إعادة تعيين رمز المرور (لاختبار الواجهة بلا backend).
/// **اجعلها `false` عند ربط الباك الفعلي.**
const bool kResetPasscodeMock = false;

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

  // ───────────── إعادة تعيين رمز المرور ─────────────
  // midLogin=false → idle-lock (access token)؛ midLogin=true → step (stepToken).

  ServerName _resetServer(bool midLogin) =>
      midLogin ? ServerName.passcode : ServerName.wallet;

  // تأخير الـ mock (ليظهر shimmer الأزرار بوضوح أثناء الاختبار).
  static const Duration _mockDelay = Duration(milliseconds: 1500);

  Future<ResetInitResponse> resetPasscodeInit({required bool midLogin}) async {
    if (kResetPasscodeMock) {
      await Future.delayed(_mockDelay);
      // الفرع الافتراضي للاختبار: أسئلة (غير موثّق). لاختبار القفل/الوجه بدّل هنا.
      return const ResetInitResponse(isVerified: false);
    }
    return PostClient<ResetInitResponse>(
      serverName: _resetServer(midLogin),
      requestPrams: RequestConfig<ResetInitResponse>(
        endpoint: midLogin
            ? WalletEndPoints.resetPasscodeStepInitEP
            : WalletEndPoints.resetPasscodeInitEP,
        data: const <String, dynamic>{},
        response: ResponseValue<ResetInitResponse>(
          fromJson: (r) => ResetInitResponse.fromJson(r),
        ),
      ),
    )();
  }

  Future<ResetSendOtpResponse> resetPasscodeSendOtp(
    Map<String, dynamic> params,
  ) async {
    if (kResetPasscodeMock) {
      await Future.delayed(_mockDelay);
      return const ResetSendOtpResponse(ok: true, sessionInfo: 'mock');
    }
    return PostClient<ResetSendOtpResponse>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<ResetSendOtpResponse>(
        endpoint: WalletEndPoints.resetPasscodeSendOtpEP,
        data: params,
        response: ResponseValue<ResetSendOtpResponse>(
          fromJson: (r) => ResetSendOtpResponse.fromJson(r),
        ),
      ),
    )();
  }

  Future<ResetVerifyOtpResponse> resetPasscodeVerifyOtp(
    Map<String, dynamic> params,
  ) async {
    if (kResetPasscodeMock) {
      await Future.delayed(_mockDelay);
      return const ResetVerifyOtpResponse(ok: true);
    }
    return PostClient<ResetVerifyOtpResponse>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<ResetVerifyOtpResponse>(
        endpoint: WalletEndPoints.resetPasscodeVerifyOtpEP,
        data: params,
        response: ResponseValue<ResetVerifyOtpResponse>(
          fromJson: (r) => ResetVerifyOtpResponse.fromJson(r),
        ),
      ),
    )();
  }

  Future<ResetQuestionsResponse> resetPasscodeQuestions({
    required bool midLogin,
  }) async {
    if (kResetPasscodeMock) {
      await Future.delayed(_mockDelay);
      return _mockQuestions();
    }
    return GetClient<ResetQuestionsResponse>(
      serverName: _resetServer(midLogin),
      requestPrams: RequestConfig<ResetQuestionsResponse>(
        endpoint: midLogin
            ? WalletEndPoints.resetPasscodeStepQuestionsEP
            : WalletEndPoints.resetPasscodeQuestionsEP,
        response: ResponseValue<ResetQuestionsResponse>(
          fromJson: (r) => ResetQuestionsResponse.fromJson(r),
        ),
      ),
    )();
  }

  Future<ResetAnswersResponse> resetPasscodeAnswers(
    Map<String, dynamic> params, {
    required bool midLogin,
  }) async {
    if (kResetPasscodeMock) {
      await Future.delayed(_mockDelay);
      // نجاح افتراضي للاختبار. لاختبار الفشل/القفل بدّل القيم هنا.
      return const ResetAnswersResponse(
        success: true,
        attemptsRemaining: 2,
        resetToken: 'mock-reset-token',
      );
    }
    return PostClient<ResetAnswersResponse>(
      serverName: _resetServer(midLogin),
      requestPrams: RequestConfig<ResetAnswersResponse>(
        endpoint: midLogin
            ? WalletEndPoints.resetPasscodeStepAnswersEP
            : WalletEndPoints.resetPasscodeAnswersEP,
        data: params,
        response: ResponseValue<ResetAnswersResponse>(
          fromJson: (r) => ResetAnswersResponse.fromJson(r),
        ),
      ),
    )();
  }

  Future<ResetCompleteResponse> resetPasscodeComplete(
    Map<String, dynamic> params, {
    required bool midLogin,
  }) async {
    if (kResetPasscodeMock) {
      await Future.delayed(_mockDelay);
      return const ResetCompleteResponse(success: true);
    }
    return PostClient<ResetCompleteResponse>(
      serverName: _resetServer(midLogin),
      requestPrams: RequestConfig<ResetCompleteResponse>(
        endpoint: midLogin
            ? WalletEndPoints.resetPasscodeStepCompleteEP
            : WalletEndPoints.resetPasscodeCompleteEP,
        data: params,
        response: ResponseValue<ResetCompleteResponse>(
          fromJson: (r) => ResetCompleteResponse.fromJson(r),
        ),
      ),
    )();
  }

  // أسئلة تجريبية (3) لاختبار العرض الديناميكي وإرسال optionId.
  ResetQuestionsResponse _mockQuestions() => const ResetQuestionsResponse(
    attemptsRemaining: 2,
    questions: [
      ResetQuestion(
        id: 'q-last-login',
        text: 'Do You Remember Your Last Login ?',
        options: [
          ResetQuestionOption(id: 'hours', label: 'Hours Ago'),
          ResetQuestionOption(id: 'days', label: 'Days Ago'),
          ResetQuestionOption(id: 'weeks', label: 'Weeks Ago'),
          ResetQuestionOption(id: 'months', label: 'Months Ago'),
          ResetQuestionOption(id: 'dunno', label: "I Don't Remember"),
        ],
      ),
      ResetQuestion(
        id: 'q-account-age',
        text: 'How Long Ago Did You Create Your Account With Us?',
        options: [
          ResetQuestionOption(id: 'days', label: 'Days Ago'),
          ResetQuestionOption(id: 'weeks', label: 'Weeks Ago'),
          ResetQuestionOption(id: 'months', label: 'Months Ago'),
          ResetQuestionOption(id: 'years', label: 'Years Ago'),
          ResetQuestionOption(id: 'dunno', label: "I Don't Remember"),
        ],
      ),
      ResetQuestion(
        id: 'q-last-tx-type',
        text: 'What Was Your Last Transaction?',
        options: [
          ResetQuestionOption(id: 'deposit', label: 'Deposit'),
          ResetQuestionOption(id: 'transfer', label: 'Transfer'),
          ResetQuestionOption(id: 'payment', label: 'Payment'),
          ResetQuestionOption(id: 'dunno', label: "I Don't Remember"),
        ],
      ),
    ],
  );

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
    GetClient<List<PasskeyModel>> getPasskeyList =
        GetClient<List<PasskeyModel>>(
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

  Future<bool> switchToApp() {
    PostClient<bool> switchToApp = PostClient<bool>(
      serverName: ServerName.wallet,
      requestPrams: RequestConfig<bool>(
        endpoint: WalletEndPoints.switchToAppEP,
        response: ResponseValue<bool>(returnValueOnSuccess: true),
      ),
    );
    return switchToApp();
  }

  Future<VerifyOtpSignUpAndInResponseModel> refreshToken(String refreshToken) {
    PostClient<VerifyOtpSignUpAndInResponseModel> refresh =
        PostClient<VerifyOtpSignUpAndInResponseModel>(
          serverName: ServerName.wallet,
          requestPrams: RequestConfig<VerifyOtpSignUpAndInResponseModel>(
            endpoint: WalletEndPoints.refreshTokenEP,
            data: {"refreshToken": refreshToken},
            response: ResponseValue<VerifyOtpSignUpAndInResponseModel>(
              fromJson: (response) =>
                  VerifyOtpSignUpAndInResponseModel.fromJson(response),
            ),
          ),
        );
    return refresh();
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
