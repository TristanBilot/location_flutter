import 'package:flutter/material.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/use_cases/messaging/messaging_text_field.dart';
import '../../stores/extensions.dart';

class MessagePage extends StatefulWidget {
  final String chatID;

  MessagePage({
    @required this.chatID,
  });

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Stream<QuerySnapshot> _messages;
  TextEditingController _messageEditingController;

  @override
  void initState() {
    MessagingReposiory()
        .getMessages(widget.chatID)
        .then((messages) => setState(() => _messages = messages));
    _messageEditingController = TextEditingController();
    super.initState();
  }

  Widget get _messagesList => StreamBuilder(
        stream: _messages,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return MessageTile(
                      message: snapshot.data.documents[index]
                          .data()[MessageField.Message.value],
                      sendByMe: UserStore().user.id ==
                          snapshot.data.documents[index]
                              .data()[MessageField.SendBy.value],
                    );
                  })
              : Container();
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: Container(
          child: Stack(
            children: [
              _messagesList,
              Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  // padding: EdgeInsets.only(bottom: 30),
                  // height: 80,
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 30),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: MessagingTextField(
                    controller: _messageEditingController,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({@required this.message, @required this.sendByMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: 8, left: sendByMe ? 0 : 24, right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            sendByMe ? EdgeInsets.only(left: 30) : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe
                  ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                  : [const Color(0x1AFFFFFF), const Color(0x1AFFFFFF)],
            )),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'OverpassRegular',
                fontWeight: FontWeight.w300)),
      ),
    );
  }
}
