import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/swipe_card/swipe%20cubit/swipe_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card_section.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/wave_clipper.dart';
import 'package:location_project/use_cases/tab_pages/navigation/cubit/navigation_cubit.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';

mixin SwipePageDelegate {
  void swipe({@required bool left});
}

class SwipePage extends StatefulWidget {
  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage>
    with TickerProviderStateMixin, SwipePageDelegate {
  CardController _cardController;

  @override
  void initState() {
    _cardController = CardController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MemoryStore().setCurvedAnimationDisplayed(true);
    });
    super.initState();
  }

  @override
  void swipe({@required bool left}) {
    if (left)
      _cardController.triggerLeft();
    else
      _cardController.triggerRight();
  }

  Widget _buildSwipeFeed(List<User> users) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.74,
      child: TinderSwapCard(
        swipeUp: true,
        swipeDown: true,
        orientation: AmassOrientation.BOTTOM,
        totalNum: users.length,
        stackNum: 3,
        swipeEdge: 4.0,
        maxWidth: MediaQuery.of(context).size.width * 0.92,
        maxHeight: MediaQuery.of(context).size.height * 0.72,
        minWidth: MediaQuery.of(context).size.width * 0.82,
        minHeight: MediaQuery.of(context).size.height * 0.66,
        cardBuilder: (context, index) => SwipeCardSection(users[index], this),
        cardController: _cardController,
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
    );
  }

  Widget _emptyUsersPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Spacer(),
          CachedCircleUserImage(
            UserStore().user.mainPictureURL,
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
          SizedBox(height: 60),
          BasicButton('EXTEND DISTANCE 📍',
              fontsSize: 18,
              onPressed: () => context.read<NavigationCubit>().navigateTo(0)),
          Spacer(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double curveHeight = MediaQuery.of(context).padding.top + 90;
    return Stack(
      children: [
        _emptyUsersPlaceholder(),
        BottomWaveContainer(
          !MemoryStore().isCurvedAnimationDisplayed,
          Container(
            height: curveHeight,
            alignment: Alignment.bottomLeft,
            padding: EdgeInsets.only(left: 16, bottom: 40),
            decoration: BoxDecoration(
                gradient: ThemeUtils.getResponsiveGradient(context)),
            child: Text(
              'Near me',
              style: CupertinoTheme.of(context)
                  .textTheme
                  .navLargeTitleTextStyle
                  .copyWith(color: Colors.white, fontSize: 32),
            ),
          ),
        ),
        Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Padding(padding: EdgeInsets.only(top: curveHeight - 30)),
          BlocBuilder<SwipeCubit, SwipeState>(builder: (context, state) {
            if (state is SwipableUsersFetched) {
              return _buildSwipeFeed(state.users);
            }
            return SizedBox();
          }),
          SizedBox(height: 10)
        ]),
      ],
    );
  }
}
