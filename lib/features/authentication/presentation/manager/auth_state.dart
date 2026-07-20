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

/// [faceRequired] = 409: الأسئلة محظورة على المستخدم الموثّق (الوجه إلزامي،
/// بلا احتياط). وصولها يعني أن العميل وجّه المستخدم للمسار الخطأ.
enum ResetQuestionsStatus { init, loading, success, failure, faceRequired }

enum ResetAnswersStatus { init, loading, success, failure }

/// [proofRejected] = 403: برهان غير صالح / منتهٍ / مُستهلَك (أحادي الاستخدام).
/// المخرج إعادة البدء من `init` بتحدٍّ جديد، لا الخروج من التدفّق.
enum ResetCompleteStatus { init, loading, success, failure, proofRejected }

/// حالة بدء جلسة التحقّق بالوجه (start).
enum ReverifyStartStatus { init, loading, success, failure }

/// حالة التحقّق بالوجه (step-up) في تدفّق إعادة تعيين رمز المرور.
///
/// - [failed] فشل قابل لإعادة المحاولة على نفس التحدّي (`liveness` / `mismatch`).
/// - [lockedOut] نفدت محاولات التحدّي (`locked_out`) — **نهائي لهذا التحدّي**،
///   وبلا احتياط أسئلة للمستخدم الموثّق. المخرج الوحيد تحدٍّ جديد من `init`.
/// - [expired] انتهت صلاحية التحدّي (410) — يلزم تحدٍّ جديد من `init`.
/// - [unavailable] لا يمكن التحقّق بالوجه لهذا الحساب إطلاقًا
///   (`NO_ENROLLED_SELFIE`) — لا إعادة محاولة ولا تحدٍّ جديد يفيد، والمخرج
///   الخروج من التدفّق بتوجيه المستخدم لمراجعة الدعم.
/// - [error] خطأ نقل/خادم غير مصنّف.
enum ReverifyFaceStatus {
  init,
  loading,
  passed,
  failed,
  lockedOut,
  expired,
  unavailable,
  error,
}

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
    this.faceStepToken,
    this.resetLockedUntil,
    this.resetLockoutHours,
    this.resetError,
    this.resetSessionExpired = false,
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

  /// برهان مسار **الأسئلة**: `resetToken` العائد من `answers`، ويُرسَل في جسم
  /// `complete`.
  final String? resetToken;

  /// برهان مسار **الوجه**: التوكن أحادي الاستخدام العائد من نجاح التحقّق
  /// بالوجه، ويُرسَل في ترويسة `X-Face-Step-Token` على `complete`.
  ///
  /// مفصول عمدًا عن [resetToken]: الباك يسمّي كليهما `stepToken` في استجابته،
  /// وهما مختلفان عن session stepToken الخاص بالجلسة — ودليل التكامل يفرد
  /// جدولًا للتحذير من خلطها. دمجهما في حقل واحد يعني إرسال البرهان في المكان
  /// الخطأ عند تبديل المسارات.
  final String? faceStepToken;
  final String? resetLockedUntil;
  final int? resetLockoutHours;
  final String? resetError;

  /// 401 على أي نداء `step/*` = انتهت صلاحية session stepToken (عمره 10 دقائق).
  ///
  /// الخروج لشاشة الـ passcode لا يفيد هنا: تلك الشاشة تستخدم التوكن الميت نفسه،
  /// فيعلق المستخدم. المخرج الوحيد إعادة الدخول من البداية (هاتف → OTP).
  ///
  /// يُصفَّر مع [resetError] في كل `copyWith` (لا `??`) كي لا يبقى عالقًا في
  /// الـ AuthBloc المفرد بعد معالجته.
  final bool resetSessionExpired;
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
    final String? faceStepToken,
    final String? resetLockedUntil,
    final int? resetLockoutHours,
    final String? resetError,
    final bool? resetSessionExpired,
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
      faceStepToken: faceStepToken ?? this.faceStepToken,
      resetLockedUntil: resetLockedUntil ?? this.resetLockedUntil,
      resetLockoutHours: resetLockoutHours ?? this.resetLockoutHours,
      resetError: resetError,
      // كالـ resetError: بلا `??` — علَم لحظي يُستهلَك مرّة ثم يزول، وإلا بقي
      // عالقًا في الـ singleton فأعاد توجيه المستخدم في تدفّق لاحق.
      resetSessionExpired: resetSessionExpired ?? false,
      reverifyFaceStatus: reverifyFaceStatus ?? this.reverifyFaceStatus,
      reverifyStartStatus: reverifyStartStatus ?? this.reverifyStartStatus,
      reverifySessionId: reverifySessionId ?? this.reverifySessionId,
    );
  }
}
