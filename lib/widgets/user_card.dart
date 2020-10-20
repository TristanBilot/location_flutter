import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location_project/controllers/messaging_controller.dart';
import 'package:location_project/stores/map_store.dart';
import 'package:location_project/use_cases/swipe/swipe_controller.dart';
import 'user_card_content.dart';
import '../models/user.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:flutter/services.dart';
import 'map.dart';

class UserCard extends StatefulWidget {
  final User user;

  UserCard(this.user);

  static _UserCardState of(BuildContext context) =>
      context.findAncestorStateOfType<_UserCardState>();

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  MessagingController _messagingController;

  @override
  void initState() {
    super.initState();
    _messagingController = MessagingController();
  }

  void sendMessage(String message) {
    // _messagingController...
  }

  Future<void> sendHelloNotif() async {
    return Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    // To dismiss keyboard.
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) currentFocus.unfocus();
      },
      child: Center(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 5),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            // child: Card(
            child: UserCardContent(
              user: widget.user,
              onTextSubmitted: sendMessage,
              onSayHiTap: sendHelloNotif,
            ),
            // ),
          ),
        ),
      ),
    );
  }
}
