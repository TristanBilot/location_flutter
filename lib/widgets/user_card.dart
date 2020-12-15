import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/helpers/string_formatter.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/close_button.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../models/user.dart';

abstract class Showable {
  void show();
}

class UserCard implements Showable {
  final BuildContext context;
  final User user;

  UserCard(
    this.context,
    this.user,
  );

  /// Show modally the user card, close it smoothly with
  /// Navigator.pop(context).
  void show() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context, scrollController) => Column(
        children: [
          UserCardContent(user),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 80,
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.transparent,
      bounce: true,
      expand: true,
    );
  }
}

class UserCardContent extends StatefulWidget {
  final User user;

  UserCardContent(this.user);

  @override
  _UserCardContentState createState() => _UserCardContentState();
}

class _UserCardContentState extends State<UserCardContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      width: MediaQuery.of(context).size.width,
      child: Material(
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(10),
        child: SafeArea(
            top: false,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 80),
                      CachedCircleUserImage(
                        widget.user.pictureURL,
                        size: 200,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: TextSF(
                          StringFormatter().getNameAgeLabel(
                              widget.user.firstName, widget.user.age),
                          fontSize: TextSF.FontSize + 6,
                          fontWeight: FontWeight.w700,
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
                    ],
                  ),
                ),
                Positioned(
                  right: 30,
                  top: 50,
                  child: RoundedCloseButton(),
                )
              ],
            )),
      ),
    );
  }
}
