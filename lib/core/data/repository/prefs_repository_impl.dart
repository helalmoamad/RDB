import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/constant/configuration/prefs_key.dart';
import '../../domin/repositories/prefs_repository.dart';

class PrefsRepositoryImpl extends PrefsRepository {
  /// مسح جميع بيانات المستخدم من SharedPreferences و FlutterSecureStorage
  Future<void> clearAll() async {
    await _preferences.clear();
    await _secureStorage.deleteAll();
    _walletTokenCache = null;
    _walletRefreshTokenCache = null;
    _sessionTokenCache = null;
    _passcodeCache = null;
  }

  PrefsRepositoryImpl._(this._preferences, this._secureStorage);

  static Future<PrefsRepositoryImpl> create(
    SharedPreferences preferences,
    FlutterSecureStorage secureStorage,
  ) async {
    final repository = PrefsRepositoryImpl._(preferences, secureStorage);
    await repository._initializeSensitiveValues();
    return repository;
  }

  final SharedPreferences _preferences;
  final FlutterSecureStorage _secureStorage;

  String? _walletTokenCache;
  String? _walletRefreshTokenCache;
  String? _sessionTokenCache;
  String? _passcodeCache;

  Future<void> _initializeSensitiveValues() async {
    _walletTokenCache = await _readWithMigration(
      PrefsKey.walletToken,
      _preferences.getString,
    );
    _walletRefreshTokenCache = await _readWithMigration(
      PrefsKey.walletRefreshToken,
      _preferences.getString,
    );
    _sessionTokenCache = await _readWithMigration(
      PrefsKey.sessionToken,
      _preferences.getString,
    );
    _passcodeCache = await _readWithMigration(
      PrefsKey.passcode,
      _preferences.getString,
    );
  }

  Future<String?> _readWithMigration(
    String key,
    String? Function(String key) legacyReader,
  ) async {
    final secureValue = await _secureStorage.read(key: key);
    if (secureValue != null) {
      return secureValue;
    }

    final legacyValue = legacyReader(key);
    if (legacyValue != null) {
      await _secureStorage.write(key: key, value: legacyValue);
      await _preferences.remove(key);
    }
    return legacyValue;
  }

  @override
  Future<bool> setUserChoosedCountryIso(String? countryIso) =>
      _preferences.setString(PrefsKey.currentCountry, countryIso!);

  @override
  Future<bool> setstepToken(String token) =>
      _preferences.setString(PrefsKey.stepToken, token);

  @override
  String? get stepToken => _preferences.getString(PrefsKey.stepToken);

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
  Future<bool> setBiometricEnrolledKey(bool value) =>
      _preferences.setBool(PrefsKey.biometricEnrolled, value);
  @override
  bool? get isBiometricEnrolled =>
      _preferences.getBool(PrefsKey.biometricEnrolled);

