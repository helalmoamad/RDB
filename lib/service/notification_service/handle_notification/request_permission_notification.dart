import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// إدارة إذن الإشعارات (Android 13+ / iOS). يُستدعى من [AppNotificationService.init].
class PermissionServices {
  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) {
      return;
    }

    if (status.isPermanentlyDenied) {
      // رُفض بشكل دائم — لا يمكن الطلب مجدداً، نفتح الإعدادات.
      await openAppSettings();
      return;
    }

    // مرفوض/غير محدّد بعد — اطلب الإذن.
    final result = await Permission.notification.request();
    if (result.isPermanentlyDenied) {
      await openAppSettings();
    } else if (kDebugMode) {
      debugPrint('Notification permission result: $result');
    }
  }
}
