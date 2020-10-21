import 'package:flutter/material.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/message_tile.dart';
import 'package:location_project/use_cases/messaging/message_tile_methods.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/use_cases/messaging/messaging_text_field.dart';

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

  Future<void> _sendMessage() {
    if (_messageEditingController.text.isNotEmpty) {
      final message = _messageEditingController.text;
      final sendBy = UserStore().user.id;
      final time = FirestoreMessageEntry.Time;

      final entry = FirestoreMessageEntry(message, sendBy, time);
      MessagingReposiory().newMessage(widget.chatID, entry);
      setState(() => _messageEditingController.text = '');
    }
  }

  int _getDifferenceTimeBetweenMsgAndPrevious(
    dynamic data,
    int index,
    FirestoreMessageEntry msg,
  ) {
    var prevMsg;
    if (index >= data.documents.length - 1)
      prevMsg = null;
    else
      prevMsg = FirestoreMessageEntry.fromFirestoreObject(
        // +1 and not -1 because the list in descending order.
        data.documents[index + 1].data(),
      );
    // when prevMsg == null, we say that it is the first msg
    // and by default, we want to print the time.
    int diff = prevMsg == null
        ? MessageTileMethods.ValueForFirstMessage
        : msg.time - prevMsg.time;
    return diff;
  }

  Widget get _messagesList => StreamBuilder(
        stream: _messages,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    final msg = FirestoreMessageEntry.fromFirestoreObject(
                        snapshot.data.documents[index].data());
                    final diff = _getDifferenceTimeBetweenMsgAndPrevious(
                        snapshot.data, index, msg);
                    return MessageTile(
                      message: msg,
                      diffWithPrevMsgTime: diff,
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
          child: Column(
            children: [
              Expanded(
                child: _messagesList,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  height: 80,
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 30),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: MessagingTextField(
                    onPressed: _sendMessage,
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
