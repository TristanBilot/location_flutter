import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import '../../../../stores/extensions.dart';

final _firebaseMessaging = FirebaseMessaging();

void listenToNotifications() {
  _firebaseMessaging.configure(
    onMessage: (message) => _handle(message),
    // onBackgroundMessage: _handle,
    onLaunch: (message) async {
      print("onLaunch: $message");
    },
    onResume: (message) async {
      print("onResume: $message");
    },
  );
}

Future<dynamic> _handle(Map<String, dynamic> message) {
  print(message);
  if (!message.containsKey(NotifField.notification.value)) return null;
  final dynamic notification = message[NotifField.notification.value];
  final String title = notification[NotifField.title.value];
  final String text = notification[NotifField.message.value];

  if (message.containsKey(NotifField.data.value)) {
    final dynamic data = message[NotifField.data.value];
    final notifType = Notif.fromString(data[NotifField.type.value]);

    switch (notifType) {
      case NotifType.message:
        print('$title, $text');
        break;
      case NotifType.unknown:
        Logger().e('Invalid notif type.');
        return null;
    }
  }
  return null;
}
