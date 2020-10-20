import 'package:notification_permissions/notification_permissions.dart';

class NotificationController {
  static NotificationController _instance;
  static NotificationController get instance {
    return (_instance =
        _instance == null ? NotificationController() : _instance);
  }

  Future<PermissionStatus> enableNotifications() async {
    return NotificationPermissions.requestNotificationPermissions();
  }

  Future<PermissionStatus> get permissionStatus =>
      NotificationPermissions.getNotificationPermissionStatus();
}
