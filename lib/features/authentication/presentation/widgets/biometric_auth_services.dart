import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

// الاستيرادات الأساسية من المكتبة الخاصة بك
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

  /// 1️⃣ خطوة التسجيل والربط (لأول مرة فقط)
  Future<Map<String, dynamic>> registerBiometric({
    required String sessionToken,
    String? deviceName,
  }) async {
    try {
      print('🔵 [registerBiometric] بدء التسجيل البيومتري...');
      // أ. طلب خيارات التسجيل (Register Options) من الباك إند
      final optRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/register-options'),
        headers: {
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
        },
        body: jsonEncode({"deviceName": deviceName ?? "Mobile Device"}),
      );
      print(
        '🟡 [registerBiometric] استجابة خيارات التسجيل: status=${optRes.statusCode} body=${optRes.body}',
      );

      if (optRes.statusCode != 200) {
        print('🔴 [registerBiometric] فشل في الحصول على خيارات التسجيل');
        return {'success': false, 'error': 'FAILED_TO_GET_OPTIONS'};
      }

      // تحويل استجابة السيرفر النصية إلى Map
      final Map<String, dynamic> optionsJson = jsonDecode(optRes.body);
      print('🟢 [registerBiometric] خيارات التسجيل جاهزة: $optionsJson');

      // ب. بناء الكائن الصحيح المتوقع وتمريره لمستشعر البصمة
      final registerRequest = RegisterRequestType.fromJson(optionsJson);
      print('🟢 [registerBiometric] تم بناء كائن RegisterRequestType');

      // النتيجة القادمة هنا تكون من نوع RegisterResponseType
      final registerResponse = await _passkeyAuthenticator.register(
        registerRequest,
      );
      print(
        '🟢 [registerBiometric] تم الحصول على استجابة البصمة registerResponse',
      );

      // ج. إرسال استجابة البصمة المشفرة إلى الباك إند للتأكد وحفظها في السيرفر
      final verifyRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/register'),
        headers: {
          'Content-Type': 'application/json',
          'x-session-token': sessionToken,
        },
        body: jsonEncode({
          // تم التصحيح: تحويل الكائن مباشرة إلى JSON لأن المكتبة تعيده كـ Object وليس String
          "registrationResponse": registerResponse.toJson(),
          "deviceName": deviceName ?? "Mobile Device",
        }),
      );
      print(
        '🟡 [registerBiometric] استجابة التحقق النهائي: status=${verifyRes.statusCode} body=${verifyRes.body}',
      );

      if (verifyRes.statusCode != 200) {
        print('🔴 [registerBiometric] فشل التحقق النهائي من السيرفر');
        return {'success': false, 'error': 'SERVER_VERIFICATION_FAILED'};
      }

      final result = jsonDecode(verifyRes.body);
      print('✅ [registerBiometric] تم التسجيل بنجاح: $result');
      return {
        'success': true,
        'credentialId': result['id'] ?? result['credentialId'] ?? '',
      };
    } catch (e) {
      print('🔴 [registerBiometric] حدث استثناء: $e');
      if (e is PasskeyAuthCancelledException || e is PlatformException) {
        return {'success': false, 'error': 'USER_CANCELLED'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }

  /// 2️⃣ خطوة التحقق وفك القفل التلقائي (في المرات القادمة)
  Future<Map<String, dynamic>> verifyBiometric() async {
    try {
      print('🔵 [verifyBiometric] بدء التحقق البيومتري...');
      // أ. طلب خيارات التحقق (Auth Options) من الباك إند
      final optRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/auth-options'),
        headers: {'Content-Type': 'application/json'},
      );
      print(
        '🟡 [verifyBiometric] استجابة خيارات التحقق: status=${optRes.statusCode} body=${optRes.body}',
      );

      if (optRes.statusCode != 200) {
        print('🔴 [verifyBiometric] فشل في الحصول على خيارات التحقق');
        return {'success': false, 'error': 'FAILED_TO_GET_AUTH_OPTIONS'};
      }

      // تحويل استجابة السيرفر النصية إلى Map
      final Map<String, dynamic> optionsJson = jsonDecode(optRes.body);
      print('🟢 [verifyBiometric] خيارات التحقق جاهزة: $optionsJson');

      // ب. بناء كائن التحقق الصحيح وتفعيل مستشعر البصمة لقراءة الـ Passkey
      final authenticateRequest = AuthenticateRequestType.fromJson(optionsJson);
      print('🟢 [verifyBiometric] تم بناء كائن AuthenticateRequestType');

      // النتيجة القادمة هنا تكون من نوع AuthenticateResponseType
      final authenticateResponse = await _passkeyAuthenticator.authenticate(
        authenticateRequest,
      );
      print('🟢 [verifyBiometric] تم الحصول على استجابة authenticateResponse');

      // ج. إرسال التوقيع الرقمي للباك إند للتحقق النهائي والملكية
      final verifyRes = await http.post(
        Uri.parse('$baseUrl/sessions/passkey/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          // تم التصحيح: تحويل الكائن مباشرة إلى JSON المتوقع للباك إند بدون شروط معقدة
          "authenticationResponse": authenticateResponse.toJson(),
        }),
      );
      print(
        '🟡 [verifyBiometric] استجابة التحقق النهائي: status=${verifyRes.statusCode} body=${verifyRes.body}',
      );

      final data = jsonDecode(verifyRes.body);

      if (verifyRes.statusCode != 200 || data['valid'] != true) {
        print('🔴 [verifyBiometric] التوقيع البيومتري غير صحيح أو فشل التحقق');
        return {'success': false, 'error': 'INVALID_BIOMETRIC_SIGNATURE'};
      }

      print('✅ [verifyBiometric] تم التحقق بنجاح');
      return {'success': true};
    } catch (e) {
      print('🔴 [verifyBiometric] حدث استثناء: $e');
      if (e is PasskeyAuthCancelledException || e is PlatformException) {
        return {'success': false, 'error': 'USER_CANCELLED'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
