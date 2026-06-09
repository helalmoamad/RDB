part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class SendOtpEvent extends AuthEvent {
  final int isViaWhatsApp;
  final String phone;
  final bool isSignUp;
  final bool isResend;
  const SendOtpEvent({
    required this.phone,
    required this.isViaWhatsApp,
    required this.isSignUp,
    required this.isResend,
  });
  @override
  List<Object?> get props => [phone, isViaWhatsApp, isResend, isSignUp];
}

class VerifyOtpSignInEvent extends AuthEvent {
  final String sessionInfo;
  final String otp;
  final String phone;
  final String action;
  final int? msegatId;
  final String? provider;
  final String? platform;
  final String? deviceId;
  final Map<String, dynamic>? deviceInfo;

  const VerifyOtpSignInEvent({
    required this.sessionInfo,
    required this.otp,
    required this.phone,
    required this.action,
    this.msegatId,
    this.provider,
    this.platform,
    this.deviceId,
    this.deviceInfo,
  });
  @override
  List<Object?> get props => [
    otp,
    sessionInfo,
    phone,
    action,
    msegatId,
    provider,
    platform,
    deviceId,
    deviceInfo,
  ];
}

class VerifyStepPasscodeEvent extends AuthEvent {
  final String passcode;

  const VerifyStepPasscodeEvent({required this.passcode});
  @override
  List<Object?> get props => [passcode];
}

class ResetAllData extends AuthEvent {
  const ResetAllData();
  @override
  List<Object?> get props => [];
}

class SaveErrorSigneInVerify extends AuthEvent {
  final String error;

  const SaveErrorSigneInVerify({required this.error});
  @override
  List<Object?> get props => [error];
}

class GetUserProfileEvent extends AuthEvent {
  const GetUserProfileEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUserProfileEvent extends AuthEvent {
  const UpdateUserProfileEvent({required this.fullName});

  final String fullName;

  @override
  List<Object?> get props => [fullName];
}

/*class VerifyOtpSignUpEvent extends AuthEvent {
  final String sessionInfo;
  final String otp;
  final String phone;

  const VerifyOtpSignUpEvent({
    required this.sessionInfo,
    required this.otp,
    required this.phone,
  });
  @override
  List<Object?> get props => [otp, phone, sessionInfo];
}*/

/*class LoginToWalletEvent extends AuthEvent {
  final String? otpIdToken;
  final String? phone;
  final String? name;
  const LoginToWalletEvent({this.otpIdToken, this.phone, this.name});
  @override
  List<Object?> get props => [otpIdToken, phone, name];
}*/

class GetUserCountryEvent extends AuthEvent {
  const GetUserCountryEvent();

  @override
  List<Object?> get props => [];
}

class GetPasskeyListEvent extends AuthEvent {
  const GetPasskeyListEvent();

  @override
  List<Object?> get props => [];
}

class CreateWalletEvent extends AuthEvent {
  const CreateWalletEvent();
  @override
  List<Object?> get props => [];
}

class RefreshTokenEvent extends AuthEvent {
  const RefreshTokenEvent();
  @override
  List<Object?> get props => [];
}

/// يفحص صلاحية التوكن اعتمادًا على expiresAt، ويطلق RefreshTokenEvent
/// فقط إذا كان التوكن منتهيًا أو قاربَ على الانتهاء.
class EnsureWalletTokenValidEvent extends AuthEvent {
  const EnsureWalletTokenValidEvent();
  @override
  List<Object?> get props => [];
}

/// الرجوع من جلسة الويب (LOCKED) إلى التطبيق عبر POST /sessions/switch-to-app.
class SwitchToAppEvent extends AuthEvent {
  const SwitchToAppEvent();
  @override
  List<Object?> get props => [];
}

/// إعادة تعيين حالة التبديل إلى init (تُستدعى عند ظهور طبقة التبديل).
class ResetSwitchToAppEvent extends AuthEvent {
  const ResetSwitchToAppEvent();
  @override
  List<Object?> get props => [];
}

class VerifySessionPasscodeEvent extends AuthEvent {
  final String passcode;
  const VerifySessionPasscodeEvent(this.passcode);
  @override
  List<Object?> get props => [passcode];
}

class SetPasscodeEvent extends AuthEvent {
  final String passcode;
  const SetPasscodeEvent(this.passcode);
  @override
  List<Object?> get props => [passcode];
}

class ChangePasscodeEvent extends AuthEvent {
  final String currentPasscode;
  final String newPasscode;
  const ChangePasscodeEvent(this.currentPasscode, this.newPasscode);
  @override
  List<Object?> get props => [currentPasscode, newPasscode];
}
