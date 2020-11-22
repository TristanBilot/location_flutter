import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/utils/toaster/toaster_widget.dart';

class ChatToaster extends Toaster {
  final BuildContext context;
  final Chat chat;
  final String fromID;

  ChatToaster(this.context, this.chat, this.fromID);

  Future show() async {
    final user = await fetchUser(fromID);

    _onToastTap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MessagePage(chat: chat, user: user),
        ),
      );
    }

    final body = 'New conversation with ${user.firstName}!';
    ToasterWidget(context, body, user, _onToastTap).show();
  }
}
