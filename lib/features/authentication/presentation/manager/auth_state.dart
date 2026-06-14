part of 'auth_bloc.dart';

enum CreateUserStatus { init, loading, success, failure }

enum SendOtpStatus { init, loading, success, failure }

//enum VerifyOtpSignUpStatus { init, loading, success, failure }

enum VerifyOtpSignInStatus { init, loading, success, failure }

enum UpdateUserProfileStatus { init, loading, success, failure }

enum VerifyOtpFromGuestStatus { init, loading, success, failure }

enum GetCustomerCountryStatus { loading, success, failure }

enum GetPasskeyListStatus { init, loading, success, failure }

enum VerifyPasscodeStatus { init, loading, success, failure }

enum SetPasscodeStatus { init, loading, success, failure }

enum ChangePasscodeStatus { init, loading, success, failure }

enum SwitchToAppStatus { init, loading, success, failure }

// إعادة تعيين رمز المرور
enum ResetInitStatus { init, loading, success, failure }

enum ResetSendOtpStatus { init, loading, success, failure }

enum ResetVerifyOtpStatus { init, loading, success, failure }

enum ResetQuestionsStatus { init, loading, success, failure }

enum ResetAnswersStatus { init, loading, success, failure }

enum ResetCompleteStatus { init, loading, success, failure }

/// حالة بدء جلسة التحقّق بالوجه (start).
enum ReverifyStartStatus { init, loading, success, failure }

/// حالة التحقّق بالوجه (step-up) في تدفّق إعادة تعيين رمز المرور.
enum ReverifyFaceStatus { init, loading, passed, failed, error }

class AuthState {
  const AuthState({
    this.sendOtpStatus = SendOtpStatus.init,
    this.walletUser,
    this.countryName,
    this.signInErrorMessage,
    this.setPasscodeStatus = SetPasscodeStatus.init,
    this.changePasscodeStatus = ChangePasscodeStatus.init,
    this.switchToAppStatus = SwitchToAppStatus.init,
    this.sendOtpError,
    this.signUpErrorMessage,
    this.verifyPasscodeStatus = VerifyPasscodeStatus.init,
    this.passkeyListStatus = GetPasskeyListStatus.init,
    this.passkeys,
    this.passkeyListError,
    this.updateUserProfileError,
    this.getUserCountryResponseModel,
    this.otpMsegatId,
    this.otpProvider,
    // this.verifyOtpSignUpStatus = VerifyOtpSignUpStatus.init,
    this.verifyOtpSignInStatus = VerifyOtpSignInStatus.init,
    this.updateUserProfileStatus = UpdateUserProfileStatus.init,
    this.verifyOtpFromGuestStatus = VerifyOtpFromGuestStatus.init,
    this.getCustomerCountryStatus = GetCustomerCountryStatus.loading,
    // إعادة تعيين رمز المرور
    this.resetInitStatus = ResetInitStatus.init,
    this.resetSendOtpStatus = ResetSendOtpStatus.init,
    this.resetVerifyOtpStatus = ResetVerifyOtpStatus.init,
    this.resetQuestionsStatus = ResetQuestionsStatus.init,
    this.resetAnswersStatus = ResetAnswersStatus.init,
    this.resetCompleteStatus = ResetCompleteStatus.init,
    this.resetInitResult,
    this.resetQuestions = const [],
    this.resetAttemptsRemaining,
    this.resetToken,
    this.resetLockedUntil,
    this.resetLockoutHours,
    this.resetError,
    this.reverifyFaceStatus = ReverifyFaceStatus.init,
    this.reverifyStartStatus = ReverifyStartStatus.init,
    this.reverifySessionId,
  });

  final SendOtpStatus sendOtpStatus;

  //final VerifyOtpSignUpStatus verifyOtpSignUpStatus;
  final VerifyOtpSignInStatus verifyOtpSignInStatus;
  final SetPasscodeStatus setPasscodeStatus;
  final ChangePasscodeStatus changePasscodeStatus;
  final SwitchToAppStatus switchToAppStatus;
  final UpdateUserProfileStatus updateUserProfileStatus;
  final VerifyOtpFromGuestStatus verifyOtpFromGuestStatus;
  final GetPasskeyListStatus passkeyListStatus;
  final VerifyPasscodeStatus verifyPasscodeStatus;

  final GetCustomerCountryStatus getCustomerCountryStatus;

  final User? walletUser;
  final GetUserCountryResponseModel? getUserCountryResponseModel;
  final String? signInErrorMessage;
  final String? signUpErrorMessage;
  final String? updateUserProfileError;
  final String? passkeyListError;
  final List<PasskeyModel>? passkeys;

