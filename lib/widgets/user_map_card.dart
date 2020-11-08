import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:location_project/controllers/messaging_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location_project/helpers/logger.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/use_cases/tab_pages/messaging/message_sender.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/widgets/user_card.dart';
import 'package:location_project/widgets/user_map_card_content.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../models/user.dart';

class UserMapCard extends StatefulWidget implements Showable {
  final BuildContext context;
  final User user;
  final Future<void> Function() fetchAreaFunction;

  UserMapCard(
    this.context,
    this.user,
    this.fetchAreaFunction,
  );

  void show() {
    showGeneralDialog(
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: this,
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 150),
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  static _UserCardState of(BuildContext context) =>
      context.findAncestorStateOfType<_UserCardState>();

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserMapCard> {
  TextEditingController _messageEditingController;
  MessagingController _messagingController;
  RoundedLoadingButtonController _blockButtonController;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _messagingController = MessagingController();
    _blockButtonController = RoundedLoadingButtonController();
    super.initState();
  }

  /// Action when a user send directly a message to another person.
  /// The value of isEngaged is set at true so no need to accept.
  /// Creates a new chat and then insert a first message.
  Future<void> _sendMessage() async {
    if (_messageEditingController.text.isEmpty) return;
    // Create a new chat.
    User requester = UserStore().user;
    User requested = widget.user;
    final chatEntry = FirestoreChatEntry.newChatEntry(
      requester.id,
      requested.id,
      requester.firstName,
      requested.firstName,
      true,
      true,
    );
    await MessagingReposiory().newChat(chatEntry.chatID, chatEntry);
    // Insert the first message.
    final message = _messageEditingController.text;
    MessageSender().send(message, chatEntry.chatID);
    setState(() => _messageEditingController.text = '');

    final data = (await MessagingReposiory().getChat(chatEntry.chatID)).data();
    final chat = FirestoreChatEntry.fromFirestoreObject(data);
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: chat,
          user: widget.user,
        ),
      ),
    );
  }

  /// Action when a user requests to talk with another person.
  /// A chat is pending state is created and a notification is sent
  /// to the requested.
  Future<void> _sendHelloNotif() async {
    User requester = UserStore().user;
    User requested = widget.user;
    final entry = FirestoreChatEntry.newChatEntry(
      requester.id,
      requested.id,
      requester.firstName,
      requested.firstName,
      true,
      false,
    );
    MessagingReposiory().newChat(entry.chatID, entry);
    // await MessagingController().sendAndRetrieveMessage();
  }

  /// Action when the user blocks another user on the map.
  Future<void> _blockUser(context) async {
    User blockedUser = widget.user;
    UserStore().addBlockedUser(blockedUser.id).then((_) async {
      _blockButtonController.success();
      HapticFeedback.mediumImpact();
      await widget.fetchAreaFunction();
      await Future.delayed(Duration(milliseconds: 200));
      Navigator.of(context).pop();
    });
  }

  Future<List<DocumentSnapshot>> _fetchChatInfo(String otherUserID) async {
    Stopwatch stopwatch = new Stopwatch()..start();
    String id = UserStore().user.id;
    String chatID1 = MessagingReposiory.getChatID(id, otherUserID);
    String chatID2 = MessagingReposiory.getChatID(otherUserID, id);
    final chat1 = MessagingReposiory().getChat(chatID1);
    final chat2 = MessagingReposiory().getChat(chatID2);
    await Future.wait([chat1, chat2]);
    int chatInfoFetchingTime = stopwatch.elapsed.inMilliseconds;
    Logger().v('chat info fetched in ${chatInfoFetchingTime}ms');
    return Future.wait([chat1, chat2]);
  }

  @override
  Widget build(BuildContext context) {
    // To dismiss keyboard.
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 5),
          child: Container(
            height: 400,
            child: FutureBuilder(
              future: _fetchChatInfo(widget.user.id),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final chatIfExists =
                      snapshot.data[0].data() ?? snapshot.data[1].data();
                  final chatEntryIfExists = chatIfExists == null
                      ? null
                      : FirestoreChatEntry.fromFirestoreObject(chatIfExists);
                  return UserMapCardContent(
                    user: widget.user,
                    onSendTap: _sendMessage,
                    onSayHiTap: _sendHelloNotif,
                    onBlockTap: () => _blockUser(context),
                    messageEditingController: _messageEditingController,
                    blockButtonController: _blockButtonController,
                    chatEntryIfExists: chatEntryIfExists,
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
