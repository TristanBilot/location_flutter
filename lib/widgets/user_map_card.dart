import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location_project/controllers/messaging_controller.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
import 'package:location_project/use_cases/messaging/message_page.dart';
import 'package:location_project/use_cases/messaging/message_sender.dart';
import 'package:location_project/use_cases/messaging/messaging_repository.dart';
import 'package:location_project/widgets/user_map_card_content.dart';
import '../models/user.dart';

class UserMapCard extends StatefulWidget {
  final User user;

  UserMapCard(this.user);

  static _UserCardState of(BuildContext context) =>
      context.findAncestorStateOfType<_UserCardState>();

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserMapCard> {
  TextEditingController _messageEditingController;
  MessagingController _messagingController;

  @override
  void initState() {
    _messageEditingController = TextEditingController();
    _messagingController = MessagingController();
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
            child: UserMapCardContent(
              user: widget.user,
              onSendTap: _sendMessage,
              onSayHiTap: _sendHelloNotif,
              messageEditingController: _messageEditingController,
            ),
          ),
        ),
      ),
    );
  }
}
