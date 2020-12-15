import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/storage/distant/user_store.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_button.dart';
import 'package:location_project/use_cases/start_path/widgets/basic_gradient_border_button.dart';
import 'package:location_project/use_cases/swipe_card/swipe%20cubit/swipe_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/wave_clipper.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';
import 'package:location_project/widgets/textSF.dart';

class SwipePage extends StatefulWidget {
  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final _horizontalPadding = 15.0;
  final _littlePictureSize = 100.0;
  final _bigPictureSize = 150.0;
  final _bigImageOffset = 50.0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MemoryStore().setCurvedAnimationDisplayed(true);
      final _backgroundColor =
          MediaQuery.of(context).platformBrightness == Brightness.dark
              ? DarkTheme.BackgroundDarkColor
              : Theme.of(context).backgroundColor;
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                insetPadding:
                    EdgeInsets.symmetric(horizontal: _horizontalPadding),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: _backgroundColor,
                content: Builder(
                  builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width * 1.3,
                    child: Center(
                      child: Column(
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
                                    MemoryStore().users.first.pictureURL,
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
                            'You can now chat with ${MemoryStore().users.first.firstName}',
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
                          ),
                          SizedBox(height: 10),
                          BasicGradientBorderButton(
                            'KEEP SWIPPING',
                            fontsSize: 16,
                            onPressed: () => {},
                            textColor:
                                MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : PrimaryColor,
                            width: MediaQuery.of(context).size.width * 0.7,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double curveHeight = MediaQuery.of(context).padding.top + 90;
    return Stack(
      children: [
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
              return SwipeCard(context, state.users);
              // []..addAll(state.users)..addAll(state.users)
            }
            return SizedBox(height: SwipeCard.MaxHeight);
          }),
          SizedBox(height: 10)
        ]),
      ],
    );
  }
}
