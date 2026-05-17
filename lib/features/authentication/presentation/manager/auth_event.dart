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

  const VerifyOtpSignInEvent({
    required this.sessionInfo,
    required this.otp,
    required this.phone,
    required this.action,
  });
  @override
  List<Object?> get props => [otp, sessionInfo, phone];
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

class CreateWalletEvent extends AuthEvent {
  const CreateWalletEvent();
  @override
  List<Object?> get props => [];
}
