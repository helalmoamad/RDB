import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:passkeys/authenticator.dart';
import 'package:passkeys/types.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/main.dart';
import 'package:rdb/service/language_service.dart';

class BiometricAuthService {
  // رابط السيرفر (الباك إند) الخاص بك
  final String baseUrl = dotenv.env['WALLET_URL']!;

  // الكائن المسؤول عن قراءة بصمة الهاتف
  final _passkeyAuthenticator = PasskeyAuthenticator();

  /// 1️⃣ خطوة التسجيل والربط (نسخة مصححة وحاسمة لنوع البيانات)
  Future<Map<String, dynamic>> registerBiometric({
    required String sessionToken,
    String? deviceName,
  }) async {
    Map<String, String>? headers;
    headers = {
      'Authorization': 'Bearer ${GetIt.I<PrefsRepository>().walletToken}',

      'lang': LanguageService.languageCode == 'ar'
          ? LanguageService.isKurdish
                ? "ku"
                : 'ar'
          : LanguageService.languageCode,

      'User-Agent':
          'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: $applicationVersion',

      'Content-Type': 'application/json',
      'x-session-token': sessionToken,
    };

    try {
      if (kDebugMode) {
        print('🔵 [registerBiometric] بدء التسجيل البيومتري...');
      }

      // أ. طلب خيارات التسجيل (Register Options) من الباك إند
      final optRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/register-options'),
        headers: headers,
        body: jsonEncode({"deviceName": deviceName ?? "Mobile Device"}),
      );

      if (kDebugMode) {
        print(
          '🟡 [registerBiometric] استجابة خيارات التسجيل: status=${optRes.statusCode} body=${optRes.body}',
        );
      }

      if (optRes.statusCode != 200 && optRes.statusCode != 201) {
        if (kDebugMode) {
          print('🔴 [registerBiometric] فشل في الحصول على خيارات التسجيل');
        }
        return {'success': false, 'error': 'FAILED_TO_GET_OPTIONS'};
      }

      // تحويل استجابة السيرفر النصية إلى Map قابلة للتعديل
      final Map<String, dynamic> optionsJson = jsonDecode(optRes.body);

      // 🔥 الحل الحاسم: تنظيف المصفوفة مع إبقاء الـ id كـ String كما تطلبه الحزمة تماماً
      if (optionsJson['excludeCredentials'] != null &&
          optionsJson['excludeCredentials'] is List) {
        final List<dynamic> excludeList = optionsJson['excludeCredentials'];

        optionsJson['excludeCredentials'] = excludeList.map((item) {
          if (item is Map) {
            return {
              // نمرر الـ id كنص (String) وتجنب الـ null عبر وضع قيمة افتراضية فارغة إذا لم يوجد
              'id': item['id']?.toString() ?? '',
              'type': item['type'] ?? 'public-key',
              'transports':
                  item['transports'] ?? [], // حماية ضد الـ null في الأندرويد
            };
          }
          return item;
        }).toList();
      } else {
        optionsJson['excludeCredentials'] = [];
      }

      // حماية حقل hints من الـ null
      if (optionsJson['hints'] == null) {
        optionsJson['hints'] = [];
      }

      if (kDebugMode) {
        print(
          '🟢 [registerBiometric] خيارات التسجيل جاهزة ومطهرة نهائياً: $optionsJson',
        );
      }

      // ب. بناء الكائن وتمريره لمستشعر البصمة
      final registerRequest = RegisterRequestType.fromJson(optionsJson);
      if (kDebugMode) {
        print('🟢 [registerBiometric] تم بناء كائن RegisterRequestType');
      }

      // استدعاء نافذة البصمة بالنظام
      final registerResponse = await _passkeyAuthenticator.register(
        registerRequest,
      );
      if (kDebugMode) {
        print(
          '🟢 [registerBiometric] تم الحصول على استجابة البصمة registerResponse',
        );
      }

      // ج. إرسال استجابة البصمة المشفرة إلى الباك إند للتحقق النهائي
      final verifyRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/register'),
        headers: headers,
        body: jsonEncode({"registrationResponse": registerResponse.toJson()}),
      );

      if (kDebugMode) {
        print(
          '🟡 [registerBiometric] استجابة التحقق النهائي: status=${verifyRes.statusCode} response=${verifyRes.body}',
        );
      }

      if (verifyRes.statusCode != 200 && verifyRes.statusCode != 201) {
        if (kDebugMode) {
          print('🔴 [registerBiometric] فشل التحقق النهائي من السيرفر');
        }
        return {'success': false, 'error': 'SERVER_VERIFICATION_FAILED'};
      }

