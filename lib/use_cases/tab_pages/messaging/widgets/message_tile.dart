import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_tile_methods.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/reaction.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_tile_menu.dart';
import 'package:location_project/widgets/textSF.dart';

class MessageTile extends StatelessWidget {
  final Message message;
  final Chat chat;
  final int diffWithPrevMsgTime;
  final bool isLastMessage;

  MessageTile({
    @required this.message,
    @required this.chat,
    @required this.diffWithPrevMsgTime,
    @required this.isLastMessage,
  });

  List<Widget> get _messagesSeenText {
    if (!isLastMessage || message.sendBy != UserStore().user.id) return [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 3.0),
        child: TextSF(message.isViewed ? 'Seen' : 'Sent',
            fontWeight: FontWeight.w400, fontSize: 12),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final methods = MessageTileMethods(message, diffWithPrevMsgTime);
    bool sentByMe = UserStore().user.id == message.sendBy;

    return MessageTileMenu(
      message: message,
      chat: chat,
      child: Container(
          padding: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: sentByMe ? 0 : 24,
              right: sentByMe ? 24 : 0),
          alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              methods.getTimeText(context, sentByMe),
              Stack(
                alignment: message.sendBy == UserStore().user.id
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                children: [
                  Container(
                    // offset for reaction emoji outside of tile.
                    margin: sentByMe
                        ? EdgeInsets.only(left: 23)
                        : EdgeInsets.only(right: 23),
                    padding: EdgeInsets.only(
                        top: 10, bottom: 10, left: 20, right: 20),
                    decoration: BoxDecoration(
                        borderRadius: sentByMe
                            ? methods.radiusSentByMeMsg
                            : methods.radiusReceivedMsg,
                        gradient: LinearGradient(
                          colors: methods.getMessageBackgroundColor(
                              sentByMe, context),
                        )),
                    child: TextSF(
                      message.message,
                      align: TextAlign.start,
                      color: methods.getMessageTextColor(sentByMe, context),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSF(message.reaction.emoji, fontSize: 18),
                ],
              ),
            ]..addAll(_messagesSeenText),
          )),
    );
  }
}
