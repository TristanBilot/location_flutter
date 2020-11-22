// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/stores/user_store.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/use_cases/tab_pages/messaging/messaging_repository.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/utils/toaster/toaster_library.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';

class MessageToast {
  final BuildContext context;
  final String fromID;
  final String message;

  MessageToast(this.context, this.fromID, this.message);

  Future show() async {
    final id = UserStore().user.id;
    String chatID = MessagingReposiory.getChatID(id, fromID);
    final infos = await UserMandatoryInfoFetcher().fetch(fromID);
    final pictures = await UserPicturesInfoFetcher().fetch(fromID);

    final chat = await MessagingReposiory().getChatAsChat(chatID);
    final user = User.public()..build(infos: infos)..build(pictures: pictures);

    _MessageToastWidget(context, fromID, message, chat, user).show();
  }
}

class _MessageToastWidget extends StatelessWidget {
  final FToast fToast = FToast();
  final BuildContext context;
  final String fromID;
  final String message;
  final Chat chat;
  final User user;

  _MessageToastWidget(
    this.context,
    this.fromID,
    this.message,
    this.chat,
    this.user,
  ) {
    fToast.init(context);
  }

  void show() {
    fToast.showToast(
        child: this,
        toastDuration: Duration(seconds: 2),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 0,
            left: 0,
          );
        });
  }

  _onToastTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(
          chat: chat,
          user: user,
        ),
      ),
    );
    fToast.removeCustomToast();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onToastTap,
      onVerticalDragStart: (_) => fToast.removeCustomToast(),
      child: Container(
        alignment: Alignment.centerLeft,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: DarkTheme.BackgroundDarkColor.withOpacity(0.92),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 50, 8, 10),
          child: Row(
            children: [
              SizedBox(width: 20),
              CachedCircleUserImage(user.pictureURL,
                  size: 40, borderColor: Colors.transparent),
              SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextSF(user.firstName, color: Colors.white, fontSize: 15),
                  SizedBox(height: 5),
                  TextSF(message,
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
