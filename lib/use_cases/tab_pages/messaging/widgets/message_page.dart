import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/storage/databases/user_database.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messages/cubit/messages_cubit.dart';
import 'package:location_project/use_cases/tab_pages/widgets/cached_circle_user_image_with_active_status.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/message.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_sender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_tile.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_tile_methods.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessagesCubit(),
        child: MessagePageContent(chat: widget.chat, user: widget.user));
  }
}

class MessagePageContent extends StatefulWidget {
  final Chat chat;
  final User user;

  MessagePageContent({
    @required this.chat,
    @required this.user,
  });

  @override
  _MessagePageContentState createState() => _MessagePageContentState();
}

class _MessagePageContentState extends State<MessagePageContent> {
  TextEditingController _messageEditingController;

  static const PlaceholderImageSize = 150.0;
  static const PlaceholderFontSize = 17.0;

  @override
  void initState() {
    _init();
    _fetch();
    _messageEditingController = TextEditingController();
    super.initState();
  }

  void _init() {
    MemoryStore()
        .setDisplayToastValues(true, true, true, false, widget.user.id);
  }

  void _fetch() {
    final chatID = widget.chat.chatID;
    context.read<MessagesCubit>().fetchMessages(chatID);
  }

  void _updateLastActivity() {
    MessagingReposiory().updateChatLastActivity(
      widget.chat,
      lastActivitySeen: true,
      lastActivitySeenParticipant: Participant.Me,
    );
  }

  void _sendMessage() {
    final content = _messageEditingController.text.trim();
    if (content.isEmpty) return;
    MessageSender().send(content, widget.chat);
    setState(() => _messageEditingController.text = '');

    // Handle the first message sent, to engage the chat
    if (!widget.chat.isChatEngaged) {
      _engageChat();
    }
  }

  Future<void> _engageChat() async {
    MemoryStore()
        .setDisplayToastValues(false, true, true, false, widget.user.id);
    await MessagingReposiory().updateChatEngaged(widget.chat.chatID, true);
    // change requester status
    await MessagingReposiory().updateChatLastActivity(
      widget.chat,
      lastActivityTime: Message.Time,
      lastActivitySeen: false,
      lastActivitySeenParticipant: Participant.Me,
    );
    // change requested status
    await MessagingReposiory().updateChatLastActivity(
      widget.chat,
      lastActivityTime: Message.Time,
      lastActivitySeen: false,
      lastActivitySeenParticipant: Participant.Other,
    );
  }

  void _handleLastMsgView(bool isLastMsg, Message msg) {
    if (!isLastMsg) return;
    if (msg.sentBy != UserStore().user.id)
      MessagingReposiory().updateLastMessageView(widget.chat, true);
  }

  int _getDifferenceTimeBetweenMsgAndPrevious(
    List<Message> messages,
    int index,
    Message msg,
  ) {
    var prevMsg;
    if (index >= messages.length - 1)
      prevMsg = null;
    else
      prevMsg = messages[index + 1];
    // +1 and not -1 because the list in descending order.
    // when prevMsg == null, we say that it is the first msg
    // and by default, we want to print the time.
    int diff = prevMsg == null
        ? MessageTileMethods.ValueForFirstMessage
        : msg.time - prevMsg.time;
    return diff;
  }

  /// Return the list of messages.
  Widget get _messagesOrPlaceholderWidget =>
      BlocBuilder<MessagesCubit, MessagesState>(builder: (context, state) {
        if (state is MessagesFetchedState) {
          final messages = state.messages;
          if (messages.isEmpty) return _noMessagesPlaceholder;
          _updateLastActivity();

          return ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final diff = _getDifferenceTimeBetweenMsgAndPrevious(
                    messages, index, msg);
                final isLastMessage = index == 0;
                _handleLastMsgView(isLastMessage, msg);
                return MessageTile(
                  message: msg,
                  chat: widget.chat,
                  diffWithPrevMsgTime: diff,
                  isLastMessage: isLastMessage,
                );
              });
        }
        return Container();
      });

  /// Placeholder displayed when the user has requested the chat
  /// and the chat has been accepted by the other participant.
  /// It is only displayed when there is 0 messages yet.
  Widget get _noMessagesPlaceholder => Center(
        child: Column(
          children: [
            Spacer(),
            CachedCircleUserImage(
              widget.user.mainPictureURL,
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
  // Widget get _requestWaitingPlaceholder => Center(
  //       child: Column(
  //         children: [
  //           Spacer(),
  //           Container(
  //             width: PlaceholderImageSize,
  //             height: PlaceholderImageSize,
  //             decoration: BoxDecoration(
  //               image: DecorationImage(
  //                   image: AssetImage("assets/pending.png"),
  //                   colorFilter:
  //                       ColorFilter.mode(Colors.white54, BlendMode.modulate),
  //                   fit: BoxFit.cover),
  //               // color: Colors.teal[900],
  //             ),
  //           ),
  //           Padding(
  //             padding: EdgeInsets.all(30),
  //             child: TextSF(
  //               'A request had been sent to ${widget.user.firstName}!',
  //               fontSize: PlaceholderFontSize,
  //               align: TextAlign.center,
  //             ),
  //           ),
  //           Spacer(),
  //         ],
  //       ),
  //     );

  /// Placeholder displayed when the requested user receives
  /// a request and should choose to accept or not.
  // Widget get _requestInvitationPlaceholder => Center(
  //       child: Column(
  //         children: [
  //           Spacer(),
  //           CachedCircleUserImage(
  //             widget.user.pictureURL,
  //             size: PlaceholderImageSize,
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.only(top: 20, bottom: 40),
  //             child: TextSF(
  //               '${widget.user.firstName} wants to talk with you.',
  //               fontSize: PlaceholderFontSize,
  //             ),
  //           ),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               BasicButton('DENY', onPressed: _onRequestDenied),
  //               SizedBox(width: 20),
  //               BasicButton('ACCEPT', onPressed: _onRequestAccepted),
  //             ],
  //           ),
  //           Spacer(),
  //         ],
  //       ),
  // //     );

  // /// When a requested user denies a request, delete the chat
  // /// in the firestore and in the database cache. Then, redireft to
  // /// chats page.
  // void _onRequestDenied() {
  //   MessagingReposiory().deleteChat(widget.chat.chatID);
  //   UserDatabase()
  //       .deleteUser(widget.chat.requesterID)
  //       .then((value) => Navigator.of(context).pop());
  // }

  // /// When a requested user accepts a request, update the chat to
  // /// engaged = true to tell that the conversation is engaged between
  // /// the two participants. Also update the last activity time to be
  // /// at the top of messages and set seen to true for the moment.
  // Future<void> _onRequestAccepted() async {
  //   MemoryStore()
  //       .setDisplayToastValues(false, true, true, false, widget.user.id);
  //   await MessagingReposiory().updateChatEngaged(widget.chat.chatID, true);
  //   await MessagingReposiory().updateChatLastActivity(
  //     widget.chat,
  //     lastActivityTime: Message.Time,
  //     lastActivitySeen: false,
  //     lastActivitySeenParticipant: Participant.Me,
  //   );
  //   await MessagingReposiory().updateChatLastActivity(
  //     widget.chat,
  //     lastActivityTime: Message.Time,
  //     lastActivitySeen: false,
  //     lastActivitySeenParticipant: Participant.Other,
  //   );
  //   setState(() => widget.chat.isChatEngaged = true);
  // }

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
              pictureURL: widget.user.mainPictureURL,
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
