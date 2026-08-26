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

// ╔═════════════════════════════════════════════════════════════════════════╗
// ║  ⚠️  حلّ مؤقّت — التحقّق من شهادات TLS معطَّل في كل النسخ                ║
// ║      يُزال فور إصلاح الباك-اند. لا تبنِ عليه ولا تنسخه لمشروع آخر.       ║
// ╚═════════════════════════════════════════════════════════════════════════╝
//
//  سبب التعطيل:
//    WALLET_URL يشير إلى `trydos_wallet_develop.ramaaz.dev`، والاسم يحوي
//    شُرَطاً سفلية. الشرطة السفلية ممنوعة في أسماء المضيفات (RFC 1123)، وقواعد
//    مطابقة الأحرف البديلة (RFC 6125) تشترط أن يكون المقطع اسم DNS صالحاً —
//    فيرفض dart:io مطابقة الاسم مع `*.ramaaz.dev` رغم أن الشهادة سليمة تماماً
//    وسلسلتها كاملة وصادرة عن Google Trust Services.
//
//    أُثبت بـ openssl s_client -verify_hostname على نفس الخادم والشهادة:
//      trydos_wallet_develop.ramaaz.dev  ->  62 (hostname mismatch)
//      trydos-wallet-develop.ramaaz.dev  ->  0  (ok)
//
//  الإصلاح النهائي (على الباك-اند — دقائق، وبلا أي عمل على الشهادات):
//    1) أضف سجل DNS `trydos-wallet-develop.ramaaz.dev` يشير لنفس الوجهة.
//       شهادة `*.ramaaz.dev` الحالية تغطّيه فوراً.
//    2) حدّث WALLET_URL في `.env` وفي `.github/workflows/deploy.yml`.
//    3) احذف هذا التعطيل: أعِد شرط `if (kDebugMode)` حول
//       badCertificateCallback هنا، وحول HttpOverrides.global في main.dart،
//       وأعِد `allowBadCertificate: kDebugMode` في home_page.dart.
//
//  ما الذي تخسره ما دام هذا السطر قائماً:
//    التحقّق من الشهادة معطَّل لكل نطاق وكل طلب في نسخة الإصدار. أي مهاجم على
//    نفس الشبكة (واي فاي عام، راوتر مخترَق، نقطة اتصال مزيّفة) يستطيع تقديم
//    شهادة موقّعة ذاتياً فيقبلها التطبيق بصمت، ثم يقرأ **ويعدّل** المرور:
//    رموز OTP، walletToken، stepToken، ومبالغ التحويلات وأرقام حسابات
//    المستلِمين. لا يظهر للمستخدم أي تحذير.
//
//  ملاحظة: قواعد Semgrep في `.semgrep/dart-security.yaml` سترصد هذا السطر
//  كخطأ (ERROR) عمداً — تُركت تعمل لتبقى المشكلة ظاهرة حتى تُحلّ. لا تُسكِتها
//  بـ nosemgrep.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // مؤقّت: اقبل كل الشهادات. انظر الشرح أعلاه.
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}
