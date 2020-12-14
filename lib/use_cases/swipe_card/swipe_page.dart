import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/storage/memory/memory_store.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/themes/theme_utils.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe%20cubit/swipe_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/wave_clipper.dart';

class SwipePage extends StatefulWidget {
  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => MemoryStore().setCurvedAnimationDisplayed(true));
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
          buttonsRow(),
        ]),
      ],
    );
  }

  Widget buttonsRow() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            mini: true,
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.loop, color: Colors.yellow),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            onPressed: () => context.read<SwipeButtonsCubit>().emitUnlike(),
            backgroundColor: Colors.white,
            child: Icon(Icons.close, color: Colors.red),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            onPressed: () => context.read<SwipeButtonsCubit>().emitLike(),
            backgroundColor: Colors.white,
            child: Icon(Icons.favorite, color: Colors.green),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            mini: true,
            onPressed: () {},
            backgroundColor: Colors.white,
            child: Icon(Icons.star, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
