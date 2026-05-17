part of 'auth_bloc.dart';

enum CreateUserStatus { init, loading, success, failure }

enum SendOtpStatus { init, loading, success, failure }

//enum VerifyOtpSignUpStatus { init, loading, success, failure }

enum VerifyOtpSignInStatus { init, loading, success, failure }

enum UpdateUserProfileStatus { init, loading, success, failure }

enum VerifyOtpFromGuestStatus { init, loading, success, failure }

enum GetCustomerCountryStatus { loading, success, failure }

class AuthState {
  const AuthState({
    this.sendOtpStatus = SendOtpStatus.init,
    this.walletUser,
    this.countryName,
    this.signInErrorMessage,
    this.sendOtpError,
    this.signUpErrorMessage,
    this.updateUserProfileError,
    this.getUserCountryResponseModel,

    // this.verifyOtpSignUpStatus = VerifyOtpSignUpStatus.init,
    this.verifyOtpSignInStatus = VerifyOtpSignInStatus.init,
    this.updateUserProfileStatus = UpdateUserProfileStatus.init,
    this.verifyOtpFromGuestStatus = VerifyOtpFromGuestStatus.init,
    this.getCustomerCountryStatus = GetCustomerCountryStatus.loading,
  });

  final SendOtpStatus sendOtpStatus;

  //final VerifyOtpSignUpStatus verifyOtpSignUpStatus;
  final VerifyOtpSignInStatus verifyOtpSignInStatus;
  final UpdateUserProfileStatus updateUserProfileStatus;
  final VerifyOtpFromGuestStatus verifyOtpFromGuestStatus;

  final GetCustomerCountryStatus getCustomerCountryStatus;

  final User? walletUser;
  final GetUserCountryResponseModel? getUserCountryResponseModel;
  final String? signInErrorMessage;
  final String? signUpErrorMessage;
  final String? updateUserProfileError;

  final String? sendOtpError;
  final String? countryName;
  AuthState copyWith({
    final SendOtpStatus? sendOtpStatus,
    final GetUserCountryResponseModel? getUserCountryResponseModel,
    final String? signInErrorMessage,
    final String? countryName,

    final GetCustomerCountryStatus? getCustomerCountryStatus,

    final String? signUpErrorMessage,
    final String? updateUserProfileError,
    final String? sendOtpError,

    final User? walletUser,

    // final VerifyOtpSignUpStatus? verifyOtpSignUpStatus,
    final VerifyOtpSignInStatus? verifyOtpSignInStatus,
    final UpdateUserProfileStatus? updateUserProfileStatus,
    final VerifyOtpFromGuestStatus? verifyOtpFromGuestStatus,
  }) {
    return AuthState(
      countryName: countryName ?? this.countryName,
      sendOtpError: sendOtpError ?? this.sendOtpError,
      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      getUserCountryResponseModel:
          getUserCountryResponseModel ?? this.getUserCountryResponseModel,
      signUpErrorMessage: signUpErrorMessage ?? this.signUpErrorMessage,
      signInErrorMessage: signInErrorMessage ?? this.signInErrorMessage,
      updateUserProfileError:
          updateUserProfileError ?? this.updateUserProfileError,
      walletUser: walletUser ?? this.walletUser,
      getCustomerCountryStatus:
          getCustomerCountryStatus ?? this.getCustomerCountryStatus,
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
