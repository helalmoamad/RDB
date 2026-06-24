import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

/// خدمة التحليلات (PostHog) — تُهيّأ مرة واحدة عند إقلاع التطبيق.
///
/// PostHog هو singleton على مستوى العملية، لذلك بمجرد التهيئة هنا فإن كل
/// أجزاء التطبيق — بما فيها شاشات مكتبة `trydos_wallet` التي تُعرض داخل نفس
/// شجرة الويدجت — تُراقَب تلقائياً عبر Session Replay (يلتقط الشاشة بالكامل)
/// وعبر [PosthogObserver] المضاف إلى الراوتر.
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // رموز ANSI لتلوين طباعة الـ console.
  static const String _green = '\x1B[32m';
  static const String _red = '\x1B[31m';
  static const String _yellow = '\x1B[33m';
  static const String _reset = '\x1B[0m';

  void _logSuccess(String msg) => debugPrint('$_green$msg$_reset');
  void _logError(String msg) => debugPrint('$_red$msg$_reset');
  void _logWarn(String msg) => debugPrint('$_yellow$msg$_reset');

  /// تهيئة PostHog. تُستدعى بعد تحميل ملف `.env` وقبل عرض التطبيق.
  Future<void> init() async {
    if (_initialized) return;

    final apiKey = dotenv.env['POSTHOG_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _logError('🔴 PostHog: POSTHOG_API_KEY مفقود — تم تخطّي التهيئة.');
      return;
    }

    final config = PostHogConfig(apiKey)
      ..host = dotenv.env['POSTHOG_HOST'] ?? 'https://us.i.posthog.com'
      ..debug = kDebugMode
      // أحداث دورة حياة التطبيق (فتح/خلفية/استئناف).
      ..captureApplicationLifecycleEvents = true
      // تسجيل الجلسات (Session Replay) — يلتقط كل الشاشات بما فيها شاشات المحفظة.
      ..sessionReplay = true
      // التحكّم بزمن إرسال الأحداث من الطابور:
      // - flushAt: عدد الأحداث المتراكمة قبل الإرسال (الافتراضي 20).
      // - flushInterval: أقصى مهلة قبل الإرسال بأي حال (الافتراضي 30 ثانية).
      // في التطوير نرسل فوراً (1) كل 5 ثوانٍ لرؤية البيانات بسرعة، وفي الإنتاج
      // نُبقي التجميع الفعّال لتوفير البطارية والشبكة.
      ..flushAt = 4
      ..flushInterval = const Duration(seconds: 2);

    // إظهار النصوص العادية في التسجيل (maskAllTexts = false). الإخفاء صار
    // انتقائياً: لفّ أي ويدجت حسّاس (رصيد، رقم بطاقة، OTP، اسم/هاتف) بـ
    // PostHogMaskWidget(child: ...) ليظهر صندوقاً مخفياً فقط هو.
    config.sessionReplayConfig
      ..maskAllTexts = false
      ..maskAllImages = false;

    // تتبّع الأخطاء (Error Tracking) — تُرسَل كأحداث $exception. كلها معطّلة
    // افتراضياً في الحزمة، لذلك نفعّلها صراحةً.
    config.errorTrackingConfig
      ..captureFlutterErrors =
          true // أخطاء إطار Flutter (FlutterError.onError)
      ..capturePlatformDispatcherErrors =
          true // أخطاء Dart غير المتزامنة
      ..captureIsolateErrors =
          true // أخطاء الـ isolates
      ..captureNativeExceptions =
          true // كراش أصلي (Android/iOS)
      // اعتبار كود تطبيقنا + المحفظة "in-app" لتمييزه عن أكواد الطرف الثالث.
      ..inAppIncludes.addAll(['package:rdb', 'package:trydos_wallet']);

    try {
      await Posthog().setup(config);
      _initialized = true;
      _logSuccess('🟢 PostHog: تمّت التهيئة بنجاح (host: ${config.host}).');

      // طباعة معرّف الجلسة الأولى عند فتحها (قد يتأخّر إنشاؤها لحظات).
      try {
        final sessionId = await Posthog().getSessionId();
        if (sessionId != null && sessionId.isNotEmpty) {
          _logSuccess('🟢 PostHog: فُتحت أول جلسة — sessionId: $sessionId');
        } else {
          _logWarn(
            '🟡 PostHog: تمّت التهيئة لكن لم تُفتح جلسة بعد '
            '(ستُفتح عند أول نشاط/شاشة).',
          );
        }
      } catch (e) {
        _logWarn('🟡 PostHog: تعذّر قراءة معرّف الجلسة: $e');
      }
    } catch (e, st) {
      _logError('🔴 PostHog: فشلت التهيئة — $e');
      _logError('🔴 PostHog stackTrace: $st');
    }
  }

  /// ربط الجلسة بالمستخدم الحالي (تُستدعى بعد تسجيل الدخول / تهيئة المحفظة).
  Future<void> identify({
    required String userId,
    Map<String, Object>? properties,
  }) async {
    if (!_initialized || userId.isEmpty) return;
    await Posthog().identify(userId: userId, userProperties: properties);
  }

  /// حدث مخصص.
  Future<void> capture(
    String eventName, {
    Map<String, Object>? properties,
  }) async {
    if (!_initialized) return;
    await Posthog().capture(eventName: eventName, properties: properties);
  }

  /// تسجيل عرض شاشة يدوياً (مفيد للشاشات التي لا يلتقطها الـ observer).
  Future<void> screen(
    String screenName, {
    Map<String, Object>? properties,
  }) async {
    if (!_initialized) return;
    await Posthog().screen(screenName: screenName, properties: properties);
  }

  /// التقاط استثناء يدوياً (داخل try/catch) — يُرسَل كحدث \u200E$exception.
  Future<void> captureException(
    Object error, {
    StackTrace? stackTrace,
    Map<String, Object>? properties,
  }) async {
    if (!_initialized) return;
    await Posthog().captureException(
      error: error,
      stackTrace: stackTrace,
      properties: properties,
    );
  }

  /// دفع كل ما في الطابور (أحداث + لقطات Session Replay) فوراً إلى الخادم.
  /// يُستدعى عند انتقال التطبيق للخلفية لتقليل فقدان آخر اللقطات قبل الإغلاق.
  Future<void> flush() async {
    if (!_initialized) return;
    try {
      await Posthog().flush();
    } catch (e) {
      _logWarn('🟡 PostHog: تعذّر الـ flush: $e');
    }
  }

  /// مسح هوية المستخدم عند تسجيل الخروج.
  Future<void> reset() async {
    if (!_initialized) return;
    await Posthog().reset();
  }
}
