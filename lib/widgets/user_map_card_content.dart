import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/helpers/string_formatter.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/say_hello_button.dart';
import 'package:location_project/widgets/scrollable_textview.dart';
import 'package:location_project/widgets/textSF.dart';
import '../models/user.dart';

class UserMapCardContent extends StatefulWidget {
  final User user;
  final Function onSendTap;
  final Function onSayHiTap;
  final TextEditingController messageEditingController;

  UserMapCardContent({
    @required this.user,
    @required this.onSendTap,
    @required this.onSayHiTap,
    @required this.messageEditingController,
  });

  @override
  _UserMapCardContentState createState() => _UserMapCardContentState();
}

class _UserMapCardContentState extends State<UserMapCardContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 400,
      padding: EdgeInsets.all(20),
      child: Material(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: CachedCircleUserImage(
                      widget.user.pictureURL,
                      size: 130,
                    ),
                  ),
                  // Expanded(
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextSF(
                      StringFormatter().getNameAgeLabel(
                          widget.user.firstName, widget.user.age),
                      fontSize: TextSF.FontSize + 4,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: TextSF(
                      widget.user.distance == 0
                          ? ''
                          : '${widget.user.distance} meters',
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: ScrollableTextView(
                      controller: widget.messageEditingController,
                      withSendButton: true,
                      onSendPressed: widget.onSendTap,
                    ),
                  ),
                  Spacer(),
                  SayHelloButton(
                    onPressed: widget.onSayHiTap,
                    userName: widget.user.firstName,
                  ),

                  Spacer(),
                ],
              ),
            ),
          )),
    );
  }
}
