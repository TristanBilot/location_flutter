import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class MessagingController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void handleMessages() {
    // _firebaseMessaging.getToken().then((token) {});
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        HapticFeedback.mediumImpact();
        sleep(const Duration(milliseconds: 150));
        HapticFeedback.lightImpact();
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }
}