      final result = jsonDecode(verifyRes.body);
      if (kDebugMode) {
        print('✅ [registerBiometric] تم التسجيل بنجاح: $result');
      }
      return {
        'success': true,
        'credentialId': result['id'] ?? result['credentialId'] ?? '',
      };
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [registerBiometric] حدث استثناء: $e');
      }
      if (e is PasskeyAuthCancelledException || e is PlatformException) {
        return {'success': false, 'error': 'USER_CANCELLED'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2️⃣ خطوة التحقق وفك القفل التلقائي (في المرات القادمة) - نسخة مطهرة ومصححة
  Future<Map<String, dynamic>> verifyBiometric(String sessionToken) async {
    Map<String, String>? headers;
    headers = {
      'Authorization': 'Bearer ${GetIt.I<PrefsRepository>().walletToken}',

      'lang': LanguageService.languageCode == 'ar'
          ? LanguageService.isKurdish
                ? "ku"
                : 'ar'
          : LanguageService.languageCode,

      'User-Agent':
          'device OS:${Platform.isAndroid ? 'Android' : 'IOS'} , application version: $applicationVersion',

      'Content-Type': 'application/json',
      'x-session-token': sessionToken,
    };

    try {
      if (kDebugMode) {
        print('🔵 [verifyBiometric] بدء التحقق البيومتري...');
      }

      // أ. طلب خيارات التحقق (Auth Options) من الباك إند
      final optRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/auth-options'),
        headers: headers,
      );

      if (kDebugMode) {
        print(
          '🟡 [verifyBiometric] استجابة خيارات التحقق: status=${optRes.statusCode} body=${optRes.body}',
        );
      }

      if (optRes.statusCode != 200 && optRes.statusCode != 201) {
        if (kDebugMode) {
          print('🔴 [verifyBiometric] فشل في الحصول على خيارات التحقق');
        }
        return {'success': false, 'error': 'FAILED_TO_GET_AUTH_OPTIONS'};
      }

      // تحويل استجابة السيرفر النصية إلى Map قابلة للتعديل
      final Map<String, dynamic> optionsJson = jsonDecode(optRes.body);

      // 🔥 حل مشكلة الـ Type Cast لحقل allowCredentials ليتوافق مع لغة دارت وحزمة Passkeys
      if (optionsJson['allowCredentials'] != null &&
          optionsJson['allowCredentials'] is List) {
        final List<dynamic> allowList = optionsJson['allowCredentials'];

        optionsJson['allowCredentials'] = allowList.map((item) {
          if (item is Map) {
            return {
              // نضمن تحويل الـ id إلى String آمن مع تجنب الـ null
              'id': item['id']?.toString() ?? '',
              'type': item['type'] ?? 'public-key',
              'transports':
                  item['transports'] ??
                  [], // حماية الحقل من الـ null لمنع انهيار الـ Parsing في الأندرويد
            };
          }
          return item;
        }).toList();
      } else {
        optionsJson['allowCredentials'] = [];
      }

      if (kDebugMode) {
        print('🟢 [verifyBiometric] خيارات التحقق جاهزة ومطهرة: $optionsJson');
      }

      // ب. بناء كائن التحقق الصحيح وتفعيل مستشعر البصمة لقراءة الـ Passkey
      final authenticateRequest = AuthenticateRequestType.fromJson(optionsJson);
      if (kDebugMode) {
        print(
          '🟢 [verifyBiometric] تم بناء كائن AuthenticateRequestType بنجاح',
        );
      }

      // النتيجة القادمة هنا تكون من نوع AuthenticateResponseType
      final authenticateResponse = await _passkeyAuthenticator.authenticate(
        authenticateRequest,
      );
      if (kDebugMode) {
        print(
          '🟢 [verifyBiometric] تم الحصول على استجابة authenticateResponse',
        );
      }

      // ج. إرسال التوقيع الرقمي للباك إند للتحقق النهائي والملكية
      final verifyRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/verify'),
        headers: headers,
        body: jsonEncode({
          "authenticationResponse": authenticateResponse.toJson(),
        }),
      );

      if (kDebugMode) {
        print(
          '🟡 [verifyBiometric] استجابة التحقق النهائي: status=${verifyRes.statusCode} body=${verifyRes.body}',
        );
      }

      final data = jsonDecode(verifyRes.body);

      // 🛠️ تم التصحيح: فحص الـ verifyRes.statusCode بشكل صحيح بدلاً من التكرار العارض لـ optRes
      if ((verifyRes.statusCode != 200 && verifyRes.statusCode != 201) ||
          data['valid'] != true) {
        if (kDebugMode) {
          print(
            '🔴 [verifyBiometric] التوقيع البيومتري غير صحيح أو فشل التحقق',
          );
        }
        return {'success': false, 'error': 'INVALID_BIOMETRIC_SIGNATURE'};
      }

      if (kDebugMode) {
        print('✅ [verifyBiometric] تم التحقق بنجاح وتأكيد ملكية الـ Passkey');
      }
      return {'success': true};
    } catch (e) {
      if (kDebugMode) {
        print('🔴 [verifyBiometric] حدث استثناء: $e');
      }
      if (e is PasskeyAuthCancelledException || e is PlatformException) {
        return {'success': false, 'error': 'USER_CANCELLED'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
