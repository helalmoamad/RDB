import '../notification_utils/payload_model.dart';
import '../type_notification/activity_notification.dart';
import 'i_notification_factory.dart';
import 'notification_type.dart';

class NotificationFactoryImpl extends INotificationFactory {

  final typesNotification = <NotificationTypeName, NotificationType>{
    NotificationTypeName.delivery: DeliveryNotification(),
  };

  @override
  NotificationType getNotificationType(NotificationTypeName type) {
    return typesNotification[type]!;
  }
}
