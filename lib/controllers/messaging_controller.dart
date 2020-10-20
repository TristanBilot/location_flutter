import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class MessagingController {
  static const serverToken =
      'AAAAscoVa2Y:APA91bE5xiCyGPpPaD3ZqMmlurH9ozkELB6YOvQVXPLsp4h7U62X4PwBwRcWzdJ1dgQ-V-XTONUEY4K5JvfLiJM0WNnPHqyWCS7_I_ccQEzkOmPAQaII2mhLtnCEjIXwB56zGl58F2ct';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  MessagingController() {
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
    await _firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title',
            'mutableContent': true,
            'contentAvailable': true,
            'apnsPushType': "background",
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': await _firebaseMessaging.getToken(),
        },
      ),
    );

    // final completer = Completer<Map<String, dynamic>>();

    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     completer.complete(message);
    //   },
    // );

    // return completer.future;
  }
}
