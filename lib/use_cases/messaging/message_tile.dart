import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/message_tile_methods.dart';
import 'package:location_project/widgets/textSF.dart';

class MessageTile extends StatelessWidget {
  final FirestoreMessageEntry message;
  final int diffWithPrevMsgTime;

  MessageTile({
    @required this.message,
    this.diffWithPrevMsgTime,
  });

  @override
  Widget build(BuildContext context) {
    final methods = MessageTileMethods(message, diffWithPrevMsgTime);
    bool sentByMe = UserStore().user.id == message.sendBy;

    return Container(
      padding: EdgeInsets.only(
          top: 4, bottom: 4, left: sentByMe ? 0 : 24, right: sentByMe ? 24 : 0),
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          methods.getTimeText(context, sentByMe),
          Container(
            margin: sentByMe
                ? EdgeInsets.only(left: 30)
                : EdgeInsets.only(right: 30),
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: sentByMe
                    ? methods.radiusSentByMeMsg
                    : methods.radiusReceivedMsg,
                gradient: LinearGradient(
                  colors: methods.getMessageBackgroundColor(sentByMe, context),
                )),
            child: TextSF(
              message.message,
              align: TextAlign.start,
              color: methods.getMessageTextColor(sentByMe, context),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
