import 'package:flutter_dotenv/flutter_dotenv.dart';

/// مسارات خادم الـ KYC. خطوة التحقّق بالوجه (step-up) تقبل `Authorization: Bearer`
/// فتعمل من العميل الأصلي مباشرةً.
abstract class KycEndPoints {
  // إعادة التحقّق بالوجه (Face re-verification) — مدخلها challengeId من init.
  static const reverifyStartEP = 'api/kyc/reverify/start';
  static const reverifyVerifyEP = 'api/kyc/reverify/verify';
}

abstract class KycUrls {
  /// تُستخدم host+scheme فقط (PostClient يضع المسار الكامل في endpoint).
  static Uri get baseUri => Uri.parse(_baseUrl);

  static String get _baseUrl => dotenv.env['KYC_URL'] ?? '';
}
