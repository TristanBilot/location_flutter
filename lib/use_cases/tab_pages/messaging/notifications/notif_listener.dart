import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/conf/extensions.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';

final _firebaseMessaging = FirebaseMessaging();

void listenToNotifications(BuildContext context) {
  _firebaseMessaging.configure(
    // /!\ onBackgroundMessage not implemented.
    onMessage: (message) async {
      _logNotif(message, 'onMessage');
    },
    // /!\ these two handlers can only access `data` element in the json.
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

Future<dynamic> _onPushNotificationTap(
  Map<String, dynamic> message,
  BuildContext context,
) async {
  final fromID = (message[NotifField.fromID.value] ?? '') as String;
  final notifType = Notif.fromString(message[NotifField.type.value]);
  if (fromID.isEmpty || notifType == NotifType.Unknown) {
    Logger().w('listenToNotiofications(): invalid id or type');

    /// TODO: change route
    ///
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) =>
    //             TabPageChatsRequestsPage(TabPageType.Discussions)));
    return null;
  }
  if (notifType == NotifType.Views) {
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => TabPageViewsPage()));
    return;
  }
  final chatID = MessagingReposiory.getChatID(UserStore().user.id, fromID);
  final user = await UserRepository().fetchUser(fromID, withInfos: true);
  final chat = await MessagingReposiory().getChatAsChat(chatID);
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MessagePage(chat: chat, user: user)));
}

void _logNotif(Map<String, dynamic> message, String handler) {
  final from = message[NotifField.fromID.value] ?? '';
  Logger().i('New notification $handler from $from');
}
