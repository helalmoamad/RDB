import '../notification_utils/payload_model.dart';
import 'notification_type.dart';

abstract class INotificationFactory{
  NotificationType getNotificationType(NotificationTypeName type);
}