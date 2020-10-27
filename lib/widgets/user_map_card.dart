import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location_project/controllers/messaging_controller.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/use_cases/messaging/firestore_chat_entry.dart';
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
  MessagingController _messagingController;

  @override
  void initState() {
    super.initState();
    _messagingController = MessagingController();
  }

  void sendMessage(String message) {
    // _messagingController...
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
      lastActivitySeen: true,
    );
    MessagingReposiory().newChat(entry.chatID, entry);
    await MessagingController().sendAndRetrieveMessage();
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
              onTextSubmitted: sendMessage,
              onSayHiTap: _sendHelloNotif,
            ),
          ),
        ),
      ),
    );
  }
}
