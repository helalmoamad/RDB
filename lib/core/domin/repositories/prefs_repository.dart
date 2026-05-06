import 'package:flutter/material.dart';

abstract class PrefsRepository {
  String? get walletToken;

  String? get countryIso;
  String? get userChoosedCountryIso;
  String? get fcmTokenId;
  String? get email;
  String? get photo;
  String? get memberSince;
  String? get fcmMarketTokenId;

  //String? get alaaWebForCall;
  int? get userCountryIsAvailable;

  String? get myUserId;

  bool? get isVerifiedPhone;

  bool? get isVerifiedPhonePeforeExpiredToken;
  bool? get isTokenExpired;
  bool? get isRequestNotificationPermission;

  bool? get isCreateWallet;
  String? get userName;

  String? get myPhoneNumber;

  String? get language;

  String? get sessionInfo;

  String? get otpCode;
  String? get passcode;

  Future<bool> setIsCearteWallet(bool isCreate);

  Future<bool> setVerifiedPhone(bool verifiedPhone);

  Future<bool> setVerifiedPhonePeforeExpiredToken(
    bool verifiedPhonePeforeExpiredToken,
  );
  Future<bool> setTokenExpired(bool tokenExpired);
  Future<bool> setTimerForOtpRunning(bool isRunning);

  Future<bool> setLanguage(String? language);

  Future<bool> setCountryIso(String? countryIso);
  bool? get isTimerForOtpRunning;
  Future<bool> setUserChoosedCountryIso(String? countryIso);
  Future<bool> setEmail(String? email);
  Future<bool> setPhoto(String? photo);
  Future<bool> setMemberSince(String? memberSince);

  Future<bool> setsessionInfo(String verificationId);

  Future<bool> setOtpCode(String otpToken);
  Future<bool> setUserCountryIsAvailable(int userCountryAvailable);

  Future<bool> setWalletToken(String token);

  Future<bool> setPhoneNumber(String phoneNumber);

  Future<void> setFcmTokenId(String fcmTokenId);
  Future<void> setFcmMarketTokenId(String fcmMarketTokenId);

  Future<bool> setUserId(String id);

  Future<bool> setUserName(String name);

  Future<bool> setTheme(ThemeMode themeMode);

  Future<bool> addFcmToken(String fcmToken);

  List<String> get getFcmTokens;

  // Future<bool> setUser(User user);
  //
  // User? get user;

  bool? get onMessageRun;

  Future<bool> clearTokenForMarket();

  Future<bool> clearVerificationId();
  Future<bool> setPasscode(String passcode);
  bool? get shouldShowPin;
  Future<bool> setShouldShowPin(bool value);
  bool? get isFaceLoginEnabled;
  Future<bool> setFaceLoginEnabled(bool value);
  bool? get isAccountActive;
  Future<bool> setIsAccountActive(bool value);
  bool? get isTwoFactorEnabled;
  Future<bool> setIsTwoFactorEnabled(bool value);

  // PIN lockout state
  int get pinFailedAttempts;
  Future<bool> setPinFailedAttempts(int count);
  int get pinLockoutLevel;
  Future<bool> setPinLockoutLevel(int level);
  int get pinLockoutUntilMs;
  Future<bool> setPinLockoutUntilMs(int timestampMs);
}
