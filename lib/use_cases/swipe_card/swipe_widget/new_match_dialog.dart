import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/tab_pages/messaging/models/chat.dart';
import 'package:location_project/use_cases/tab_pages/messaging/widgets/message_page.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_gradient_border_button.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:location_project/storage/distant/user_store.dart';

class NewMatchDialog extends StatefulWidget {
  final User user;
  final Chat chat;

  const NewMatchDialog(this.user, this.chat);

  @override
  _NewMatchDialogState createState() => _NewMatchDialogState();
}

class _NewMatchDialogState extends State<NewMatchDialog> {
  final _horizontalPadding = 15.0;
  final _littlePictureSize = 100.0;
  final _bigPictureSize = 150.0;
  final _bigImageOffset = 50.0;

  @override
  Widget build(BuildContext context) {
    final _backgroundColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? DarkTheme.BackgroundDarkColor
            : Theme.of(context).backgroundColor;
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: _horizontalPadding),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: _backgroundColor,
      content: Builder(
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 1.3,
          child: Center(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: _bigImageOffset + _bigPictureSize,
                      width: _bigImageOffset + _bigPictureSize,
                      child: Stack(
                        children: [
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: CachedCircleUserImage(
                              UserStore().user.pictureURL,
                              size: _littlePictureSize,
                              borderColor: Colors.transparent,
                            ),
                          ),
                          Positioned(
                            bottom: _bigImageOffset,
                            left: _bigImageOffset,
                            child: CachedCircleUserImage(
                              widget.user.pictureURL,
                              size: _bigPictureSize,
                              borderColor: _backgroundColor,
                              borderWidth: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    TextSF('It\'s a match!',
                        fontSize: 25, fontWeight: FontWeight.w800),
                    SizedBox(height: 10),
                    TextSF(
                      'You can now chat with ${widget.user.firstName}',
                      fontSize: 14,
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white
                          : Colors.black38,
                      align: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    BasicButton(
                      'SEND MESSAGE',
                      fontsSize: 16,
                      width: MediaQuery.of(context).size.width * 0.7,
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MessagePage(
                                    chat: widget.chat, user: widget.user)));
                      },
                    ),
                    SizedBox(height: 10),
                    BasicGradientBorderButton(
                      'KEEP SWIPPING',
                      fontsSize: 16,
                      textColor: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Colors.white
                          : PrimaryColor,
                      width: MediaQuery.of(context).size.width * 0.7,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
