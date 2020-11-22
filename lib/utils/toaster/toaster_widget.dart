// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/repositories/user/user_mandatory_info_fetcher.dart';
import 'package:location_project/repositories/user/user_pictures_fetcher.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/utils/toaster/toaster_library.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';

enum MessageToastType {
  Discussion,
  Request,
  View,
  Message,
}

abstract class Toaster {
  Future<User> fetchUser(String id) async {
    final infos = await UserMandatoryInfoFetcher().fetch(id);
    final pictures = await UserPicturesInfoFetcher().fetch(id);
    return User.public()..build(infos: infos)..build(pictures: pictures);
  }
}

class ToasterWidget extends StatelessWidget {
  final FToast fToast = FToast();
  final BuildContext context;
  final String message;
  final User user;
  final Function onToastTap;

  ToasterWidget(
    this.context,
    this.message,
    this.user,
    this.onToastTap,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onToastTap();
        fToast.removeCustomToast();
      },
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
