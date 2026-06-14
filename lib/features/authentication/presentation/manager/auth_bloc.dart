import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:rdb/features/authentication/data/models/get_user_country_response_model.dart';
import 'package:rdb/features/authentication/domain/entities/verify_otp_session_status.dart';
import 'package:rdb/features/authentication/domain/use_cases/complete_session_usecase.dart';
import 'package:rdb/features/authentication/data/models/passkey_model.dart';
import 'package:rdb/features/authentication/domain/use_cases/get_passkey_list_usecase.dart';
import 'package:rdb/features/authentication/domain/use_cases/get_user_profile_usecase.dart';
import 'package:rdb/features/authentication/domain/use_cases/refresh_token_usecase.dart';
import 'package:rdb/features/authentication/domain/use_cases/switch_to_app_usecase.dart';
import 'package:trydos_wallet/trydos_wallet.dart' show TrydosWallet;
import 'package:rdb/features/authentication/domain/use_cases/verify_session_passcode_usecase.dart';
import 'package:rdb/features/authentication/domain/use_cases/verify_step_passcode_usecase.dart';
import '../../domain/use_cases/set_passcode_usecase.dart';
import '../../domain/use_cases/change_passcode_usecase.dart';
// ignore: depend_on_referenced_packages
import 'package:stream_transform/stream_transform.dart';
import 'package:rdb/core/error/error_manager.dart';
import 'package:rdb/enums/status_code_type.dart';
import 'package:rdb/routes/router.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/domain/use_cases/get_user_country_usecase.dart';

import 'package:rdb/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:rdb/features/authentication/domain/use_cases/update_user_profile_usecase.dart';

import 'package:rdb/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
import 'package:rdb/features/authentication/data/models/reset_passcode_models.dart';
import 'package:rdb/features/authentication/domain/use_cases/reset_passcode_usecases.dart';
import '../../../../common/helper/show_message.dart';
import '../../../../core/domin/repositories/prefs_repository.dart';
import '../../data/models/verify_otp_sign_up_and_in_response_model.dart';

part 'auth_event.dart';

part 'auth_state.dart';

const throttleDuration = Duration(minutes: 2);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

