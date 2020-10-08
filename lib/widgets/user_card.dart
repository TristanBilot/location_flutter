import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'bottom_sheet_content.dart';
import '../models/user.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

class UserCard extends StatelessWidget {
  final User user;

  const UserCard(this.user);

  @override
  Widget build(BuildContext context) {
    CardController controller;

    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        child: new TinderSwapCard(
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
            child: BottomSheetContent(
              user: user,
            ),
          ),
          cardController: controller = CardController(),
          swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
            /// Get swiping card's alignment
            if (align.x < 0) {
              //Card is LEFT swiping
            } else if (align.x > 0) {
              //Card is RIGHT swiping
            }
          },
          swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
            /// Get orientation & index of swiped card!
          },
        ),
      ),
    );
  }
}
