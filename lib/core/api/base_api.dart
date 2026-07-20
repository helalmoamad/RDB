import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/api/methods/detect_server.dart';
import 'package:rdb/main.dart';
import '../../service/language_service.dart';
import '../domin/repositories/prefs_repository.dart';
import 'handling_exception.dart';

abstract class BaseApi<T> with HandlingExceptionRequest {
  BaseApi(this.serverName) {
    // **نسخة مستقلّة لكل طلب.** الكتابة المباشرة في خريطة ترويسات Dio المفرد
    // كانت تُبقي `Authorization` الخاصة بطلب سابق على طلبات لا تريدها:
    //
    // - خوادم بلا توكن (تحديد الدولة) كانت تستقبل توكن المحفظة.
    // - وفي mid-login تحديدًا: `walletToken` يساوي "" لا null، فتُكتب
    //   `Authorization: Bearer ` فارغة ثم تتسرّب إلى نداء KYC الذي يجب أن
    //   يُصادَق بـ `X-Step-Token` **بلا Bearer إطلاقًا** (دليل الـ Worker §1).
    //
    // لذلك نبدأ من نسخة، ونحذف أثر أي مصادقة سابقة، ثم نكتب مصادقة هذا الطلب.
    final headers = Map<String, dynamic>.of(client.options.headers)
      ..remove(HttpHeaders.authorizationHeader);
    final String? token = getServerToken(serverName);

    if (token != null) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    if (serverName != ServerName.cloudinary) {
      headers['country'] =
          GetIt.I<PrefsRepository>().userCountryIsAvailable == 1
          ? GetIt.I<PrefsRepository>().userChoosedCountryIso
          : GetIt.I<PrefsRepository>().countryIso;
      headers['lang'] = LanguageService.languageCode == 'ar'
          ? LanguageService.isKurdish
                ? "ku"
                : 'ar'
          : LanguageService.languageCode;

      headers['User-Agent'] =
          'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: $applicationVersion';
    }
    options = Options(headers: headers);
  }

  final ServerName serverName;

  final client = GetIt.I<Dio>();

  late Options options;

  Future<T> call();
}