  @override
  Future<bool> setWalletToken(String token) async {
    try {
      if (token.isEmpty) {
        await _secureStorage.delete(key: PrefsKey.walletToken);
      } else {
        await _secureStorage.write(key: PrefsKey.walletToken, value: token);
      }
      await _preferences.remove(PrefsKey.walletToken);
      _walletTokenCache = token.isEmpty ? null : token;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> setWalletRefreshToken(String token) async {
    try {
      if (token.isEmpty) {
        await _secureStorage.delete(key: PrefsKey.walletRefreshToken);
      } else {
        await _secureStorage.write(
          key: PrefsKey.walletRefreshToken,
          value: token,
        );
      }
      await _preferences.remove(PrefsKey.walletRefreshToken);
      _walletRefreshTokenCache = token.isEmpty ? null : token;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> setSessionToken(String token) async {
    try {
      if (token.isEmpty) {
        await _secureStorage.delete(key: PrefsKey.sessionToken);
      } else {
        await _secureStorage.write(key: PrefsKey.sessionToken, value: token);
      }
      await _preferences.remove(PrefsKey.sessionToken);
      _sessionTokenCache = token.isEmpty ? null : token;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  String? get walletToken => _walletTokenCache;

  @override
  String? get walletRefreshToken => _walletRefreshTokenCache;

  @override
  DateTime? get walletTokenExpiresAt {
    final raw = _preferences.getString(PrefsKey.walletTokenExpiresAt);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  @override
  Future<bool> setWalletTokenExpiresAt(DateTime? expiresAt) {
    if (expiresAt == null) {
      return _preferences.remove(PrefsKey.walletTokenExpiresAt);
    }
    return _preferences.setString(
      PrefsKey.walletTokenExpiresAt,
      expiresAt.toIso8601String(),
    );
  }

  @override
  int? get switchShownAtMs => _preferences.getInt(PrefsKey.switchShownAt);

  @override
  Future<bool> setSwitchShownAtMs(int? millisSinceEpoch) {
    if (millisSinceEpoch == null) {
      return _preferences.remove(PrefsKey.switchShownAt);
    }
    return _preferences.setInt(PrefsKey.switchShownAt, millisSinceEpoch);
  }

  @override
  String? get sessionToken => _sessionTokenCache;

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

  @override
  String? get passcode => _passcodeCache;

  @override
  Future<bool> setPasscode(String passcode) async {
    try {
      if (passcode.isEmpty) {
        await _secureStorage.delete(key: PrefsKey.passcode);
      } else {
        await _secureStorage.write(key: PrefsKey.passcode, value: passcode);
      }
      await _preferences.remove(PrefsKey.passcode);
      _passcodeCache = passcode.isEmpty ? null : passcode;
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  bool? get shouldShowPin => _preferences.getBool(PrefsKey.shouldShowPin);

  @override
  Future<bool> setShouldShowPin(bool value) =>
      _preferences.setBool(PrefsKey.shouldShowPin, value);

  @override
  bool? get isFaceLoginEnabled =>
      _preferences.getBool(PrefsKey.faceLoginEnabled);

  @override
  Future<bool> setFaceLoginEnabled(bool value) =>
      _preferences.setBool(PrefsKey.faceLoginEnabled, value);

  @override
  bool? get isAccountActive => _preferences.getBool(PrefsKey.isAccountActive);

  @override
  Future<bool> setIsAccountActive(bool value) =>
      _preferences.setBool(PrefsKey.isAccountActive, value);

  @override
  bool? get isTwoFactorEnabled =>
      _preferences.getBool(PrefsKey.isTwoFactorEnabled);

  @override
  Future<bool> setIsTwoFactorEnabled(bool value) =>
      _preferences.setBool(PrefsKey.isTwoFactorEnabled, value);

  @override
  bool? get isKycVerification =>
      _preferences.getBool(PrefsKey.isKycVerification);

  @override
  Future<bool> setIsKycVerification(bool value) =>
      _preferences.setBool(PrefsKey.isKycVerification, value);

  @override
  int get pinFailedAttempts =>
      _preferences.getInt(PrefsKey.pinFailedAttempts) ?? 0;

  @override
  Future<bool> setPinFailedAttempts(int count) =>
      _preferences.setInt(PrefsKey.pinFailedAttempts, count);

  @override
  int get pinLockoutLevel => _preferences.getInt(PrefsKey.pinLockoutLevel) ?? 0;

  @override
  Future<bool> setPinLockoutLevel(int level) =>
      _preferences.setInt(PrefsKey.pinLockoutLevel, level);

  @override
  int get pinLockoutUntilMs =>
      _preferences.getInt(PrefsKey.pinLockoutUntil) ?? 0;

  @override
  Future<bool> setPinLockoutUntilMs(int timestampMs) =>
      _preferences.setInt(PrefsKey.pinLockoutUntil, timestampMs);

  @override
  bool? get shouldShowSwitch => _preferences.getBool(PrefsKey.shouldShowSwitch);

  @override
  Future<bool> setShouldShowSwitch(bool value) =>
      _preferences.setBool(PrefsKey.shouldShowSwitch, value);
}
