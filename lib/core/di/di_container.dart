import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    headers: <String, String>{HttpHeaders.acceptHeader: 'application/json'},
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
    return PrefsRepositoryImpl.create(prefs, const FlutterSecureStorage());
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

// ═══════════════════════════════════════════════════════════════════════════
//  سياسة TLS: لا تجاوز — إطلاقاً، ولا حتى في وضع التطوير.
// ═══════════════════════════════════════════════════════════════════════════
//
//  لا يوجد badCertificateCallback في هذا المشروع، ولا HttpOverrides.global.
//  عميل dart:io الافتراضي هو المستخدم، فيتحقّق من سلسلة الثقة ومن تطابق اسم
//  المضيف، ويرفض أي شهادة موقّعة ذاتياً أو منتهية أو مزيّفة — في debug وrelease
//  على حدّ سواء.
//
//  خلفية تاريخية (لا تُعِد الكرّة):
//    كان هنا badCertificateCallback يُعيد true دائماً. لم يكن قراراً أمنياً بل
//    التفافاً على عطل في اسم نطاق: WALLET_URL كان `trydos_wallet_develop...`
//    بشُرَط سفلية، وهي ممنوعة في أسماء المضيفات (RFC 1123)، فكانت مطابقة الاسم
//    مع `*.ramaaz.dev` تفشل بـ 62 (hostname mismatch) رغم أن الشهادة سليمة.
//    فعُطِّل التحقّق كلّه ليمرّ عطل واحد — وسقطت الحماية عن كل نطاق وكل طلب.
//    حُلّ العطل من الباك-اند بتغيير النطاق إلى `rdb-develop.ramaaz.dev`.
//
//  إن فشل اتصال بخطأ شهادة مستقبلاً فذلك **عطل حقيقي** في الخادم أو في اسم
//  النطاق — شخّصه بـ:
//      openssl s_client -connect <host>:443 -servername <host> \
//        -verify_hostname <host> -verify_return_error
//  ولا تُعِد فتح التجاوز. لخادم تطوير بشهادة ذاتية: أضف شهادة الـ CA إلى
//  SecurityContext بدلاً من تعطيل التحقّق.
//
//  قاعدتا Semgrep `rdb-dart-bad-certificate-callback` و
//  `rdb-dart-allow-bad-certificate-literal` في `.semgrep/dart-security.yaml`
//  تحرسان هذا القرار وتُفشلان أي محاولة لإعادته.
