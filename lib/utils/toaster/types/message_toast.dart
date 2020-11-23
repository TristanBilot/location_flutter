import 'package:flutter/material.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/utils/toaster/toaster_widget.dart';

class MessageToaster extends Toaster {
  final BuildContext context;
  final String fromID;
  final String body;

  MessageToaster(this.context, this.fromID, this.body);

  Future show() async {
    final user = await fetchUser(fromID);
    final chatID = MessagingReposiory.getChatID(UserStore().user.id, user.id);
    final chat = await MessagingReposiory().getChatAsChat(chatID);

    _onToastTap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(chat: chat, user: user),
        ),
      );
    }

    ToasterWidget(context, body, user, _onToastTap).show();
  }
}
