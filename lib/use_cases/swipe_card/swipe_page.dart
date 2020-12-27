import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe%20cubit/swipe_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card_section.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/wave_clipper.dart';
import 'package:location_project/use_cases/tab_pages/navigation/cubit/navigation_cubit.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';
import 'package:provider/provider.dart';

class SwipePage extends StatefulWidget {
  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  CardController _cardController;
  List<User> _users;

  @override
  void initState() {
    _cardController = CardController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MemoryStore().setCurvedAnimationDisplayed(true);
    });
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  _unlike(User user, int index) {
    _cardController.triggerLeft();
  }

  _like(User user, int index) {
    _cardController.triggerRight();
  }

  _handleLeft(User user) {
    context.read<SwipeButtonsCubit>().unlike(user);
    _resetCurrentlyDisplayedPictureIndexes();
    setState(() {});
  }

  _handleRight(User user) {
    context.read<SwipeButtonsCubit>().like(user, context);
    _resetCurrentlyDisplayedPictureIndexes();
    setState(() {});
  }

  void _resetCurrentlyDisplayedPictureIndexes() {
    for (int i = 0; i < _users.length; i++)
      SwipeCardSection.CurrentlyDisplayedPictureIndex[i] = 0;
  }

  Widget _buildSwipeFeed() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.74,
      child: TinderSwapCard(
        swipeUp: true,
        swipeDown: true,
        orientation: AmassOrientation.BOTTOM,
        totalNum: _users.length,
        stackNum: 2,
        swipeEdge: 4.0,
        allowVerticalMovement: false,

        /* /!\ min & max widths are linked to the width of 
        * gesture destector of swipe_card_section.dart
        */
        minWidth: MediaQuery.of(context).size.width * 0.82,
        maxWidth: MediaQuery.of(context).size.width * 0.92,
        minHeight: MediaQuery.of(context).size.height * 0.66,
        maxHeight: MediaQuery.of(context).size.height * 0.72,
        cardController: _cardController,
        cardBuilder: (context, index) {
          return SwipeCardSection(
            index,
            UniqueKey(),
            _users[index],
            _like,
            _unlike,
          );
        },
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
          if (orientation == CardSwipeOrientation.LEFT) {
            _handleLeft(_users[index]);
          } else if (orientation == CardSwipeOrientation.RIGHT) {
            _handleRight(_users[index]);
          }
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
    super.build(context);
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
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BlocListener<SwipeCubit, SwipeState>(
              listener: (context, state) {
                if (state is SwipableUsersFetched) {
                  setState(() {
                    _users = state.users;
                    _resetCurrentlyDisplayedPictureIndexes();
                  });
                }
              },
              child: (_users == null || _users.isEmpty)
                  ? SizedBox(height: 10)
                  : _buildSwipeFeed(),
            ),
            Padding(padding: EdgeInsets.only(bottom: 30)),
          ],
        ),
      ],
    );
  }
}
