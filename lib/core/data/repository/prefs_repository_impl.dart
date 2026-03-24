import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constant/configuration/prefs_key.dart';
import '../../domin/repositories/prefs_repository.dart';

class PrefsRepositoryImpl extends PrefsRepository {
  PrefsRepositoryImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<bool> setUserChoosedCountryIso(String? countryIso) =>
      _preferences.setString(PrefsKey.currentCountry, countryIso!);

  @override
  String? get userChoosedCountryIso =>
      _preferences.getString(PrefsKey.currentCountry);

  @override
  Future<bool> setEmail(String? email) =>
      _preferences.setString(PrefsKey.email, email!);
  @override
  Future<bool> setPhoto(String? photo) =>
      _preferences.setString(PrefsKey.photo, photo!);
  @override
  Future<bool> setMemberSince(String? memberSince) =>
      _preferences.setString(PrefsKey.memberSince, memberSince!);

  @override
  Future<bool> setWalletToken(String token) =>
      _preferences.setString(PrefsKey.walletToken, token);

  @override
  String? get walletToken => _preferences.getString(PrefsKey.walletToken);

  @override
  Future<bool> setTheme(ThemeMode themeMode) =>
      _preferences.setString(PrefsKey.theme, themeMode.name);

  @override
  String? get fcmTokenId => _preferences.getString(PrefsKey.fcmTokenId);
  @override
  String? get fcmMarketTokenId =>
      _preferences.getString(PrefsKey.fcmMarketTokenId);
  /* @override
  String? get alaaWebForCall => _preferences.getString("alaa");*/
  @override
  Future<bool> setFcmTokenId(String fcmTokenId) =>
      _preferences.setString(PrefsKey.fcmTokenId, fcmTokenId);
  @override
  Future<bool> setFcmMarketTokenId(String fcmMarketTokenId) =>
      _preferences.setString(PrefsKey.fcmMarketTokenId, fcmMarketTokenId);

  /* @override
  Future<bool> setAlaaWebForCall(String url) =>
      _preferences.setString("alaa", url);*/

  @override
  String? get myPhoneNumber => _preferences.getString(PrefsKey.phoneNumber);
  @override
  String? get email => _preferences.getString(PrefsKey.email);
  @override
  String? get photo => _preferences.getString(PrefsKey.photo);
  @override
  String? get memberSince => _preferences.getString(PrefsKey.memberSince);

  @override
  Future<bool> setPhoneNumber(String phoneNumber) =>
      _preferences.setString(PrefsKey.phoneNumber, phoneNumber);

  @override
  Future<bool> clearVerificationId() =>
      _preferences.remove(PrefsKey.verificationId);

  @override
  Future<bool> setsessionInfo(String verificationId) =>
      _preferences.setString(PrefsKey.verificationId, verificationId);

  @override
  String? get sessionInfo => _preferences.getString(PrefsKey.verificationId);

  @override
  String? get otpCode => _preferences.getString(PrefsKey.otpCode);

  @override
  Future<bool> setOtpCode(String otpCode) =>
      _preferences.setString(PrefsKey.otpCode, otpCode);

  @override
  bool? get isVerifiedPhone => _preferences.getBool(PrefsKey.verifiedPhone);

  @override
  Future<bool> setVerifiedPhone(bool verifiedPhone) =>
      _preferences.setBool(PrefsKey.verifiedPhone, verifiedPhone);

  @override
  String? get countryIso => _preferences.getString('countryIso');

  @override
  Future<bool> setCountryIso(String? countryIso) =>
      _preferences.setString('countryIso', countryIso!);

  @override
  String? get myUserId => _preferences.getString(PrefsKey.userMarketId);

  @override
  Future<bool> setUserId(String id) =>
      _preferences.setString(PrefsKey.userMarketId, id);

  @override
  String? get userName => _preferences.getString(PrefsKey.marketName);

  @override
  Future<bool> setUserName(String name) =>
      _preferences.setString(PrefsKey.marketName, name);

  @override
  Future<bool> addFcmToken(String fcmToken) {
    List<String> tokens = [];

    tokens.add(fcmToken);
    return _preferences.setStringList(PrefsKey.fcmToken, tokens);
  }

  @override
  List<String> get getFcmTokens =>
      _preferences.getStringList(PrefsKey.fcmToken) ?? [];

  @override
  Future<bool> clearTokenForMarket() {
    return _preferences.remove(PrefsKey.marketToken);
  }

  @override
  Future<bool> setTimerForOtpRunning(bool isRunning) =>
      _preferences.setBool(PrefsKey.isTimerRunningId, isRunning);
  @override
  bool? get isTimerForOtpRunning =>
      _preferences.getBool(PrefsKey.isTimerRunningId);
  @override
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable) {
    return _preferences.setInt(
      PrefsKey.userCountryIsAvailable,
      userCountryAvailable,
    );
  }

  @override
  int? get userCountryIsAvailable =>
      _preferences.getInt(PrefsKey.userCountryIsAvailable);

  @override
  String? get language => _preferences.getString(PrefsKey.language);

  @override
  Future<bool> setLanguage(String? language) {
    return _preferences.setString(PrefsKey.language, language!);
  }

  @override
  bool? get isTokenExpired => _preferences.getBool(PrefsKey.tokenExpired);

  @override
  Future<bool> setTokenExpired(bool tokenExpired) =>
      _preferences.setBool(PrefsKey.tokenExpired, tokenExpired);

  @override
  Future<bool> setIsCearteWallet(bool isCreate) =>
      _preferences.setBool(PrefsKey.createWallet, isCreate);

  @override
  bool? get isCreateWallet => _preferences.getBool(PrefsKey.createWallet);
  @override
  bool? get isVerifiedPhonePeforeExpiredToken =>
      _preferences.getBool(PrefsKey.verifiedPhonePeforeExpiredToken);
  @override
  Future<bool> setVerifiedPhonePeforeExpiredToken(
    bool verifiedPhonePeforeExpiredToken,
  ) => _preferences.setBool(
    PrefsKey.verifiedPhonePeforeExpiredToken,
    verifiedPhonePeforeExpiredToken,
  );

  @override
  bool? get onMessageRun => _preferences.getBool(PrefsKey.onMessageRun);
  @override
  bool? get isRequestNotificationPermission =>
      _preferences.getBool(PrefsKey.requestNotificationPermission);
}
