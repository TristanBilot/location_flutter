import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'user_card_content.dart';
import '../models/user.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'map.dart';

class UserCard extends StatefulWidget {
  final User user;
  final MapState mapState;

  UserCard(this.user, this.mapState);

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  @override
  Widget build(BuildContext context) {
    CardController controller;

    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: TinderSwapCard(
          swipeUp: true,
          swipeDown: true,
          orientation: AmassOrientation.BOTTOM,
          totalNum: 1,
          stackNum: 3,
          swipeEdge: 4.0,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.width * 0.9,
          minWidth: MediaQuery.of(context).size.width * 0.8,
          minHeight: MediaQuery.of(context).size.width * 0.8,
          cardBuilder: (context, index) => Card(
            child: UserCardContent(
              user: widget.user,
            ),
          ),
          cardController: controller = CardController(),
          swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
            widget.mapState.setState(() {
              int baseShade = widget.mapState.barrierColorBaseShade;
              int shade = baseShade ~/ (align.x.abs() + align.y.abs());
              shade = shade > baseShade ? baseShade : shade;
              var color = Color.fromARGB(shade, 0, 0, 0);
              widget.mapState.barrierColor = color;
            });

            /// Get swiping card's alignment
            if (align.x < 0) {
              //Card is LEFT swiping
            } else if (align.x > 0) {
              //Card is RIGHT swiping
            }
          },
          swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
            /// Get orientation & index of swiped card!
            Navigator.of(context, rootNavigator: true).pop(true);
            widget.mapState.setState(() {
              widget.mapState.isModalDisplayed = false;
            });
          },
        ),
      ),
    );
  }
}
