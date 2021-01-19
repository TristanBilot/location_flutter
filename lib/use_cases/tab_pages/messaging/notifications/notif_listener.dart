import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location_project/controllers/navigation_controller.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/notifications/notif.dart';
import 'package:location_project/conf/extensions.dart';

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

  if (fromID.isEmpty) {
    Logger().w('listenToNotiofications(): invalid id or type');
    _handleUnknown(context);
    return null;
  }

  switch (notifType) {
    case NotifType.Message:
      await _handleNewMessage(fromID, context);
      break;
    case NotifType.Match:
      await _handleNewMatch(fromID, context);
      break;
    case NotifType.View:
      _handleNewView(context);
      break;
    case NotifType.Like:
      _handleNewLike(context);
      break;
    case NotifType.Unknown:
      Logger().w(
          'listenToNotiofications(): received an "Unknown" push notification.');
      _handleUnknown(context);
      break;
  }
}

void _logNotif(Map<String, dynamic> message, String handler) {
  final from = message[NotifField.fromID.value] ?? '';
  Logger().i('New notification $handler from $from');
}

Future _handleNewMessage(String fromID, BuildContext context) async {
  final chatID = MessagingReposiory.getChatID(UserStore().user.id, fromID);
  final user = await UserRepository().fetchUser(fromID, withInfos: true);
  final chat = await MessagingReposiory().getChatAsChat(chatID);

  NavigationController().navigateToMessagePage(user, chat, context);
}

Future _handleNewMatch(String fromID, BuildContext context) async {
  _handleNewMessage(fromID, context);
}

Future _handleNewView(BuildContext context) async {
  NavigationController().navigateToPremiumViewPage();
}

Future _handleNewLike(BuildContext context) async {
  NavigationController().navigateToPremiumLikePage();
}

Future _handleUnknown(BuildContext context) async {
  NavigationController().navigateToMessagingPage();
}
