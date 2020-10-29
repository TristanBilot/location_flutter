import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/use_cases/messaging/chat_tile.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/start_path/basic_alert.dart';
import 'package:location_project/use_cases/start_path/basic_alert_button.dart';

class ChatTileSlideActionsDelegate {
  List<Widget> discussionActions(ChatTile widget, User user, context) => [
        IconSlideAction(
          caption: 'Share profile',
          color: Colors.indigo,
          icon: Icons.share,
          onTap: _onSharePress,
        ),
        IconSlideAction(
          caption: 'Unmatch',
          color: Colors.red[500],
          icon: Icons.close,
          onTap: () => _onUnmatchPress(widget, user.firstName, context),
        ),
      ];

  List<Widget> requestsActions(ChatTile widget, User user, context) => [
        IconSlideAction(
          caption: 'Remove',
          color: Colors.red[500],
          icon: Icons.close,
          onTap: () => _onUnmatchPress(widget, user.firstName, context),
        ),
      ];

  List<Widget> viewsActions(ChatTile widget, User user, context) => [
        IconSlideAction(
          caption: 'Unmatch',
          color: Colors.red[500],
          icon: Icons.close,
          onTap: () => _onUnmatchPress(widget, user.firstName, context),
        ),
      ];

  void _onSharePress() {}

  void _onUnmatchPress(ChatTile widget, String userName, context) {
    Color cancelButtonColor() {
      bool isDark =
          MediaQuery.of(context).platformBrightness == Brightness.dark;
      return isDark
          ? Color.fromRGBO(60, 60, 60, 1)
          : Color.fromRGBO(140, 140, 140, 1);
    }

    void onCancelPress() => Navigator.of(context).pop();

    void onUnmatchPress() {
      MessagingReposiory().deleteMessages(widget.chat.chatID);
      MessagingReposiory().deleteChat(widget.chat.chatID);
      Database()
          .deleteUser(widget.chat.requesterID)
          .then((value) => Navigator.of(context).pop());
    }

    showDialog(
      context: context,
      builder: (context) => BasicAlert(
        'Are you sure to unmatch $userName?',
        titleFontSize: 18,
        titleAlignment: TextAlign.center,
        contentPadding: EdgeInsets.only(bottom: 10),
        actions: [
          BasicAlertButton('CANCEL', onCancelPress, color: cancelButtonColor()),
          BasicAlertButton('UNMATCH', onUnmatchPress, color: Colors.red[500]),
        ],
      ),
    );
  }
}
