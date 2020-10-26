import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/cahed_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/messaging/message_tile.dart';
import 'package:location_project/use_cases/messaging/message_tile_methods.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/use_cases/messaging/messaging_text_field.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_card.dart';

class MessagePage extends StatefulWidget {
  final FirestoreChatEntry chat;
  final User user;

  MessagePage({
    @required this.chat,
    @required this.user,
  });

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  Stream<QuerySnapshot> _messages;
  TextEditingController _messageEditingController;
  bool _isMessagesEmpty;

  @override
  void initState() {
    _fetchMessages();
    _messageEditingController = TextEditingController();
    super.initState();
  }

  void _fetchMessages() {
    MessagingReposiory()
        .getMessages(widget.chat.chatID)
        .then((messages) => setState(() => _messages = messages));
  }

  void _sendMessage() {
    if (_messageEditingController.text.isNotEmpty) {
      final message = _messageEditingController.text;
      final sendBy = UserStore().user.id;
      final time = FirestoreMessageEntry.Time;

      final entry = FirestoreMessageEntry(message, sendBy, time);
      MessagingReposiory().newMessage(widget.chat.chatID, entry);
      MessagingReposiory().updateChatLastActivity(
        widget.chat.chatID,
        lastActivityTime: time,
        lastActivitySeen: false,
      );
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

  /// Return the list of messages.
  Widget get _messagesOrPlaceholderWidget => StreamBuilder(
        stream: _messages,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.documents.length == 0)
              return _requesterPlaceholder;

            return ListView.builder(
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
                });
          }
          return Container();
        },
      );

  /// Placeholder displayed when the user has requested the chat
  /// and the chat has been accepted by the other participant.
  /// It is only displayed when there is 0 messages yet.
  Widget get _requesterPlaceholder => Column(
        children: [
          Spacer(),
          CachedCircleUserImage(
            widget.user.pictureURL,
            size: 160,
          ),
          Padding(padding: EdgeInsets.only(top: 30)),
          TextSF('Engage a discussion with ${widget.user.firstName}!'),
          Spacer(),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(85.0),
        child: AppBar(
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: TextSF(
                widget.user.firstName,
                color: Colors.white,
              ),
            ),
          ),
          elevation: 6,
          title: CachedCircleUserImageWithActiveStatus(
              pictureURL: widget.user.pictureURL,
              isActive: widget.user.settings.connected,
              size: 55,
              onTapped: () => UserCard(context, widget.user).show()),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
        },
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: _messagesOrPlaceholderWidget,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Container(
                  height: 80,
                  padding: EdgeInsets.fromLTRB(10, 15, 10, 30),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: MessagingTextField(
                    onPressed: _sendMessage,
                    onChanged: (text) => setState(() => {}),
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
