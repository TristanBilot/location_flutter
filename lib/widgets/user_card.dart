import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:location_project/stores/map_store.dart';
import 'package:location_project/use_cases/swipe/swipe_controller.dart';
import 'user_card_content.dart';
import '../models/user.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:flutter/services.dart';
import 'map.dart';

class UserCard extends StatefulWidget {
  final User user;
  final MapState mapState;
  final MapStore mapStore;

  UserCard(this.mapStore, this.mapState, this.user);

  static _UserCardState of(BuildContext context) =>
      context.findAncestorStateOfType<_UserCardState>();

  @override
  _UserCardState createState() =>
      _UserCardState(this.mapStore, this.mapState, this.user);
}

class _UserCardState extends State<UserCard> {
  // x axis which determine when the card is swapped
  final _swipeEdge = 4.0;
  double _lastX = 0.0;
  SwipeController _swipeController;

  _UserCardState(store, state, user) {
    _swipeController = SwipeController(store, state, user);
  }

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
          swipeEdge: _swipeEdge,
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

            _lastX = align.x;
          },
          swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
            print(_lastX);
            if (_lastX.abs() > _swipeEdge) {
              _swipeController
                  .swipe(_lastX < 0 ? SwipeSide.left : SwipeSide.right);
            }

            // if (_lastX < 0) {
            //   if (absX > _swipeEdge) ;
            //   //Card is LEFT swiping
            // } else if (align.x > 0) {
            //   if (absX > _swipeEdge) ;
            //   //Card is RIGHT swiping
            // }

            /// Get orientation & index of swiped card!
            Navigator.of(context, rootNavigator: true).pop(true);
            HapticFeedback.heavyImpact();
            widget.mapState.setState(() {
              widget.mapState.isModalDisplayed = false;
            });
          },
        ),
      ),
    );
  }
}
