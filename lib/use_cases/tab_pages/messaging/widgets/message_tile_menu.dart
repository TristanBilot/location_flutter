import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/focused_menu_holder.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/focused_menu_item.dart';

class MessageTileMenu extends StatefulWidget {
  final Widget child;
  final Chat chat;
  final Message message;

  MessageTileMenu({
    @required this.message,
    @required this.chat,
    @required this.child,
  });

  @override
  _MessageTileMenuState createState() => _MessageTileMenuState();
}

class _MessageTileMenuState extends State<MessageTileMenu> {
  /// Warning: by default FocusedMenuHolder events do a pop().

  _onCopyPress() => FlutterClipboard.copy(widget.message.message);

  _onDeleteReactionPress(BuildContext context) => MessagingReposiory()
      .updateMessageReaction(widget.chat, widget.message, Reaction.NoReaction);

  _onDeletePress() =>
      MessagingReposiory().deleteMessage(widget.chat.chatID, widget.message);

  @override
  Widget build(BuildContext context) {
    bool isMsgSentByMe = widget.message.sentBy == UserStore().user.id;
    return FocusedMenuHolder(
      onPressed: () => {},
      menuItems: [
        if (!isMsgSentByMe)
          FocusedMenuItem(
              title: Text("React"),
              trailingIcon: Row(children: [
                Reaction.Heart.emojiWidget(
                    widget.chat, widget.message, context),
                Reaction.Laugh.emojiWidget(
                    widget.chat, widget.message, context),
                Reaction.Sad.emojiWidget(widget.chat, widget.message, context),
                Reaction.Yes.emojiWidget(widget.chat, widget.message, context),
              ]), // Icon(Icons.favorite_border)]),
              onPressed: () {}),
        if (!isMsgSentByMe && widget.message.reaction != Reaction.NoReaction)
          FocusedMenuItem(
              title: Text("Delete reaction"),
              trailingIcon: Icon(Icons.close),
              onPressed: () => _onDeleteReactionPress(context)),
        FocusedMenuItem(
            title: Text("Copy"),
            trailingIcon: Icon(Icons.content_copy),
            onPressed: _onCopyPress),
        if (isMsgSentByMe)
          FocusedMenuItem(
              title: Text("Delete", style: TextStyle(color: Colors.redAccent)),
              trailingIcon: Icon(Icons.delete_forever, color: Colors.redAccent),
              onPressed: _onDeletePress)
      ],
      child: widget.child,
    );
  }
}
