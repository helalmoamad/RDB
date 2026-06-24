import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/features/authentication/presentation/manager/auth_bloc.dart';
import 'package:rdb/firebase_options.dart';

import 'handle_notification/handle_with_notification_type.dart';
import 'notification_background_handler.dart';
import 'notification_channels.dart';
import 'notification_model.dart';

/// 🔔 الخدمة المركزية الوحيدة لإدارة الإشعارات (Firebase Messaging +
/// flutter_local_notifications) — التهيئة، الأذونات، القنوات، التوكن،
/// واستقبال الرسائل في كل الحالات (foreground / background / فتح من إشعار).
///
/// الاستخدام: `await AppNotificationService.instance.init();` مرة واحدة عند الإقلاع.
/// منطق كل نوع إشعار في [handleWithNotificationType] (ملف منفصل).
class AppNotificationService {
  AppNotificationService._();
  static final AppNotificationService instance = AppNotificationService._();

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// تهيئة كاملة. آمنة للاستدعاء أكثر من مرة (تُنفّذ مرّة واحدة فعلياً).
  Future<void> init() async {
    if (_initialized) return;
    try {
      await _initFirebase();

      // تسجيل معالج الخلفية (يجب أن يكون دالة top-level).
      FirebaseMessaging.onBackgroundMessage(notificationBackgroundHandler);

      // ملاحظة: لا نطلب إذن الإشعارات هنا. الطلب يتم لاحقاً عبر
      // [ensureNotificationPermission] بعد الوصول للـ HomePage وفك القفل
      // (إن وُجد passcode) — ويُفحص عند كل فتح للتطبيق.
      await _initLocalNotifications();
      await _createAndroidChannels();
      _wireForegroundListeners();
      await _handleInitialMessage();
      // إفراغ شريط الإشعارات عند الإقلاع (بعد معالجة إشعار الفتح إن وُجد).
      // نداء مباشر لأن _initialized لم يُضبط بعد في هذه المرحلة.
      try {
        await _local.cancelAll();
      } catch (_) {}
      // نستمع لتجديد التوكن فقط هنا. جلب التوكن الأول يتم **بعد منح الإذن**
      // داخل [ensureNotificationPermission] (مهم لـ iOS الذي يتطلّب APNs/إذناً).
      _listenTokenRefresh();

      _initialized = true;
      if (kDebugMode) debugPrint('🔔 AppNotificationService initialized');
    } catch (e, st) {
      if (kDebugMode) debugPrint('🔔 Notification init failed: $e\n$st');
    }
  }

  // ───────────────────────── التهيئة ─────────────────────────