@LazySingleton()
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    //this.createWalletUseCase,
    //this.loginToWalletUseCase,
    this.sendOtpUseCase,
    this.verifyOtpSignInUseCase,
    this.updateUserProfileUseCase,
    this.verifyStepPasscodeUseCase,
    this.verifySessionPasscodeUseCase,
    this.getUserCountryUseCase,
    this.getPasskeyListUseCase,
    this.getUserProfileUseCase,
    this.completeSessionUsecase,
    this.setPasscodeUseCase,
    this.changePasscodeUseCase,
    this.refreshTokenUsecase,
    this.switchToAppUsecase,
    this.resetInitUseCase,
    this.resetSendOtpUseCase,
    this.resetVerifyOtpUseCase,
    this.resetQuestionsUseCase,
    this.resetAnswersUseCase,
    this.resetCompleteUseCase,
    this.reverifyFaceVerifyUseCase,
    this.reverifyFaceStartUseCase,
    // this.verifyOtpSignUpUseCase,
  ) : super(const AuthState()) {
    on<AuthEvent>((event, emit) {});

    /* on<LoginToWalletEvent>(
      _onLoginToWalletEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );*/

    on<SendOtpEvent>(
      _onSendOtpEvent,
      transformer: throttleDroppable(const Duration(seconds: 10)),
    );
    on<SaveErrorSigneInVerify>(_onSaveErrorSigneInVerify);
    on<ResetAllData>(_onResetAllData);
    on<VerifyOtpSignInEvent>(_onVerifyOtpSignInEvent);

    on<UpdateUserProfileEvent>(_onUpdateUserProfileEvent);
    on<GetUserProfileEvent>(_onGetUserProfileEvent);
    on<VerifyStepPasscodeEvent>(_onVerifyStepPasscodeEvent);
    on<VerifySessionPasscodeEvent>(_onVerifySessionPasscodeEvent);
    on<SetPasscodeEvent>(_onSetPasscodeEvent);
    on<ChangePasscodeEvent>(_onChangePasscodeEvent);

    // on<VerifyOtpSignUpEvent>(_onVerifyOtpSignUpEvent);

    on<GetUserCountryEvent>(
      _onGetUserCountryEvent,
      //transformer: throttleDroppable(throttleDuration)
    );
    on<GetPasskeyListEvent>(_onGetPasskeyListEvent);
    on<RefreshTokenEvent>(_onRefreshTokenEvent);
    on<EnsureWalletTokenValidEvent>(_onEnsureWalletTokenValidEvent);
    on<SwitchToAppEvent>(_onSwitchToAppEvent);
    on<ResetSwitchToAppEvent>(_onResetSwitchToAppEvent);
    // on<CreateWalletEvent>(_onCreateWalletEvent);

    // إعادة تعيين رمز المرور
    on<ResetInitEvent>(_onResetInitEvent);
    on<ResetSendOtpEvent>(_onResetSendOtpEvent);
    on<ResetVerifyOtpEvent>(_onResetVerifyOtpEvent);
    on<ResetQuestionsEvent>(_onResetQuestionsEvent);
    on<ResetAnswersEvent>(_onResetAnswersEvent);
    on<ResetCompleteEvent>(_onResetCompleteEvent);
    on<ReverifyStartEvent>(_onReverifyStartEvent);
    on<ReverifyFaceEvent>(_onReverifyFaceEvent);
    on<ResetFlowClearEvent>(_onResetFlowClear);
  }

  FutureOr<void> _onResetFlowClear(
    ResetFlowClearEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(
      state.copyWith(
        resetInitStatus: ResetInitStatus.init,
        resetSendOtpStatus: ResetSendOtpStatus.init,
        resetVerifyOtpStatus: ResetVerifyOtpStatus.init,
        resetQuestionsStatus: ResetQuestionsStatus.init,
        resetAnswersStatus: ResetAnswersStatus.init,
        resetCompleteStatus: ResetCompleteStatus.init,
        reverifyFaceStatus: ReverifyFaceStatus.init,
        reverifyStartStatus: ReverifyStartStatus.init,
        reverifySessionId: '',
        resetQuestions: const [],
        resetToken: '',
        resetLockedUntil: '',
        resetLockoutHours: 0,
        resetAttemptsRemaining: 0,
        resetError: null,
      ),
    );
  }

  final ResetInitUseCase resetInitUseCase;
  final ResetSendOtpUseCase resetSendOtpUseCase;
  final ResetVerifyOtpUseCase resetVerifyOtpUseCase;
  final ResetQuestionsUseCase resetQuestionsUseCase;
  final ResetAnswersUseCase resetAnswersUseCase;
  final ResetCompleteUseCase resetCompleteUseCase;
  final ReverifyFaceVerifyUseCase reverifyFaceVerifyUseCase;
  final ReverifyFaceStartUseCase reverifyFaceStartUseCase;

  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpSignInUseCase verifyOtpSignInUseCase;
  final CompleteSessionUsecase completeSessionUsecase;
  final VerifyStepasscodeUseCase verifyStepPasscodeUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  //final VerifyOtpSignUpUseCase verifyOtpSignUpUseCase;
  //final CreateWalletUseCase createWalletUseCase;
  // final LoginToWalletUseCase loginToWalletUseCase;
  final GetUserCountryUseCase getUserCountryUseCase;
  final GetPasskeyListUseCase getPasskeyListUseCase;
  final VerifySessionPasscodeUseCase verifySessionPasscodeUseCase;
  final SetPasscodeUseCase setPasscodeUseCase;
  final ChangePasscodeUseCase changePasscodeUseCase;
  final RefreshTokenUsecase refreshTokenUsecase;
  final SwitchToAppUsecase switchToAppUsecase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

  /// طلب الـ refresh الجاري حاليًا (إن وُجد) — يمنع إطلاق طلب refresh آخر
  /// أثناء وجود واحد قيد التنفيذ.
  Future<bool>? _refreshInFlight;

  FutureOr<void> _onUpdateUserProfileEvent(
    UpdateUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    final nameParts = event.fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final firstName = nameParts.isEmpty ? '' : nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    emit(
      state.copyWith(
        updateUserProfileStatus: UpdateUserProfileStatus.loading,
        updateUserProfileError: '',
      ),
    );

    final response = await updateUserProfileUseCase(
      UpdateUserProfileParams(
        profilePictureUrl: _prefsRepository.photo ?? '',
        firstName: firstName,
        lastName: lastName,
      ),
    );

    response.fold(
      (failure) {
        emit(
          state.copyWith(
            updateUserProfileStatus: UpdateUserProfileStatus.failure,
            updateUserProfileError: failure.message.isEmpty
                ? 'Failed to update profile'
                : failure.message,
          ),
        );
      },
      (_) {
        _prefsRepository.setUserName(event.fullName);
        emit(
          state.copyWith(
            updateUserProfileStatus: UpdateUserProfileStatus.success,
            updateUserProfileError: '',
          ),
        );
      },
    );
  }

  FutureOr<void> _onGetUserProfileEvent(
    GetUserProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_prefsRepository.walletToken == null ||
        (_prefsRepository.shouldShowSwitch ?? false)) {
      return;
    }
    final response = await getUserProfileUseCase(NoParams());
    response.fold((failure) {}, (userProfile) {
      _prefsRepository.setUserName(
        "${userProfile.firstName} ${userProfile.lastName}",
      );
      _prefsRepository.setEmail(userProfile.email);
      _prefsRepository.setPhoneNumber(userProfile.phoneNumber);
      _prefsRepository.setPhoto(userProfile.profilePictureURL ?? '');
      _prefsRepository.setMemberSince(userProfile.createdAt);
      _prefsRepository.setVerifiedPhone(userProfile.isPhoneVerified);
      _prefsRepository.setIsAccountActive(!userProfile.isBlocked);
      _prefsRepository.setIsTwoFactorEnabled(userProfile.isTwoFactorEnabled);
      // تحديث حالة توثيق الهوية (KYC) كل مرة يُجلب فيها البروفايل.
      _prefsRepository.setIsKycVerification(
        userProfile.kycVerification.isVerified,
      );
    });
  }

  FutureOr<void> _onGetPasskeyListEvent(
    GetPasskeyListEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        passkeyListStatus: GetPasskeyListStatus.loading,
        passkeyListError: '',
      ),
    );

    final response = await getPasskeyListUseCase(NoParams());
    response.fold(
      (failure) {
        emit(
          state.copyWith(
            passkeyListStatus: GetPasskeyListStatus.failure,
            passkeyListError: failure.message.isEmpty
                ? 'Failed to load passkeys'
                : failure.message,
          ),
        );
      },
      (passkeys) {
        if (passkeys.isEmpty) {
          _prefsRepository.setBiometricEnrolledKey(false);
        } else {
          _prefsRepository.setBiometricEnrolledKey(true);
        }
        emit(
          state.copyWith(
            passkeyListStatus: GetPasskeyListStatus.success,
            passkeys: passkeys,
            passkeyListError: '',
          ),
        );
      },
    );
  }

  FutureOr<void> _onSendOtpEvent(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    _prefsRepository.clearVerificationId();
    emit(state.copyWith(sendOtpStatus: SendOtpStatus.loading));
    final response = await sendOtpUseCase(
      SendOtpParams(
        isViaWhatsApp: event.isViaWhatsApp,
        phone: event.phone,
        isResend: event.isResend,
        isSignUp: event.isSignUp,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('SendOtpEvent', l.statusCode)) {
          add(
            SendOtpEvent(
              isViaWhatsApp: event.isViaWhatsApp,
              phone: event.phone,
              isResend: event.isResend,
              isSignUp: event.isSignUp,
            ),
          );
          ErrorManager.incrementRetry('SendOtpEvent');
        }
        emit(
          state.copyWith(
            sendOtpStatus: SendOtpStatus.failure,
            sendOtpError: 'please wait some seconds and try again',
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('SendOtpEvent');
        _prefsRepository.setsessionInfo(r.sessionInfo!);
        emit(
          state.copyWith(
            sendOtpStatus: SendOtpStatus.success,
            verifyOtpFromGuestStatus: VerifyOtpFromGuestStatus.init,
            verifyOtpSignInStatus: VerifyOtpSignInStatus.init,
            otpMsegatId: r.msegatId,
            otpProvider: r.provider,
          ),
        );
      },
    );
  }

  FutureOr<void> _onVerifyStepPasscodeEvent(
    VerifyStepPasscodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verifyPasscodeStatus: VerifyPasscodeStatus.loading));
    final response = await verifyStepPasscodeUseCase(
      VerifyPasscodeParams(passcode: event.passcode),
    );
    await response.fold(
      (failure) {
        emit(
          state.copyWith(verifyPasscodeStatus: VerifyPasscodeStatus.failure),
        );
      },
      (isVerified) async {
        _prefsRepository.setSessionToken(isVerified.sessionToken);
        final response = await completeSessionUsecase(
          CompleteSessionParams(sessionToken: isVerified.sessionToken),
        );
        response.fold((l) {}, (r) {
          try {
            _prefsRepository.setUserId(r.user!.id.toString());

            _prefsRepository.setUserName(
              "${r.user?.firstName ?? ''} ${r.user?.lastName ?? ''}",
            );

            _prefsRepository.setEmail(r.user?.email ?? "");
            _prefsRepository.setPhoto(r.user?.profilePictureUrl ?? "");
            _prefsRepository.setMemberSince(
              (r.user?.createdAt ?? '').toString(),
            );
            _prefsRepository.setWalletToken(r.accessToken!.token!);
            _prefsRepository.setWalletTokenExpiresAt(r.accessToken?.expiresAt);
            _prefsRepository.setWalletRefreshToken(r.refreshToken?.token ?? "");
            _prefsRepository.setSessionToken(r.sessionToken ?? "");

            _prefsRepository.setTokenExpired(false);
            _prefsRepository.setUserId(r.user!.id.toString());

            // ignore: unrelated_type_equality_checks
            _prefsRepository.setVerifiedPhone(r.user?.isPhoneVerified ?? false);
            _prefsRepository.setPhoneNumber((r.user?.phoneNumber).toString());
            _prefsRepository.setIsAccountActive(!(r.user?.isBlocked ?? false));
            _prefsRepository.setIsTwoFactorEnabled(
              r.user?.isTwoFactorEnabled ?? false,
            );
            _prefsRepository.setVerifiedPhonePeforeExpiredToken(false);

            ////////////////////////
          } catch (error) {
            showMessage(error.toString(), hasError: true);
          }

          emit(
            state.copyWith(
              verifyOtpSignInStatus: VerifyOtpSignInStatus.success,
              walletUser: r.user,
              signInErrorMessage: r.status,
              verifyPasscodeStatus: VerifyPasscodeStatus.success,
            ),
          );
          Future.delayed(const Duration(seconds: 1), () {
            add(GetPasskeyListEvent());
          });
        });
      },
    );
  }

  FutureOr<void> _onVerifySessionPasscodeEvent(
    VerifySessionPasscodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verifyPasscodeStatus: VerifyPasscodeStatus.loading));
    final response = await verifySessionPasscodeUseCase(event.passcode);
    response.fold(
      (failure) {
        emit(
          state.copyWith(verifyPasscodeStatus: VerifyPasscodeStatus.failure),
        );
      },
      (isVerified) async {
        emit(
          state.copyWith(verifyPasscodeStatus: VerifyPasscodeStatus.success),
        );
      },
    );
  }

  /*FutureOr<void> _onLoginToWalletEvent(
    LoginToWalletEvent event,
    Emitter<AuthState> emit,
  ) async {
    final response = await loginToWalletUseCase(
      LoginToWalletParams(
        otpIdToken: event.otpIdToken,
        phone: event.phone,
        name: event.name,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('LoginToWalletEvent', l.statusCode)) {
          add(
            LoginToWalletEvent(
              otpIdToken: event.otpIdToken,
              phone: event.phone,
              name: event.name,
            ),
          );
          ErrorManager.incrementRetry('LoginToWalletEvent');
        }
      },
      (r) {
        _prefsRepository.setWalletToken(r.accessToken?.token ?? "");
        add(CreateWalletEvent());

        ErrorManager.resetRetry('LoginToWalletEvent');
      },
    );
  }*/

  /*FutureOr<void> _onCreateWalletEvent(
    CreateWalletEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (_prefsRepository.isCreateWallet ?? false) {
      //  GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
      return;
    }
    final response = await createWalletUseCase(NoParams());
    response.fold(
      (l) {
        if (l.statusCode == 409) {
          _prefsRepository.setIsCearteWallet(true);
          //  GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
          return;
        }
        if (ErrorManager.shouldRetry('CreateWalletEvent', l.statusCode)) {
          add(CreateWalletEvent());
          ErrorManager.incrementRetry('CreateWalletEvent');
          return;
        }
        //  GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
      },
      (r) {
        _prefsRepository.setIsCearteWallet(true);
        ErrorManager.resetRetry('CreateWalletEvent');
        //   GetIt.I<HomeBloc>().add(GetCurrenciesForWalletEvent());
      },
    );
  }*/

  FutureOr<void> _onVerifyOtpSignInEvent(
    VerifyOtpSignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verifyOtpSignInStatus: VerifyOtpSignInStatus.loading));

    final response = await verifyOtpSignInUseCase(
      VerifyOtpSignInParams(
        sessionInfo: event.sessionInfo,
        otp: event.otp,
        action: event.action,
        phone: event.phone,
        msegatId: event.msegatId,
        provider: event.provider,
        platform: event.platform,
        deviceId: event.deviceId,
        deviceInfo: event.deviceInfo,
      ),
    );
    await response.fold(
      (l) {
        if (ErrorManager.shouldRetry('VerifyOtpSignInEvent', l.statusCode)) {
          add(
            VerifyOtpSignInEvent(
              sessionInfo: event.sessionInfo,
              otp: event.otp,
              action: event.action,
              phone: event.phone,
            ),
          );
          ErrorManager.incrementRetry('VerifyOtpSignInEvent');
        }
        emit(
          state.copyWith(verifyOtpSignInStatus: VerifyOtpSignInStatus.failure),
        );
      },
      (r) async {
        if ((r.status ?? "") != VerifyOtpSessionStatus.requiresPasscode.value) {
          final response = await completeSessionUsecase(
            CompleteSessionParams(sessionToken: r.sessionToken ?? ""),
          );
          response.fold((l) {}, (r) {
            try {
              _prefsRepository.setUserId(r.user!.id.toString());

              _prefsRepository.setUserName(
                "${r.user?.firstName ?? ''} ${r.user?.lastName ?? ''}",
              );

              _prefsRepository.setEmail(r.user?.email ?? "");
              _prefsRepository.setPhoto(r.user?.profilePictureUrl ?? "");
              _prefsRepository.setMemberSince(
                (r.user?.createdAt ?? '').toString(),
              );
              _prefsRepository.setWalletToken(r.accessToken!.token!);
              _prefsRepository.setWalletTokenExpiresAt(
                r.accessToken?.expiresAt,
              );
              _prefsRepository.setWalletRefreshToken(
                r.refreshToken?.token ?? "",
              );
              _prefsRepository.setSessionToken(r.sessionToken ?? "");

              _prefsRepository.setTokenExpired(false);
              _prefsRepository.setUserId(r.user!.id.toString());

              // ignore: unrelated_type_equality_checks
              _prefsRepository.setVerifiedPhone(
                r.user?.isPhoneVerified ?? false,
              );
              _prefsRepository.setPhoneNumber((r.user?.phoneNumber).toString());
              _prefsRepository.setIsAccountActive(
                !(r.user?.isBlocked ?? false),
              );
              _prefsRepository.setIsTwoFactorEnabled(
                r.user?.isTwoFactorEnabled ?? false,
              );
              _prefsRepository.setVerifiedPhonePeforeExpiredToken(false);

              ////////////////////////
              // ignore: empty_catches
            } catch (error) {}

            emit(
              state.copyWith(
                verifyOtpSignInStatus: VerifyOtpSignInStatus.success,
                walletUser: r.user,
                signInErrorMessage: r.status,
              ),
            );
          });
        } else {
          ErrorManager.resetRetry('VerifyOtpSignInEvent');
          try {
            _prefsRepository.setUserId(r.user!.id.toString());
            _prefsRepository.setPasscode('true');

            _prefsRepository.setUserName(
              "${r.user?.firstName ?? ''} ${r.user?.lastName ?? ''}",
            );

            _prefsRepository.setEmail(r.user?.email ?? "");
            _prefsRepository.setPhoto(r.user?.profilePictureUrl ?? "");
            _prefsRepository.setMemberSince(
              (r.user?.createdAt ?? '').toString(),
            );
            _prefsRepository.setWalletToken(r.accessToken?.token ?? "");
            _prefsRepository.setWalletTokenExpiresAt(r.accessToken?.expiresAt);
            _prefsRepository.setWalletRefreshToken(r.refreshToken?.token ?? "");
            _prefsRepository.setSessionToken(r.sessionToken ?? "");

            _prefsRepository.setTokenExpired(false);
            _prefsRepository.setUserId(r.user!.id.toString());

            // ignore: unrelated_type_equality_checks
            _prefsRepository.setVerifiedPhone(r.user?.isPhoneVerified ?? false);
            _prefsRepository.setPhoneNumber((r.user?.phoneNumber).toString());
            _prefsRepository.setIsAccountActive(!(r.user?.isBlocked ?? false));
            _prefsRepository.setIsTwoFactorEnabled(
              r.user?.isTwoFactorEnabled ?? false,
            );
            _prefsRepository.setVerifiedPhonePeforeExpiredToken(false);

            ////////////////////////
            // ignore: empty_catches
          } catch (error) {}
          _prefsRepository.setstepToken(r.stepToken ?? "");
          await Future.delayed(const Duration(seconds: 1), () {});
          emit(
            state.copyWith(
              verifyOtpSignInStatus: VerifyOtpSignInStatus.success,
              walletUser: r.user,
              signInErrorMessage: r.status,
            ),
          );
        }
      },
    );
  }

  /* FutureOr<void> _onVerifyOtpSignUpEvent(
    VerifyOtpSignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(verifyOtpSignUpStatus: VerifyOtpSignUpStatus.loading));
    final response = await verifyOtpSignUpUseCase(
      VerifyOtpSignUpParams(
        sessionInfo: event.sessionInfo,
        otp: event.otp,
        phone: event.phone,
      ),
    );
    response.fold(
      (l) {
        if (ErrorManager.shouldRetry('VerifyOtpSignUpEvent', l.statusCode)) {
          add(
            VerifyOtpSignUpEvent(
              sessionInfo: event.sessionInfo,
              otp: event.otp,
              phone: event.phone,
            ),
          );
          ErrorManager.incrementRetry('VerifyOtpSignUpEvent');
        }
        emit(
          state.copyWith(
            signUpErrorMessage: 'faild',
            verifyOtpSignUpStatus: VerifyOtpSignUpStatus.failure,
          ),
        );
      },
      (r) {
        ErrorManager.resetRetry('VerifyOtpSignUpEvent');
        if ((r.user!.firstName?.replaceAll(' ', '') ?? '') != '') {
          _prefsRepository.setUserName(r.user!.firstName!);
        }

        _prefsRepository.setOtpCode(event.otp);
        _prefsRepository.setWalletToken(r.accessToken!.token!);
        _prefsRepository.setTokenExpired(false);

        //////////////////////////////////////

        _prefsRepository.setUserId(r.user!.id.toString());
        //    print(
        //    "dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd${r.data!.user?.isPhoneVerified}");

        // ignore: unrelated_type_equality_checks
        _prefsRepository.setVerifiedPhone(r.user?.isPhoneVerified ?? false);
        _prefsRepository.setPhoneNumber((r.user?.phoneNumber).toString());

        emit(
          state.copyWith(
            verifyOtpSignUpStatus: VerifyOtpSignUpStatus.success,
            walletUser: r.user,
          ),
        );
      },
    );
  }*/

  FutureOr<void> _onSwitchToAppEvent(
    SwitchToAppEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(switchToAppStatus: SwitchToAppStatus.loading));
    final response = await switchToAppUsecase(NoParams());
    await response.fold((failure) async {
      if (failure.statusCode != StatusCode.unauth.code) {
        // فشل آخر (شبكة/خادم) — يمكن إعادة المحاولة
        emit(state.copyWith(switchToAppStatus: SwitchToAppStatus.failure));
        return;
      }
      // 401 أثناء التبديل: نبقى في صفحة التبديل، نجدّد التوكن ونحدّث المكتبة
      // ثم نعيد محاولة switch مرة واحدة.
      final refreshed = await _performTokenRefresh();
      if (!refreshed) {
        // تعذّر تجديد التوكن — نبقى في صفحة التبديل (يمكن إعادة المحاولة)
        emit(state.copyWith(switchToAppStatus: SwitchToAppStatus.failure));
        return;
      }
      // فاصل زمني قصير حتى يُطبَّق التوكن الجديد (التخزين المحلي + تحديث
      // المكتبة) قبل إرسال طلب switch بالتوكن الجديد
      await Future.delayed(const Duration(milliseconds: 1500));
      final retry = await switchToAppUsecase(NoParams());
      retry.fold(
        (_) =>
            emit(state.copyWith(switchToAppStatus: SwitchToAppStatus.failure)),
        (_) => _emitSwitchSuccess(emit),
      );
    }, (_) async => _emitSwitchSuccess(emit));
  }

  /// عاد المستخدم للتطبيق بنجاح — الجلسة مستمرة، أخفِ طبقة التبديل وصفّر العدّاد.
  void _emitSwitchSuccess(Emitter<AuthState> emit) {
    _prefsRepository.setShouldShowSwitch(false);
    _prefsRepository.setSwitchShownAtMs(null);
    emit(state.copyWith(switchToAppStatus: SwitchToAppStatus.success));
  }

  FutureOr<void> _onResetSwitchToAppEvent(
    ResetSwitchToAppEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(switchToAppStatus: SwitchToAppStatus.init));
  }

  FutureOr<void> _onEnsureWalletTokenValidEvent(
    EnsureWalletTokenValidEvent event,
    Emitter<AuthState> emit,
  ) async {
    final hasPasscode = (_prefsRepository.passcode ?? "").isNotEmpty;
    final hasRefreshToken =
        (_prefsRepository.walletRefreshToken ?? "").isNotEmpty;
    final expiresAt = _prefsRepository.walletTokenExpiresAt;
    if (!hasPasscode || !hasRefreshToken || expiresAt == null) {
      return;
    }
    // حدّث إذا انتهى التوكن أو سينتهي خلال الدقيقة القادمة
    final threshold = DateTime.now().add(const Duration(minutes: 1));
    if (threshold.isAfter(expiresAt)) {
      add(const RefreshTokenEvent());
    }
  }

  FutureOr<void> _onRefreshTokenEvent(
    RefreshTokenEvent event,
    Emitter<AuthState> emit,
  ) async {
    await _performTokenRefresh();
  }

  /// يطلب توكنًا جديدًا بالـ refresh token المخزّن، وعند النجاح يحدّث التوكنات
  /// المخزّنة ويُرسل الجديد للمكتبة. يُعيد true عند النجاح، false عند الفشل
  /// (لا refresh token، أو فشل الطلب / 401 = الجلسة انتهت).
  ///
  /// إذا كان هناك طلب refresh جارٍ، تنتظر الاستدعاءات الأخرى نتيجته نفسها
  /// بدل إطلاق طلب جديد.
  Future<bool> _performTokenRefresh() {
    return _refreshInFlight ??= _doTokenRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  /// الجلسة انتهت (فشل الـ refresh بـ 401) — امسح التوكنات وتوجّه للصفحة الأولى
  /// على مستوى التطبيق كله.
  void _handleSessionExpired() {
    _prefsRepository.setWalletToken("");
    _prefsRepository.setWalletRefreshToken("");
    _prefsRepository.setWalletTokenExpiresAt(null);
    _prefsRepository.setShouldShowSwitch(false);
    _prefsRepository.setSwitchShownAtMs(null);
    GRouter.router.go(GRouter.config.kRootRoute);
  }

  Future<bool> _doTokenRefresh() async {
    final currentRefreshToken = _prefsRepository.walletRefreshToken ?? "";
    if (currentRefreshToken.isEmpty) {
      return false;
    }

    final response = await refreshTokenUsecase(currentRefreshToken);
    return response.fold(
      (failure) async {
        // انتهت صلاحية الـ refresh token (401) = الجلسة انتهت — على مستوى التطبيق
        // كله: امسح التوكنات وتوجّه للصفحة الأولى.
        if (failure.statusCode == StatusCode.unauth.code) {
          _handleSessionExpired();
        }
        return false;
      },
      (r) async {
        final newAccessToken = r.accessToken?.token ?? "";
        if (newAccessToken.isEmpty) {
          return false;
        }

        // تحديث التوكنات المخزّنة لدينا — ننتظر اكتمال الكتابة حتى لا تُقرأ
        // القيمة القديمة في الطلب التالي (مثل switch)
        await _prefsRepository.setWalletToken(newAccessToken);
        await _prefsRepository.setWalletRefreshToken(
          r.refreshToken?.token ?? currentRefreshToken,
        );
        await _prefsRepository.setWalletTokenExpiresAt(
          r.accessToken?.expiresAt,
        );
        await _prefsRepository.setTokenExpired(false);

        // إرسال التوكن الجديد للمكتبة لمتابعة العمل به
        TrydosWallet.updateToken(newAccessToken);
        return true;
      },
    );
  }

  FutureOr<void> _onGetUserCountryEvent(
    GetUserCountryEvent event,
    Emitter<AuthState> emit,
  ) async {
    final response = await getUserCountryUseCase(NoParams());
    // initializeSmartLook();
    Logger(printer: PrettyPrinter(methodCount: 0)).i('SMARTLOOK STARTED!');
    response.fold(
      (l) {
        emit(
          state.copyWith(
            getCustomerCountryStatus: GetCustomerCountryStatus.failure,
          ),
        );
        if (ErrorManager.shouldRetry('GetUserCountryEvent', l.statusCode)) {
          add(GetUserCountryEvent());
          ErrorManager.incrementRetry('GetUserCountryEvent');
        }
      },
      (r) {
        ErrorManager.resetRetry('GetUserCountryEvent');
        _prefsRepository.setCountryIso(r.countryCode);

        emit(
          state.copyWith(
            getUserCountryResponseModel: r,
            countryName: r.country,
            getCustomerCountryStatus: GetCustomerCountryStatus.success,
          ),
        );
      },
    );
  }

  FutureOr<void> _onSaveErrorSigneInVerify(
    SaveErrorSigneInVerify event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(signInErrorMessage: event.error));
  }

  FutureOr<void> _onResetAllData(
    ResetAllData event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        signInErrorMessage: "",
        sendOtpStatus: SendOtpStatus.init,
        updateUserProfileStatus: UpdateUserProfileStatus.init,
        updateUserProfileError: '',
        walletUser: User(),
        verifyOtpFromGuestStatus: VerifyOtpFromGuestStatus.init,
        verifyOtpSignInStatus: VerifyOtpSignInStatus.init,
      ),
    );
    GetIt.I<PrefsRepository>().setVerifiedPhone(false);
    GetIt.I<PrefsRepository>().setVerifiedPhonePeforeExpiredToken(false);
    GetIt.I<PrefsRepository>().setIsAccountActive(false);
    GetIt.I<PrefsRepository>().setIsTwoFactorEnabled(false);
  }

  FutureOr<void> _onSetPasscodeEvent(
    SetPasscodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(setPasscodeStatus: SetPasscodeStatus.loading));
    final result = await setPasscodeUseCase(event.passcode);
    await result.fold(
      (failure) {
        emit(state.copyWith(setPasscodeStatus: SetPasscodeStatus.failure));
      },
      (isSet) async {
        _prefsRepository.setPasscode("true");
        emit(state.copyWith(setPasscodeStatus: SetPasscodeStatus.success));
      },
    );
    // يمكن إضافة معالجة الحالة هنا لاحقاً
  }

  FutureOr<void> _onChangePasscodeEvent(
    ChangePasscodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(changePasscodeStatus: ChangePasscodeStatus.loading));
    final result = await changePasscodeUseCase(
      event.currentPasscode,
      event.newPasscode,
    );
    result.fold(
      (failure) {
        emit(
          state.copyWith(changePasscodeStatus: ChangePasscodeStatus.failure),
        );
      },
      (isChanged) {
        emit(
          state.copyWith(changePasscodeStatus: ChangePasscodeStatus.success),
        );
      },
    );
    // يمكن إضافة معالجة الحالة هنا لاحقاً
  }

  // ───────────── معالجات إعادة تعيين رمز المرور ─────────────

  FutureOr<void> _onResetInitEvent(
    ResetInitEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(resetInitStatus: ResetInitStatus.loading));
    final res = await resetInitUseCase(
      ResetEntryParams(midLogin: event.midLogin),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          resetInitStatus: ResetInitStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          resetInitStatus: ResetInitStatus.success,
          resetInitResult: r,
          // '' لمسح أي قفل قديم عالق (AuthBloc مفرد). التفرّع يعتمد على
          // resetInitResult.isLocked الطازج لا على هذا الحقل.
          resetLockedUntil: r.lockout?.lockedUntil ?? '',
          resetLockoutHours: r.lockout?.lockoutHours ?? 0,
        ),
      ),
    );
  }

  FutureOr<void> _onResetSendOtpEvent(
    ResetSendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(resetSendOtpStatus: ResetSendOtpStatus.loading));
    final res = await resetSendOtpUseCase(
      ResetSendOtpParams(
        phoneNumber: event.phoneNumber,
        channel: event.channel,
      ),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          resetSendOtpStatus: ResetSendOtpStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          resetSendOtpStatus: r.ok
              ? ResetSendOtpStatus.success
              : ResetSendOtpStatus.failure,
          resetError: r.ok ? null : (r.error ?? 'error'),
        ),
      ),
    );
  }

  FutureOr<void> _onResetVerifyOtpEvent(
    ResetVerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(resetVerifyOtpStatus: ResetVerifyOtpStatus.loading));
    final res = await resetVerifyOtpUseCase(
      ResetVerifyOtpParams(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
      ),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          resetVerifyOtpStatus: ResetVerifyOtpStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          resetVerifyOtpStatus: r.ok
              ? ResetVerifyOtpStatus.success
              : ResetVerifyOtpStatus.failure,
          resetError: r.ok ? null : (r.error ?? 'Invalid code'),
        ),
      ),
    );
  }

  FutureOr<void> _onResetQuestionsEvent(
    ResetQuestionsEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(resetQuestionsStatus: ResetQuestionsStatus.loading));
    final res = await resetQuestionsUseCase(
      ResetEntryParams(midLogin: event.midLogin),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          resetQuestionsStatus: ResetQuestionsStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          resetQuestionsStatus: ResetQuestionsStatus.success,
          resetQuestions: r.questions,
          resetAttemptsRemaining: r.attemptsRemaining,
        ),
      ),
    );
  }

  FutureOr<void> _onResetAnswersEvent(
    ResetAnswersEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(resetAnswersStatus: ResetAnswersStatus.loading));
    final res = await resetAnswersUseCase(
      ResetAnswersParams(answers: event.answers, midLogin: event.midLogin),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          resetAnswersStatus: ResetAnswersStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          resetAnswersStatus: ResetAnswersStatus.success,
          resetAttemptsRemaining: r.attemptsRemaining ?? 0,
          // '' للمسح: نفرّق في الواجهة بين نجاح (resetToken غير فارغ) / قفل
          // (resetLockedUntil غير فارغ) / خطأ (كلاهما فارغ مع بقاء محاولات).
          resetToken: r.resetToken ?? '',
          resetLockedUntil: r.lockedUntil ?? '',
          resetLockoutHours: r.lockoutHours ?? 0,
        ),
      ),
    );
  }

  FutureOr<void> _onResetCompleteEvent(
    ResetCompleteEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(resetCompleteStatus: ResetCompleteStatus.loading));
    final res = await resetCompleteUseCase(
      ResetCompleteParams(
        passcode: event.passcode,
        resetToken: state.resetToken,
        midLogin: event.midLogin,
      ),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          resetCompleteStatus: ResetCompleteStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          resetCompleteStatus: r.success
              ? ResetCompleteStatus.success
              : ResetCompleteStatus.failure,
        ),
      ),
    );
  }

  FutureOr<void> _onReverifyFaceEvent(
    ReverifyFaceEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(reverifyFaceStatus: ReverifyFaceStatus.loading));
    final res = await reverifyFaceVerifyUseCase(
      ReverifyFaceParams(
        challengeId: event.challengeId,
        liveFaceImageData: event.liveFaceImageData,
        sessionId: state.reverifySessionId,
      ),
    );
    res.fold(
      (f) => emit(
        state.copyWith(
          reverifyFaceStatus: ReverifyFaceStatus.error,
          resetError: f.message,
        ),
      ),
      (r) {
        if (r.isPassed) {
          // نخزّن stepToken في resetToken ليُحمَل على complete (مثل مسار الأسئلة).
          emit(
            state.copyWith(
              reverifyFaceStatus: ReverifyFaceStatus.passed,
              resetToken: r.stepToken ?? '',
            ),
          );
        } else {
          emit(
            state.copyWith(
              reverifyFaceStatus: ReverifyFaceStatus.failed,
              resetError: r.reason,
            ),
          );
        }
      },
    );
  }

  FutureOr<void> _onReverifyStartEvent(
    ReverifyStartEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(reverifyStartStatus: ReverifyStartStatus.loading));
    final res = await reverifyFaceStartUseCase(event.challengeId);
    res.fold(
      (f) => emit(
        state.copyWith(
          reverifyStartStatus: ReverifyStartStatus.failure,
          resetError: f.message,
        ),
      ),
      (r) => emit(
        state.copyWith(
          reverifyStartStatus: ReverifyStartStatus.success,
          reverifySessionId: r.sessionId,
        ),
      ),
    );
  }
}
