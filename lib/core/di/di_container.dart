import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/log_interceptor.dart';
import '../data/repository/prefs_repository_impl.dart';
import '../domin/repositories/prefs_repository.dart';
import 'di_container.config.dart';

final GetIt _getIt = GetIt.I;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<GetIt> configureDependencies() async => $initGetIt(_getIt);

@module
abstract class AppModule {
  BaseOptions get dioOption => BaseOptions(
        connectTimeout: const Duration(minutes: 2),
        receiveTimeout: const Duration(minutes: 2),
        sendTimeout: const Duration(minutes: 2),
        contentType: 'application/json',
        headers: <String, String>{
          HttpHeaders.acceptHeader: 'application/json',
        },
      );

  @singleton
  Logger get logger => Logger();

  @preResolve
  @singleton
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @preResolve
  @singleton
  Future<PrefsRepository> get prefsRepository async {
    SharedPreferences prefs = await sharedPreferences;
    return PrefsRepositoryImpl(prefs);
  }

  @singleton
  Dio dio(BaseOptions option, Logger logger) {
    final dio = Dio(option);
    // dio.httpClientAdapter = Http2Adapter(
    //   ConnectionManager(idleTimeout: Duration(seconds: 15),proxyConnectedPredicate: (_,__)=> true),
    // );
    dio.interceptors.add(LoggerInterceptor());
    return dio;
  }
}

// @singleton
// SessionManager get sessionManager => SessionManager();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
