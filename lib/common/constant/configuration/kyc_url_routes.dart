import 'package:flutter_dotenv/flutter_dotenv.dart';

/// مسارات خادم الـ KYC. خطوة التحقّق بالوجه (step-up) تقبل `Authorization: Bearer`
/// فتعمل من العميل الأصلي مباشرةً.
abstract class KycEndPoints {
  // إعادة التحقّق بالوجه (Face re-verification) — مدخلها challengeId من init.
  static const reverifyStartEP = 'api/kyc/reverify/start';
  static const reverifyVerifyEP = 'api/kyc/reverify/verify';

  // ── نقطة التبديل الوحيدة لتدفّق إعادة تعيين رمز المرور ──
  // العقد الحالي المؤكَّد مع الباك: **نفس المسار** في الحالتين؛ الفرق في التوكن
  // فقط (idle-lock = walletToken، mid-login = session stepToken — يُختار عبر
  // ServerName.kyc / ServerName.kycStep في detect_server.dart).
  //
  // ملاحظة: مسارا الويب `kyc/reverify/commit` و `kyc/reverify/step/commit`
  // الواردان في دليل التكامل هما نداءا Worker ← خادم ولا يستخدمهما الموبايل؛
  // الموبايل يرسل الصورة الخام إلى `reverify/verify` والخادم يحسب النتيجة.
  //
  // إن أضاف الباك لاحقًا نسخة `step/` لهذين المسارين، **عدِّل هنا فقط**.
  static String reverifyStart({required bool midLogin}) => reverifyStartEP;

  static String reverifyVerify({required bool midLogin}) => reverifyVerifyEP;
}

abstract class KycUrls {
  /// تُستخدم host+scheme فقط (PostClient يضع المسار الكامل في endpoint).
  static Uri get baseUri => Uri.parse(_baseUrl);

  static String get _baseUrl => dotenv.env['KYC_URL'] ?? '';
}
