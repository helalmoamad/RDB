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
  static const currenciesEP = "currencies";
  static const updateProfileEP = 'users/me';
  static final sendOtpEP = "send-otp".authScope();
  static final reSendOtpEP = "resend-otp".authScope();
  static final verifyEP = "verify".authScope();
  //static final registerEP = "users/phone/register";
  static String walletBalanceEP(String assetId) =>
      "wallets/my/balances/$assetId";
  static const checkoutEP = "merchant/checkout";
}

abstract class WalletUrls {
  static String get baseUrl => _baseUrlDev;

  static Uri get baseUri => Uri.parse(_baseUrlDev);

  static set setBaseUrl(String url) => _baseUrlDev = url;

  static String _baseUrlDev = dotenv.env['WALLET_URL']!;
}
