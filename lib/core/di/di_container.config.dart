// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/authentication/data/data_sources/auth_remote_datasource.dart'
    as _i539;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i317;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../../features/authentication/domain/use_cases/change_passcode_usecase.dart'
    as _i884;
import '../../features/authentication/domain/use_cases/complete_session_usecase.dart'
    as _i892;
import '../../features/authentication/domain/use_cases/create_wallet_usecase.dart'
    as _i650;
import '../../features/authentication/domain/use_cases/get_passkey_list_usecase.dart'
    as _i173;
import '../../features/authentication/domain/use_cases/get_user_country_usecase.dart'
    as _i644;
import '../../features/authentication/domain/use_cases/get_user_profile_usecase.dart'
    as _i356;
import '../../features/authentication/domain/use_cases/login_to_wallet_usecase.dart'
    as _i304;
import '../../features/authentication/domain/use_cases/refresh_token_usecase.dart'
    as _i268;
import '../../features/authentication/domain/use_cases/reset_passcode_usecases.dart'
    as _i919;
import '../../features/authentication/domain/use_cases/send_otp_usecase.dart'
    as _i952;
import '../../features/authentication/domain/use_cases/set_passcode_usecase.dart'
    as _i566;
import '../../features/authentication/domain/use_cases/switch_to_app_usecase.dart'
    as _i814;
import '../../features/authentication/domain/use_cases/update_user_profile_usecase.dart'
    as _i215;
import '../../features/authentication/domain/use_cases/verify_otp_signin_usecase.dart'
    as _i574;
import '../../features/authentication/domain/use_cases/verify_session_passcode_usecase.dart'
    as _i385;
import '../../features/authentication/domain/use_cases/verify_step_passcode_usecase.dart'
    as _i47;
import '../../features/authentication/presentation/manager/auth_bloc.dart'
    as _i561;
import '../data/data_source/common_use_repo_data_source.dart' as _i672;
import '../data/repository/common_use_repository_impl.dart' as _i77;
import '../domin/repositories/common_use_repository.dart' as _i702;
import '../domin/repositories/prefs_repository.dart' as _i658;
import '../domin/usecases/upload_file_cloudinary_usecase.dart' as _i1043;
import 'di_container.dart' as _i198;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(getIt, environment, environmentFilter);
  final appModule = _$AppModule();
  gh.factory<_i672.CommonUseRemoteDataSource>(
    () => _i672.CommonUseRemoteDataSource(),
  );
  gh.factory<_i361.BaseOptions>(() => appModule.dioOption);
  gh.factory<_i539.AuthRemoteDatasource>(() => _i539.AuthRemoteDatasource());
  gh.singleton<_i974.Logger>(() => appModule.logger);
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => appModule.sharedPreferences,
    preResolve: true,
  );
  await gh.singletonAsync<_i658.PrefsRepository>(
    () => appModule.prefsRepository,
    preResolve: true,
  );
  gh.singleton<_i361.Dio>(
    () => appModule.dio(gh<_i361.BaseOptions>(), gh<_i974.Logger>()),
  );
  gh.lazySingleton<_i702.CommonUseRepository>(
    () => _i77.CommonUseRepositoryImpl(gh<_i672.CommonUseRemoteDataSource>()),
  );
  gh.lazySingleton<_i742.AuthRepository>(
    () => _i317.AuthRepositoryImpl(gh<_i539.AuthRemoteDatasource>()),
  );
  gh.factory<_i1043.UploadFileCloudinaryUseCase>(
    () => _i1043.UploadFileCloudinaryUseCase(gh<_i702.CommonUseRepository>()),
  );
  gh.factory<_i884.ChangePasscodeUseCase>(
    () => _i884.ChangePasscodeUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i892.CompleteSessionUsecase>(
    () => _i892.CompleteSessionUsecase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i650.CreateWalletUseCase>(
    () => _i650.CreateWalletUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i173.GetPasskeyListUseCase>(
    () => _i173.GetPasskeyListUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i644.GetUserCountryUseCase>(
    () => _i644.GetUserCountryUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i356.GetUserProfileUseCase>(
    () => _i356.GetUserProfileUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i304.LoginToWalletUseCase>(
    () => _i304.LoginToWalletUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i268.RefreshTokenUsecase>(
    () => _i268.RefreshTokenUsecase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ResetInitUseCase>(
    () => _i919.ResetInitUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ResetSendOtpUseCase>(
    () => _i919.ResetSendOtpUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ResetVerifyOtpUseCase>(
    () => _i919.ResetVerifyOtpUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ResetQuestionsUseCase>(
    () => _i919.ResetQuestionsUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ResetAnswersUseCase>(
    () => _i919.ResetAnswersUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ResetCompleteUseCase>(
    () => _i919.ResetCompleteUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ReverifyFaceStartUseCase>(
    () => _i919.ReverifyFaceStartUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i919.ReverifyFaceVerifyUseCase>(
    () => _i919.ReverifyFaceVerifyUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i952.SendOtpUseCase>(
    () => _i952.SendOtpUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i566.SetPasscodeUseCase>(
    () => _i566.SetPasscodeUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i814.SwitchToAppUsecase>(
    () => _i814.SwitchToAppUsecase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i215.UpdateUserProfileUseCase>(
    () => _i215.UpdateUserProfileUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i574.VerifyOtpSignInUseCase>(
    () => _i574.VerifyOtpSignInUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i385.VerifySessionPasscodeUseCase>(
    () => _i385.VerifySessionPasscodeUseCase(gh<_i742.AuthRepository>()),
  );
  gh.factory<_i47.VerifyStepasscodeUseCase>(
    () => _i47.VerifyStepasscodeUseCase(gh<_i742.AuthRepository>()),
  );
  gh.lazySingleton<_i561.AuthBloc>(
    () => _i561.AuthBloc(
      gh<_i952.SendOtpUseCase>(),
      gh<_i574.VerifyOtpSignInUseCase>(),
      gh<_i215.UpdateUserProfileUseCase>(),
      gh<_i47.VerifyStepasscodeUseCase>(),
      gh<_i385.VerifySessionPasscodeUseCase>(),
      gh<_i644.GetUserCountryUseCase>(),
      gh<_i173.GetPasskeyListUseCase>(),
      gh<_i356.GetUserProfileUseCase>(),
      gh<_i892.CompleteSessionUsecase>(),
      gh<_i566.SetPasscodeUseCase>(),
      gh<_i884.ChangePasscodeUseCase>(),
      gh<_i268.RefreshTokenUsecase>(),
      gh<_i814.SwitchToAppUsecase>(),
      gh<_i919.ResetInitUseCase>(),
      gh<_i919.ResetSendOtpUseCase>(),
      gh<_i919.ResetVerifyOtpUseCase>(),
      gh<_i919.ResetQuestionsUseCase>(),
      gh<_i919.ResetAnswersUseCase>(),
      gh<_i919.ResetCompleteUseCase>(),
      gh<_i919.ReverifyFaceVerifyUseCase>(),
      gh<_i919.ReverifyFaceStartUseCase>(),
    ),
  );
  return getIt;
}

class _$AppModule extends _i198.AppModule {}
