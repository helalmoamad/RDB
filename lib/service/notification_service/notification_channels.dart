import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// قنوات إشعارات Android (مطلوبة من Android 8+). عرّف كل قناة مرّة واحدة هنا،
/// وتُنشأ جميعها عند تهيئة [AppNotificationService].
class NotificationChannels {
  NotificationChannels._();

  /// القناة العامة للإشعارات المهمة (افتراضية).
  static const AndroidNotificationChannel high = AndroidNotificationChannel(
    'high_importance_channel',
    'إشعارات مهمة',
    description: 'قناة الإشعارات العامة عالية الأهمية',
    importance: Importance.max,
  );

  /// أضف قنوات أخرى حسب الحاجة (مثل قناة هادئة للعروض) وأضِفها إلى [all].
  // static const AndroidNotificationChannel promo = AndroidNotificationChannel(
  //   'promo_channel', 'عروض', description: 'إشعارات العروض', importance: Importance.defaultImportance,
  // );

  static List<AndroidNotificationChannel> get all => [high];
}
