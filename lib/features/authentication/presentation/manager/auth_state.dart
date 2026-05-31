part of 'auth_bloc.dart';

enum CreateUserStatus { init, loading, success, failure }

enum SendOtpStatus { init, loading, success, failure }

//enum VerifyOtpSignUpStatus { init, loading, success, failure }

enum VerifyOtpSignInStatus { init, loading, success, failure }

enum UpdateUserProfileStatus { init, loading, success, failure }

enum VerifyOtpFromGuestStatus { init, loading, success, failure }

enum GetCustomerCountryStatus { loading, success, failure }

enum VerifyPasscodeStatus { init, loading, success, failure }

enum SetPasscodeStatus { init, loading, success, failure }

enum ChangePasscodeStatus { init, loading, success, failure }

class AuthState {
  const AuthState({
    this.sendOtpStatus = SendOtpStatus.init,
    this.walletUser,
    this.countryName,
    this.signInErrorMessage,
    this.setPasscodeStatus = SetPasscodeStatus.init,
    this.changePasscodeStatus = ChangePasscodeStatus.init,
    this.sendOtpError,
    this.signUpErrorMessage,
    this.verifyPasscodeStatus = VerifyPasscodeStatus.init,
    this.updateUserProfileError,
    this.getUserCountryResponseModel,
    this.otpMsegatId,
    this.otpProvider,
    // this.verifyOtpSignUpStatus = VerifyOtpSignUpStatus.init,
    this.verifyOtpSignInStatus = VerifyOtpSignInStatus.init,
    this.updateUserProfileStatus = UpdateUserProfileStatus.init,
    this.verifyOtpFromGuestStatus = VerifyOtpFromGuestStatus.init,
    this.getCustomerCountryStatus = GetCustomerCountryStatus.loading,
  });

  final SendOtpStatus sendOtpStatus;

  //final VerifyOtpSignUpStatus verifyOtpSignUpStatus;
  final VerifyOtpSignInStatus verifyOtpSignInStatus;
  final SetPasscodeStatus setPasscodeStatus;
  final ChangePasscodeStatus changePasscodeStatus;
  final UpdateUserProfileStatus updateUserProfileStatus;
  final VerifyOtpFromGuestStatus verifyOtpFromGuestStatus;
  final VerifyPasscodeStatus verifyPasscodeStatus;

  final GetCustomerCountryStatus getCustomerCountryStatus;

  final User? walletUser;
  final GetUserCountryResponseModel? getUserCountryResponseModel;
  final String? signInErrorMessage;
  final String? signUpErrorMessage;
  final String? updateUserProfileError;

  final String? sendOtpError;
  final String? countryName;
  final int? otpMsegatId;
  final String? otpProvider;

  AuthState copyWith({
    final SendOtpStatus? sendOtpStatus,
    final GetUserCountryResponseModel? getUserCountryResponseModel,
    final String? signInErrorMessage,
    final String? countryName,
    final GetCustomerCountryStatus? getCustomerCountryStatus,
    final VerifyPasscodeStatus? verifyPasscodeStatus,
    final SetPasscodeStatus? setPasscodeStatus,
    final ChangePasscodeStatus? changePasscodeStatus,
    final String? signUpErrorMessage,
    final String? updateUserProfileError,
    final String? sendOtpError,

    final User? walletUser,

    final int? otpMsegatId,
    final String? otpProvider,
    // final VerifyOtpSignUpStatus? verifyOtpSignUpStatus,
    final VerifyOtpSignInStatus? verifyOtpSignInStatus,
    final UpdateUserProfileStatus? updateUserProfileStatus,
    final VerifyOtpFromGuestStatus? verifyOtpFromGuestStatus,
  }) {
    return AuthState(
      countryName: countryName ?? this.countryName,
      sendOtpError: sendOtpError ?? this.sendOtpError,
      setPasscodeStatus: setPasscodeStatus ?? this.setPasscodeStatus,
      changePasscodeStatus: changePasscodeStatus ?? this.changePasscodeStatus,

      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      getUserCountryResponseModel:
          getUserCountryResponseModel ?? this.getUserCountryResponseModel,
      signUpErrorMessage: signUpErrorMessage ?? this.signUpErrorMessage,
      signInErrorMessage: signInErrorMessage ?? this.signInErrorMessage,

      updateUserProfileError:
          updateUserProfileError ?? this.updateUserProfileError,
      walletUser: walletUser ?? this.walletUser,
      verifyPasscodeStatus: verifyPasscodeStatus ?? this.verifyPasscodeStatus,
      getCustomerCountryStatus:
          getCustomerCountryStatus ?? this.getCustomerCountryStatus,
      otpMsegatId: otpMsegatId ?? this.otpMsegatId,
      otpProvider: otpProvider ?? this.otpProvider,
      //verifyOtpSignUpStatus:
      //    verifyOtpSignUpStatus ?? this.verifyOtpSignUpStatus,
      verifyOtpSignInStatus:
          verifyOtpSignInStatus ?? this.verifyOtpSignInStatus,
      updateUserProfileStatus:
          updateUserProfileStatus ?? this.updateUserProfileStatus,
      verifyOtpFromGuestStatus:
          verifyOtpFromGuestStatus ?? this.verifyOtpFromGuestStatus,
    );
  }
}
