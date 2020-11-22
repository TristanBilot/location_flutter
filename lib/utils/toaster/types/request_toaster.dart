import 'package:flutter/material.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_chats_requests_page.dart';
import 'package:location_project/use_cases/tab_pages/tab_page_type.dart';
import 'package:location_project/utils/toaster/toaster_widget.dart';

class RequestToaster extends Toaster {
  final BuildContext context;
  final Chat chat;
  final String fromID;

  RequestToaster(this.context, this.chat, this.fromID);

  Future show() async {
    final user = await fetchUser(fromID);

    _onToastTap() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabPageChatsRequestsPage(TabPageType.Requests),
        ),
      );
    }

    final body = '${user.firstName} has sent you a request';
    ToasterWidget(context, body, user, _onToastTap).show();
  }
}
