import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  MessagingController() {
    firebaseCloudMessaging_Listeners();
  }

  void firebaseCloudMessaging_Listeners() {
    _firebaseMessaging.getToken().then((token) {
      print(token);
    });

    _firebaseMessaging.configure(
        // onMessage: (Map<String, dynamic> message) async {
        //   print('on message $message');
        // },
        // onResume: (Map<String, dynamic> message) async {
        //   print('on resume $message');
        // },
        // onLaunch: (Map<String, dynamic> message) async {
        //   print('on launch $message');
        // },
        );
  }
}
