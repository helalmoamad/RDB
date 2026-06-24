import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:rdb/core/domin/repositories/prefs_repository.dart';
// مُبقى جاهزاً للتنقّل عند ملء حالات الأنواع (GRouter.router.go(...)).
// ignore: unused_import
import 'package:rdb/routes/router.dart';
import 'package:trydos_wallet/trydos_wallet.dart';

import '../notification_model.dart';

/// 🎯 المعالج المركزي لكل إشعار حسب نوعه (`type`).
///
/// يُستدعى من [AppNotificationService] (foreground/opened/tap) ومن معالج الخلفية.
/// أضِف حالة لكل قيمة `type` يرسلها الباك، ونفّذ منطقها (تنقّل / تحديث حالة / ...).
///
/// ⚠️ التنقّل في الواجهة مسموح فقط عندما يكون [source] ناتجاً عن **تفاعل المستخدم**
/// (فتح من إشعار أو ضغط)، لأن مصدر `background` يعمل في isolate منفصل بلا واجهة.
Future<void> handleWithNotificationType(
  AppNotification notification, {
  required NotificationSource source,
}) async {
  final bool isUserAction =
      source == NotificationSource.openedFromBackground ||
      source == NotificationSource.openedFromTerminated ||
      source == NotificationSource.localTap;

  switch (notification.type) {
    // ───────────────────────────────────────────────────────────────────
    // ⬇️ أضف الأنواع الفعلية هنا. لكل نوع: اقرأ notification.data، ونفّذ المنطق.
    //
    // مثال جاهز للنسخ عند معرفة النوع:
    // case NotificationTypes.transferReceived:
    //   final amount = notification.data['amount'];
    //   if (isUserAction) {
    //     GRouter.router.go(GRouter.config.kBasePage); // أو شاشة التفاصيل
    //   }
    //   break;
    // ───────────────────────────────────────────────────────────────────

    case NotificationTypes.example:
      if (kDebugMode) {
        debugPrint('📩 example notification | data=${notification.data}');
      }
      if (isUserAction) {
        // مثال تنقّل (مفعّل لاحقاً حسب وجهة هذا النوع):
        // GRouter.router.go(GRouter.config.kBasePage);
      }
      break;

    case NotificationTypes.approvalRequest:
      if (source == NotificationSource.foreground) {
        // التطبيق مفتوح → نفّذ التعليمة مباشرةً بلا تخزين.
        TrydosWallet.handleSessionApprovalRequest(notification.data);
      } else {
        // خارج foreground (خلفية/مغلق/فتح من إشعار) → خزّن الأحدث (overwrite)
        // ليُنفَّذ بعد الوصول للـ HomePage وفك القفل، ثم يُمسح.
        final prefs = GetIt.I<PrefsRepository>();
        await prefs.setPendingApprovalRequest(true);
        await prefs.setPendingApprovalRequestData(
          jsonEncode(notification.data),
        );
      }
      break;

    default:
      if (kDebugMode) {
        debugPrint(
          '📩 نوع إشعار غير معالَج: ${notification.type} | data=${notification.data}',
        );
      }
      // سلوك افتراضي عند فتح إشعار غير معروف (اختياري):
      // if (isUserAction) GRouter.router.go(GRouter.config.kBasePage);
      break;
  }
}
