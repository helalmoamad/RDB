import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

/// أنواع الإشعارات — مكان واحد لتعريف قيم `type` القادمة من الباك.
///
/// ⬇️ لاحقاً: استبدل/أضف الثوابت هنا بقيم `type` الفعلية، ثم عالِجها في
/// [handleWithNotificationType] داخل `handle_notification/handle_with_notification_type.dart`.
class NotificationTypes {
  NotificationTypes._();

  // أمثلة مبدئية (للحذف/التعديل عند معرفة الأنواع الحقيقية):
  static const String example = 'example';

  /// طلب موافقة جلسة — يُعالَج عبر TrydosWallet.handleSessionApprovalRequest.
  static const String approvalRequest = 'approval_request';
  // static const String transferReceived = 'transfer_received';
  // static const String kycApproved = 'kyc_approved';
  // static const String promo = 'promo';
}

/// مصدر/سياق وصول الإشعار — يحدّد ما إذا كان يجوز التنقّل في الواجهة.
enum NotificationSource {
  /// التطبيق مفتوح والمستخدم يراه (foreground).
  foreground,

  /// رسالة وصلت والتطبيق في الخلفية/مغلق (isolate الخلفية — لا تنقّل واجهة).
  background,

  /// فتح المستخدم التطبيق بالضغط على إشعار والتطبيق كان في الخلفية.
  openedFromBackground,

  /// فتح المستخدم التطبيق من إشعار والتطبيق كان مغلقاً تماماً (terminated).
  openedFromTerminated,

  /// ضغط المستخدم على إشعار محلّي (flutter_local_notifications).
  localTap,
}

/// نموذج موحّد لأي إشعار — يفكّ `RemoteMessage` أو payload محلّي إلى
/// (type / title / body / data) ليتعامل معه باقي النظام بشكل موحّد.
class AppNotification {
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;

  /// معرّف العرض المحلّي للإشعار (يُستخدم في show/cancel).
  final int notificationId;

  AppNotification({
    this.type,
    this.title,
    this.body,
    Map<String, dynamic>? data,
    int? notificationId,
  }) : data = data ?? const <String, dynamic>{},
       notificationId =
           notificationId ??
           (int.tryParse('${(data ?? const {})['id'] ?? ''}') ??
               DateTime.now().millisecondsSinceEpoch.remainder(100000));

  /// من رسالة FCM (foreground/background/opened).
  factory AppNotification.fromRemoteMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    return AppNotification(
      type: (data['type'] ?? data['notification_type'])?.toString(),
      title: message.notification?.title ?? data['title']?.toString(),
      body: message.notification?.body ?? data['body']?.toString(),
      data: data,
    );
  }

  /// من payload إشعار محلّي (سلسلة JSON خزّناها عند العرض).
  factory AppNotification.fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return AppNotification();
    try {
      final map = jsonDecode(payload) as Map<String, dynamic>;
      return AppNotification(
        type: map['type']?.toString(),
        title: map['title']?.toString(),
        body: map['body']?.toString(),
        data: Map<String, dynamic>.from(map['data'] ?? const {}),
      );
    } catch (_) {
      return AppNotification();
    }
  }

  /// تحويل الإشعار إلى payload JSON لتخزينه على الإشعار المحلّي ثم قراءته عند الضغط.
  String toPayload() => jsonEncode({
    'type': type,
    'title': title,
    'body': body,
    'data': data,
  });
}
