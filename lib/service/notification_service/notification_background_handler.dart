import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/data/repository/prefs_repository_impl.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
import 'package:rdb/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'handle_notification/handle_with_notification_type.dart';
import 'notification_model.dart';

/// معالج رسائل FCM عندما يكون التطبيق في الخلفية أو مغلقاً تماماً.
///
/// يعمل في **isolate منفصل** — لذا:
/// - يجب تهيئة Firebase بداخله من جديد.
/// - لا يجوز أي تنقّل/تحديث واجهة هنا (المعالجة بيانات فقط عبر النوع).
///
/// يُسجَّل مرة واحدة في [AppNotificationService.init] عبر
/// `FirebaseMessaging.onBackgroundMessage(notificationBackgroundHandler)`.
@pragma('vm:entry-point')
Future<void> notificationBackgroundHandler(RemoteMessage message) async {
  // تسجيل الإضافات في isolate الخلفية حتى تعمل SharedPreferences/SecureStorage.
  DartPluginRegistrant.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    // على iOS قد يرمي DefaultFirebaseOptions — نعتمد على ملف الإعداد الأصلي.
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    } catch (e) {
      if (kDebugMode) debugPrint('bg Firebase init failed: $e');
    }
  }

  // DI غير مُهيّأ في isolate الخلفية — نسجّل PrefsRepository يدوياً حتى يستطيع
  // [handleWithNotificationType] تخزين طلب الموافقة عبر نفس impl المستخدم في
  // التطبيق (PrefsRepositoryImpl).
  if (!GetIt.I.isRegistered<PrefsRepository>()) {
    try {
      final sp = await SharedPreferences.getInstance();
      final repo = await PrefsRepositoryImpl.create(
        sp,
        const FlutterSecureStorage(),
      );
      GetIt.I.registerSingleton<PrefsRepository>(repo);
    } catch (e) {
      if (kDebugMode) debugPrint('bg PrefsRepository init failed: $e');
    }
  }

  final notification = AppNotification.fromRemoteMessage(message);
  await handleWithNotificationType(
    notification,
    source: NotificationSource.background,
  );
}

/// معالج الضغط على إشعار محلّي عندما يكون التطبيق في الخلفية (top-level مطلوب).
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // ضغط على إشعار محلّي والتطبيق في الخلفية — لا تنقّل واجهة هنا.
  // عند فتح التطبيق ستُعالَج الوجهة عبر getInitialMessage/onMessageOpenedApp.
  if (kDebugMode) {
    debugPrint('Local notification tapped (bg): ${response.payload}');
  }
}