  Future<void> _initFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {
      // iOS: DefaultFirebaseOptions غير مهيّأ بعد — نعتمد على GoogleService-Info.plist.
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    }
  }

  /// يتحقّق من إذن الإشعارات ويطلبه إن لم يكن مفعّلاً. آمن للاستدعاء عند كل
  /// فتح للتطبيق — يعود فوراً إذا كان الإذن ممنوحاً، ولا يفتح الإعدادات تلقائياً
  /// (حتى لا نُزعج المستخدم عند الرفض الدائم في كل مرة).
  ///
  /// يُستدعى بعد الوصول للـ HomePage: مباشرةً إن لم يكن هناك passcode، أو بعد
  /// إدخال الـ passcode الصحيح (فك القفل).
  Future<void> ensureNotificationPermission() async {
    try {
      var status = await Permission.notification.status;
      if (status.isPermanentlyDenied) return;

      if (!status.isGranted) {
        status = await Permission.notification.request();
        // iOS/APNs: تأكيد التسجيل لدى FCM (لا يُظهر نافذة ثانية إن مُنح الإذن).
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // بعد التأكد من منح الإذن: اجلب توكن FCM وأرسله (مهم لـ iOS فور الموافقة).
      if (status.isGranted) {
        await _fetchAndReportToken();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 ensureNotificationPermission failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _createAndroidChannels() async {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    for (final channel in NotificationChannels.all) {
      await android.createNotificationChannel(channel);
    }
  }

  // ───────────────────────── المستمعون ─────────────────────────

  void _wireForegroundListeners() {
    // التطبيق مفتوح: FCM لا يعرض الإشعار تلقائياً → نعرضه محلّياً ثم نعالجه.
    // استثناء: approval_request يُنفَّذ مباشرةً (TrydosWallet) فلا نعرض له بانراً.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = AppNotification.fromRemoteMessage(message);
      if (notification.type != NotificationTypes.approvalRequest) {
        showLocalNotification(notification);
      }
      handleWithNotificationType(
        notification,
        source: NotificationSource.foreground,
      );
    });

    // المستخدم فتح التطبيق بالضغط على إشعار والتطبيق في الخلفية.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final notification = AppNotification.fromRemoteMessage(message);
      handleWithNotificationType(
        notification,
        source: NotificationSource.openedFromBackground,
      );
    });
  }

  /// إشعار فتح التطبيق من حالة الإغلاق التام (terminated).
  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message == null) return;
    final notification = AppNotification.fromRemoteMessage(message);
    await handleWithNotificationType(
      notification,
      source: NotificationSource.openedFromTerminated,
    );
  }

  // ───────────────────────── التوكن ─────────────────────────

  /// يستمع لتجديد توكن FCM (يُسجَّل عند التهيئة) — شبكة أمان تلتقط التوكن متى
  /// أصدره النظام (مثلاً على iOS بعد تسجيل APNs عقب منح الإذن).
  void _listenTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      if (token == _fcmToken) return;
      _fcmToken = token;
      _onTokenReady(token);
    });
  }

  /// يجلب توكن FCM ويُمرّره لـ [_onTokenReady]. يُستدعى **بعد التأكد من منح الإذن**.
  /// قرار الإرسال/منع التكرار يتم داخل [_onTokenReady] عبر `sentFcmToken` المخزّن،
  /// فتعمل إعادة المحاولة عند كل فتح إذا فشل الإرسال سابقاً.
  Future<void> _fetchAndReportToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (kDebugMode) debugPrint('🔔 FCM token: $token');
      if (token != null) {
        _fcmToken = token;
        _onTokenReady(token);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 getToken failed: $e');
    }
  }

  /// تنظيف عند تسجيل الخروج: يُبطل توكن FCM الحالي (فلا تصل إشعارات للمستخدم
  /// السابق على هذا الجهاز) ويمسح التوكن المخزّن وحالة الإرسال — حتى يبدأ
  /// المستخدم التالي بتوكن جديد يُرسَل للباك من جديد دون تعارض.
  Future<void> onLogout() async {
    // امسح الحالة المخزّنة أولاً (سريع/محلي) حتى تكون متّسقة حتى لو تأخّر/فشل
    // إبطال التوكن بسبب الشبكة.
    _fcmToken = null;
    final prefs = GetIt.I<PrefsRepository>();
    await prefs.setFcmTokenId('');
    await prefs.setSentFcmToken('');
    // إبطال توكن FCM (best-effort) — يولّد النظام توكناً جديداً للمستخدم التالي.
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 deleteToken failed: $e');
    }
  }

  /// التوكن جاهز/تغيّر — يُخزَّن في SharedPreferences ويُرسل للباك عبر AuthBloc.
  ///
  /// منطق منع التكرار: نرسل فقط إذا اختلف التوكن عن آخر توكن أُرسل بنجاح
  /// (`sentFcmToken`). لذا:
  /// - نجح الإرسال سابقاً ولم يتغيّر → لا نُعيد الإرسال.
  /// - فشل سابقاً (لم يُخزَّن sentFcmToken) → يُعاد الإرسال عند كل فتح للتطبيق.
  /// - تغيّر التوكن → يُرسل الجديد.
  void _onTokenReady(String token) {
    final prefs = GetIt.I<PrefsRepository>();
    // خزّن التوكن الحالي دائماً.
    prefs.setFcmTokenId(token);
    // أُرسل بنجاح ولم يتغيّر → لا حاجة لإعادة الإرسال.
    if (token == prefs.sentFcmToken) return;
    GetIt.I<AuthBloc>().add(SendFcmTokenEvent(token));
  }

  // ───────────────────────── العرض/الضغط ─────────────────────────

  void _onLocalTap(NotificationResponse response) {
    final notification = AppNotification.fromPayload(response.payload);
    handleWithNotificationType(
      notification,
      source: NotificationSource.localTap,
    );
  }

  /// عرض إشعار محلّي (يُستخدم تلقائياً للرسائل في الواجهة، ويمكن استدعاؤه يدوياً).
  Future<void> showLocalNotification(AppNotification notification) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationChannels.high.id,
        NotificationChannels.high.name,
        channelDescription: NotificationChannels.high.description,
        importance: Importance.max,
        priority: Priority.max,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _local.show(
      notification.notificationId,
      notification.title,
      notification.body,
      details,
      payload: notification.toPayload(),
    );
  }

  /// إلغاء إشعار محدّد.
  Future<void> cancel(int id) => _local.cancel(id);

  /// مسح كل الإشعارات من شريط الإشعارات (المحلية و FCM المعروضة من النظام).
  /// يُستدعى عند فتح/استئناف التطبيق لإفراغ الشريط.
  Future<void> clearAll() async {
    if (!_initialized) return;
    try {
      await _local.cancelAll();
    } catch (e) {
      if (kDebugMode) debugPrint('🔔 cancelAll failed: $e');
    }
  }
}
