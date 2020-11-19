import 'package:firebase_messaging/firebase_messaging.dart';

class NotifHandler {
  final _firebaseMessaging = FirebaseMessaging();

  Future<String> fetchDeviceToken() async {
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    // listen to user's settings changes
    // _firebaseMessaging.onIosSettingsRegistered.listen(
    //     (IosNotificationSettings settings) =>
    //         print("Settings registered: $settings"));
    return _firebaseMessaging.getToken();
  }
}
