import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/utils/toaster/types/message_toast.dart';

final _firebaseMessaging = FirebaseMessaging();

void listenToNotifications(BuildContext context) {
  _firebaseMessaging.configure(
    onMessage: (message) => _handle(message, context),
    // onBackgroundMessage: _handle,
    onLaunch: (message) async {
      print("onLaunch: $message");
    },
    onResume: (message) async {
      print("onResume: $message");
    },
  );
}

Future<dynamic> _handle(Map<String, dynamic> message, BuildContext context) {
  return null;
  if (!message.containsKey(NotifField.notification.value)) {
    Logger().w('Notif handled but invalid format.');
    return null;
  }
  Logger().i('Message received');
  // Do not display toast on some pages.
  if (!MemoryStore().shouldDisplayMessageToast) return null;
  final dynamic notification = message[NotifField.notification.value];

  final String body = notification[NotifField.body.value];
  final String fromID = notification[NotifField.fromID.value];
  final NotifType notifType =
      Notif.fromString(notification[NotifField.type.value]);
  if (MemoryStore().getUserChattingWithNow == fromID ||
      fromID == null ||
      body == null) return null;

  switch (notifType) {
    case NotifType.message:
      MessageToaster(context, fromID, body).show();
      break;
    case NotifType.unknown:
      Logger().e('Invalid notif type.');
      return null;
  }
  return null;
}
