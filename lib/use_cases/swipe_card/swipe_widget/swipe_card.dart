import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';
import 'swipe_card_section.dart';
import 'dart:math';

List<Alignment> cardsAlign = [
  Alignment(0.0, 1.0),
  Alignment(0.0, 0.8),
  Alignment(0.0, 0.0)
];
List<Size> cardsSize = List(3);

class SwipeCard extends StatefulWidget {
  static const MaxHeight = 0.95;
  final List<User> users;

  SwipeCard(BuildContext context, this.users) {
    cardsSize[0] = Size(MediaQuery.of(context).size.width * MaxHeight,
        MediaQuery.of(context).size.height * 0.65);
    cardsSize[1] = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 0.6);
    cardsSize[2] = Size(MediaQuery.of(context).size.width * 0.85,
        MediaQuery.of(context).size.height * 0.55);
  }

  @override
  _SwipeCardState createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard>
    with SingleTickerProviderStateMixin {
  int totalCardsCounter = 0;
  int swappedCardCounter = 0;

  List<SwipeCardSection> cards = List();
  AnimationController _controller;

  final Alignment defaultFrontCardAlign = Alignment(0.0, 0.0);
  Alignment frontCardAlign;
  double frontCardRot = 0.0;

  @override
  void initState() {
    super.initState();
    // Init the animation controller
    // Init cards
    widget.users.forEach((user) {
      cards.add(SwipeCardSection(user));
      totalCardsCounter++;
    });

    frontCardAlign = cardsAlign[2];

    _controller =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) changeCardsOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(
      children: [
        emptyUsersPlaceholder(),
        backCard(),
        middleCard(),
        frontCard(),
        gestureDetector(),
      ],
    ));
  }

  Widget emptyUsersPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          CachedCircleUserImage(
            UserStore().user.pictureURL,
            borderColor: Colors.transparent,
            size: MediaQuery.of(context).size.width * 0.4,
          ),
          SizedBox(height: 30),
          TextSF(
            'Waiting for new people around... 🌏',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            align: TextAlign.center,
          ),
          Spacer(),
          BasicButton('Extend my distance 📍'),
        ],
      ),
    );
  }

  Widget backCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.backCardAlignmentAnim(_controller).value
          : cardsAlign[0],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.backCardSizeAnim(_controller).value
              : cardsSize[2],
          child: cards[2]),
    );
  }

  Widget middleCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.middleCardAlignmentAnim(_controller).value
          : cardsAlign[1],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.middleCardSizeAnim(_controller).value
              : cardsSize[1],
          child: cards[1]),
    );
  }

  Widget frontCard() {
    return Align(
        alignment: _controller.status == AnimationStatus.forward
            ? CardsAnimation.frontCardDisappearAlignmentAnim(
                    _controller, frontCardAlign)
                .value
            : frontCardAlign,
        child: Transform.rotate(
          angle: (pi / 180.0) * frontCardRot,
          child: SizedBox.fromSize(size: cardsSize[0], child: cards[0]),
        ));
  }

  Widget gestureDetector() {
    // Prevent swiping if the cards are animating
    return _controller.status != AnimationStatus.forward
        ? SizedBox.expand(
            child: GestureDetector(
            // While dragging the first card
            onPanUpdate: (DragUpdateDetails details) {
              // Add what the user swiped in the last frame to the alignment of the card
              setState(() {
                // 20 is the "speed" at which moves the card
                frontCardAlign = Alignment(
                    frontCardAlign.x +
                        20 *
                            details.delta.dx /
                            MediaQuery.of(context).size.width,
                    frontCardAlign.y +
                        40 *
                            details.delta.dy /
                            MediaQuery.of(context).size.height);

                frontCardRot = frontCardAlign.x; // * rotation speed;
              });
            },
            // When releasing the first card
            onPanEnd: (_) {
              // If the front card was swiped far enough to count as swiped
              if (frontCardAlign.x > 3.0 || frontCardAlign.x < -3.0) {
                animateCards();
              } else {
                // Return to the initial rotation and alignment
                setState(() {
                  frontCardAlign = defaultFrontCardAlign;
                  frontCardRot = 0.0;
                });
              }
            },
          ))
        : Container();
  }

  void changeCardsOrder() {
    setState(() {
      // Swap cards (back card becomes the middle card; middle card becomes the front card, front card becomes a  bottom card)
      int remainingUsers = widget.users.length - swappedCardCounter;
      if (remainingUsers >= 3) {
        var temp = cards[0];
        cards[0] = cards[1];
        cards[1] = cards[2];
        cards[2] = temp;

        cards[2] = totalCardsCounter >= widget.users.length
            ? null
            : SwipeCardSection(widget.users[totalCardsCounter++]);
      } else if (remainingUsers == 2) {
        cards[0] = cards[1];
        cards[1] = cards[2];
      } else if (remainingUsers == 1) {
        cards[0] = cards[1];
      }
      swappedCardCounter++;

      frontCardAlign = defaultFrontCardAlign;
      frontCardRot = 0.0;
    });
  }

  void animateCards() {
    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();
  }
}

class CardsAnimation {
  static Animation<Alignment> backCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[0], end: cardsAlign[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Size> backCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[2], end: cardsSize[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Alignment> middleCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[1], end: cardsAlign[2]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Size> middleCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[1], end: cardsSize[0]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(
      AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
            begin: beginAlign,
            end: Alignment(
                beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0,
                0.0) // Has swiped to the left or right?
            )
        .animate(CurvedAnimation(
            parent: parent, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
  }
}
