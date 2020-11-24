// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
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

abstract class Toaster {}

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
        toastDuration: Duration(milliseconds: 2500),
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
          padding: const EdgeInsets.fromLTRB(25, 50, 25, 10),
          child: Row(
            children: [
              // SizedBox(width: 20),
              CachedCircleUserImage(user.pictureURL,
                  size: 40, borderColor: Colors.transparent),
              SizedBox(width: 20),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSF(user.firstName, color: Colors.white, fontSize: 15),
                    SizedBox(height: 5),
                    TextSF(message,
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
