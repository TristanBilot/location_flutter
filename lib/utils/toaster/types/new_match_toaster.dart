import 'package:flutter/material.dart';
import 'package:location_project/controllers/navigation_controller.dart';
import 'package:location_project/repositories/user_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/utils/toaster/toaster_widget.dart';

class NewMatchToaster extends Toaster {
  final BuildContext context;
  final Chat chat;
  final String fromID;

  NewMatchToaster(this.context, this.chat, this.fromID);

  Future show() async {
    final user = await UserRepository().fetchUser(fromID, withInfos: true);

    _onToastTap() {
      NavigationController().navigateToMessagePage(user, chat, context);
    }

    final body = 'New match with ${user.firstName}!';
    ToasterWidget(context, body, user, _onToastTap).show();
  }
}
