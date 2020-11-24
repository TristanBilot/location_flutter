import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_chats_requests_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/utils/toaster/types/message_toast.dart';

final _firebaseMessaging = FirebaseMessaging();

void listenToNotifications(BuildContext context) {
  _firebaseMessaging.configure(
    // /!\ onBackgroundMessage not implemented.
    onMessage: (message) async {
      _logNotif(message, 'onMessage');
    },

    /// /!\ these two handlers can only access `data` element in the json.
    onLaunch: (message) async {
      _logNotif(message, 'onLaunch');
      return _onPushNotificationTap(message, context);
    },
    onResume: (message) async {
      _logNotif(message, 'onResume');
      return _onPushNotificationTap(message, context);
    },
  );
}

void _logNotif(Map<String, dynamic> message, String handler) {
  final from = message[NotifField.fromID.value] ?? '';
  Logger().i('New notification $handler from $from');
}

Future<dynamic> _onPushNotificationTap(
  Map<String, dynamic> message,
  BuildContext context,
) async {
  print('RECEIVED $message');
  final fromID = (message[NotifField.fromID.value] ?? '') as String;
  if (fromID.isEmpty) {
    Logger().w('listenToNotiofications(): invalid id');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                TabPageChatsRequestsPage(TabPageType.Discussions)));
    return null;
  }
  final chatID = MessagingReposiory.getChatID(UserStore().user.id, fromID);
  final user = await UserRepository()
      .fetchUser(fromID, withInfos: true, withPictures: true);
  final chat = await MessagingReposiory().getChatAsChat(chatID);
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MessagePage(chat: chat, user: user)));
}

Future<dynamic> _handle(Map<String, dynamic> message, BuildContext context) {
  print("onMessage: $message");
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
    case NotifType.Messages:
      MessageToaster(context, fromID, body).show();
      break;
    case NotifType.Unknown:
      Logger().e('Invalid notif type.');
      return null;
  }
  return null;
}
