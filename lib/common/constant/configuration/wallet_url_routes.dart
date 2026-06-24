import 'package:flutter_dotenv/flutter_dotenv.dart';

extension ScopeApi on String {
  //String get _api => 'api';

  //String get _currentVersion => 'v1';
  //  String get _Version10 => 'v10';

  String authScope() => 'auth/phone/$this';
}

abstract class WalletEndPoints {
  static final loginWithIdTokenEP = 'login-with-id-token'.authScope();
  static const createWalletEP = "wallets";
  static const setPasscodeEP = "sessions/passcode/set";
  static const changePasscodeEP = "sessions/passcode/change";
  static const currenciesEP = "currencies";
  static const updateProfileEP = 'users/me';
  static final sendOtpEP = "send-otp".authScope();
  static final reSendOtpEP = "resend-otp".authScope();
  static final verifyEP = "verify".authScope();
  static final completeSession = "auth/session/complete";
  static final refreshTokenEP = "auth/refresh";
  static final switchToAppEP = "sessions/switch-to-app";
  static final sessionsStepPasscodeVerifyEP = "sessions/step/passcode/verify";
  static final sessionsPasscodeVerifyEP = "sessions/passcode/verify";
  static const passkeyListEP = "sessions/passkey/list";

  // إعادة تعيين رمز المرور — مجموعة idle-lock (access token).
  static const resetPasscodeInitEP = "auth/reset-passcode/init";
  static const resetPasscodeSendOtpEP = "auth/reset-passcode/send-otp";
  static const resetPasscodeVerifyOtpEP = "auth/reset-passcode/verify-otp";
  static const resetPasscodeQuestionsEP = "auth/reset-passcode/questions";
  static const resetPasscodeAnswersEP = "auth/reset-passcode/answers";
  static const resetPasscodeCompleteEP = "auth/reset-passcode/complete";

  // إعادة تعيين رمز المرور — مجموعة mid-login step (stepToken).
  static const resetPasscodeStepInitEP = "auth/reset-passcode/step/init";
  static const resetPasscodeStepQuestionsEP =
      "auth/reset-passcode/step/questions";
  static const resetPasscodeStepAnswersEP = "auth/reset-passcode/step/answers";
  static const resetPasscodeStepCompleteEP =
      "auth/reset-passcode/step/complete";

  //static final registerEP = "users/phone/register";
  static String walletBalanceEP(String assetId) =>
      "wallets/my/balances/$assetId";
  static const checkoutEP = "merchant/checkout";

  /// إرسال توكن FCM للباك.
  static const sendFcmEP = "send/fcm";
}

abstract class WalletUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['WALLET_URL']!;
}
