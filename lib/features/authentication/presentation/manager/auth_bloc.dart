import 'dart:async';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:rdb/features/authentication/data/models/get_user_country_response_model.dart';
// ignore: depend_on_referenced_packages
import 'package:stream_transform/stream_transform.dart';
import 'package:rdb/core/error/error_manager.dart';
import 'package:rdb/core/use_case/use_case.dart';
import 'package:rdb/features/authentication/domain/use_cases/get_user_country_usecase.dart';

import 'package:rdb/features/authentication/domain/use_cases/send_otp_usecase.dart';
import 'package:rdb/features/authentication/domain/use_cases/update_user_profile_usecase.dart';

import 'package:rdb/features/authentication/domain/use_cases/verify_otp_signin_usecase.dart';
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
    this.getUserCountryUseCase,
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

    // on<VerifyOtpSignUpEvent>(_onVerifyOtpSignUpEvent);

    on<GetUserCountryEvent>(
      _onGetUserCountryEvent,
      //transformer: throttleDroppable(throttleDuration)
    );
    // on<CreateWalletEvent>(_onCreateWalletEvent);
  }

  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpSignInUseCase verifyOtpSignInUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  //final VerifyOtpSignUpUseCase verifyOtpSignUpUseCase;
  //final CreateWalletUseCase createWalletUseCase;
  // final LoginToWalletUseCase loginToWalletUseCase;
  final GetUserCountryUseCase getUserCountryUseCase;
  final PrefsRepository _prefsRepository = GetIt.I<PrefsRepository>();

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
          ),
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
      ),
    );
    response.fold(
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
      (r) {
        ErrorManager.resetRetry('VerifyOtpSignInEvent');
        try {
          _prefsRepository.setUserId(r.user!.id.toString());

          _prefsRepository.setUserName(
            "${r.user?.firstName ?? ''} ${r.user?.lastName ?? ''}",
          );

          _prefsRepository.setEmail(r.user?.email ?? "");
          _prefsRepository.setPhoto(r.user?.profilePictureUrl ?? "");
          _prefsRepository.setMemberSince((r.user?.createdAt ?? '').toString());
          _prefsRepository.setWalletToken(r.accessToken!.token!);
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
          ),
        );
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
}