  final String? sendOtpError;
  final String? countryName;
  final int? otpMsegatId;
  final String? otpProvider;

  // إعادة تعيين رمز المرور
  final ResetInitStatus resetInitStatus;
  final ResetSendOtpStatus resetSendOtpStatus;
  final ResetVerifyOtpStatus resetVerifyOtpStatus;
  final ResetQuestionsStatus resetQuestionsStatus;
  final ResetAnswersStatus resetAnswersStatus;
  final ResetCompleteStatus resetCompleteStatus;
  final ResetInitResponse? resetInitResult;
  final List<ResetQuestion> resetQuestions;
  final int? resetAttemptsRemaining;
  final String? resetToken;
  final String? resetLockedUntil;
  final int? resetLockoutHours;
  final String? resetError;
  final ReverifyFaceStatus reverifyFaceStatus;
  final ReverifyStartStatus reverifyStartStatus;

  /// sessionId العائد من start — يُرسَل في verify التالي.
  final String? reverifySessionId;

  AuthState copyWith({
    final SendOtpStatus? sendOtpStatus,
    final GetUserCountryResponseModel? getUserCountryResponseModel,
    final String? signInErrorMessage,
    final String? countryName,
    final GetCustomerCountryStatus? getCustomerCountryStatus,
    final GetPasskeyListStatus? passkeyListStatus,
    final String? passkeyListError,
    final List<PasskeyModel>? passkeys,
    final VerifyPasscodeStatus? verifyPasscodeStatus,
    final SetPasscodeStatus? setPasscodeStatus,
    final ChangePasscodeStatus? changePasscodeStatus,
    final SwitchToAppStatus? switchToAppStatus,
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
    final ResetInitStatus? resetInitStatus,
    final ResetSendOtpStatus? resetSendOtpStatus,
    final ResetVerifyOtpStatus? resetVerifyOtpStatus,
    final ResetQuestionsStatus? resetQuestionsStatus,
    final ResetAnswersStatus? resetAnswersStatus,
    final ResetCompleteStatus? resetCompleteStatus,
    final ResetInitResponse? resetInitResult,
    final List<ResetQuestion>? resetQuestions,
    final int? resetAttemptsRemaining,
    final String? resetToken,
    final String? resetLockedUntil,
    final int? resetLockoutHours,
    final String? resetError,
    final ReverifyFaceStatus? reverifyFaceStatus,
    final ReverifyStartStatus? reverifyStartStatus,
    final String? reverifySessionId,
  }) {
    return AuthState(
      countryName: countryName ?? this.countryName,
      sendOtpError: sendOtpError ?? this.sendOtpError,
      setPasscodeStatus: setPasscodeStatus ?? this.setPasscodeStatus,
      changePasscodeStatus: changePasscodeStatus ?? this.changePasscodeStatus,
      switchToAppStatus: switchToAppStatus ?? this.switchToAppStatus,

      sendOtpStatus: sendOtpStatus ?? this.sendOtpStatus,
      passkeyListStatus: passkeyListStatus ?? this.passkeyListStatus,
      passkeyListError: passkeyListError ?? this.passkeyListError,
      passkeys: passkeys ?? this.passkeys,
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
      resetInitStatus: resetInitStatus ?? this.resetInitStatus,
      resetSendOtpStatus: resetSendOtpStatus ?? this.resetSendOtpStatus,
      resetVerifyOtpStatus: resetVerifyOtpStatus ?? this.resetVerifyOtpStatus,
      resetQuestionsStatus: resetQuestionsStatus ?? this.resetQuestionsStatus,
      resetAnswersStatus: resetAnswersStatus ?? this.resetAnswersStatus,
      resetCompleteStatus: resetCompleteStatus ?? this.resetCompleteStatus,
      resetInitResult: resetInitResult ?? this.resetInitResult,
      resetQuestions: resetQuestions ?? this.resetQuestions,
      resetAttemptsRemaining:
          resetAttemptsRemaining ?? this.resetAttemptsRemaining,
      resetToken: resetToken ?? this.resetToken,
      resetLockedUntil: resetLockedUntil ?? this.resetLockedUntil,
      resetLockoutHours: resetLockoutHours ?? this.resetLockoutHours,
      resetError: resetError,
      reverifyFaceStatus: reverifyFaceStatus ?? this.reverifyFaceStatus,
      reverifyStartStatus: reverifyStartStatus ?? this.reverifyStartStatus,
      reverifySessionId: reverifySessionId ?? this.reverifySessionId,
    );
  }
}
