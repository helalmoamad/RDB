import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //todo initialize the notification
  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    //todo initialize ios settings
    var initializationSettingIos = const DarwinInitializationSettings();
    var initializeSettings = InitializationSettings(
      iOS: initializationSettingIos,
      android: initializationSettingsAndroid,
    );

    notificationsPlugin.initialize(
      initializeSettings,
      // ignore: avoid_print
      onDidReceiveBackgroundNotificationResponse: (details) => print(
        "111111111111111fffffffffffffffffffRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR${details.payload}",
      ),
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {},
    );
    notificationsPlugin.getNotificationAppLaunchDetails().then(
      // ignore: avoid_print
      (value) => print(
        "fffffffffffffffffffRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR${value?.notificationResponse?.payload}",
      ),
    );
  }

  Future<void> uploadingNotification(maxProgress, progress, isUploading) async {
    if (isUploading) {
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            "uploading files",
            "Uploading Files Notifications",
            channelDescription: "show to user progress for uploading files",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.max,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: progress,
            autoCancel: false,
          );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await notificationsPlugin.show(
        5,
        'Uploading story',
        '',
        platformChannelSpecifics,
      );
    } else {
      notificationsPlugin.cancel(5);
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          const AndroidNotificationDetails(
            "files",
            "Files Notifications",
            channelDescription: "Inform user files uploaded",
            channelShowBadge: false,
            importance: Importance.max,
            priority: Priority.max,
            onlyAlertOnce: true,
          );

      NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      await notificationsPlugin.show(
        // معرّف إشعار محلّي لتمييز الإشعارات عن بعضها، وليس قيمة أمنية — لا
        // يُشتق منه سرّ ولا يُرسل للخادم، فلا حاجة لـ Random.secure().
        // nosemgrep: rdb-dart-insecure-random-for-security
        Random().nextInt(1000000),
        'upload story success',
        '',
        platformChannelSpecifics,
      );
    }
  }

  NotificationDetails? notificationDetails() {
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(),
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        priority: Priority.max,
        importance: Importance.max,
      ),
    );
  }

  Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }
}
