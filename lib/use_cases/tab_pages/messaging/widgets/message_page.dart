import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/stores/database.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/messaging/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_message_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_sender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_tile_methods.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/messaging_text_field.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/widgets/user_card.dart';

class MessagePage extends StatefulWidget {
  final Chat chat;
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

  static const PlaceholderImageSize = 150.0;
  static const PlaceholderFontSize = 17.0;

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
    if (_messageEditingController.text.isEmpty) return;
    final message = _messageEditingController.text;
    MessageSender().send(message, widget.chat.chatID);
    setState(() => _messageEditingController.text = '');
  }

  int _getDifferenceTimeBetweenMsgAndPrevious(
    dynamic data,
    int index,
    Message msg,
  ) {
    var prevMsg;
    if (index >= data.documents.length - 1)
      prevMsg = null;
    else
      prevMsg = Message.fromFirestoreObject(
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
            final userID = UserStore().user.id;
            if (!widget.chat.isChatEngaged) {
              if (userID == widget.chat.requesterID)
                return _requestWaitingPlaceholder;
              if (userID == widget.chat.requestedID)
                return _requestInvitationPlaceholder;
            }
            if (snapshot.data.documents.length == 0)
              return _noMessagesPlaceholder;

            return ListView.builder(
                reverse: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  final msg = Message.fromFirestoreObject(
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
  Widget get _noMessagesPlaceholder => Center(
        child: Column(
          children: [
            Spacer(),
            CachedCircleUserImage(
              widget.user.pictureURL,
              size: PlaceholderImageSize,
            ),
            Padding(padding: EdgeInsets.all(30)),
            TextSF(
              'Engage a discussion with ${widget.user.firstName}!',
              fontSize: PlaceholderFontSize,
              align: TextAlign.center,
            ),
            Spacer(),
          ],
        ),
      );

  /// Placeholder displayed when the requester user has sent
  /// a request to the other participant and the requests
  /// is in a pending state.
  Widget get _requestWaitingPlaceholder => Center(
        child: Column(
          children: [
            Spacer(),
            Container(
              width: PlaceholderImageSize,
              height: PlaceholderImageSize,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/pending.png"),
                    colorFilter:
                        ColorFilter.mode(Colors.white54, BlendMode.modulate),
                    fit: BoxFit.cover),
                // color: Colors.teal[900],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: TextSF(
                'A request had been sent to ${widget.user.firstName}!',
                fontSize: PlaceholderFontSize,
                align: TextAlign.center,
              ),
            ),
            Spacer(),
          ],
        ),
      );

  /// Placeholder displayed when the requested user receives
  /// a request and should choose to accept or not.
  Widget get _requestInvitationPlaceholder => Center(
        child: Column(
          children: [
            Spacer(),
            CachedCircleUserImage(
              widget.user.pictureURL,
              size: PlaceholderImageSize,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: TextSF(
                '${widget.user.firstName} wants to talk with you.',
                fontSize: PlaceholderFontSize,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BasicButton('DENY', onPressed: _onRequestDenied),
                SizedBox(width: 20),
                BasicButton('ACCEPT', onPressed: _onRequestAccepted),
              ],
            ),
            Spacer(),
          ],
        ),
      );

  /// When a requested user denies a request, delete the chat
  /// in the firestore and in the database cache. Then, redireft to
  /// chats page.
  void _onRequestDenied() {
    MessagingReposiory().deleteChat(widget.chat.chatID);
    Database()
        .deleteUser(widget.chat.requesterID)
        .then((value) => Navigator.of(context).pop());
  }

  /// When a requested user accepts a request, update the chat to
  /// engaged = true to tell that the conversation is engaged between
  /// the two participants. Also update the last activity time to be
  /// at the top of messages and set seen to true for the moment.
  Future<void> _onRequestAccepted() async {
    await MessagingReposiory().updateChatEngaged(widget.chat.chatID, true);
    await MessagingReposiory().updateChatLastActivity(
      widget.chat.chatID,
      lastActivityTime: Message.Time,
      lastActivitySeen: true,
    );
    setState(() => widget.chat.isChatEngaged = true);
  }

  bool get _conditionToDisplayTextField => widget.chat.isChatEngaged;

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
              borderColor: Colors.white,
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
              _conditionToDisplayTextField
                  ? Container(
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
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
