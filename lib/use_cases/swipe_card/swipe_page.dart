import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe%20cubit/swipe_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card.dart';

class SwipePage extends StatefulWidget {
  @override
  _SwipePageState createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      BlocBuilder<SwipeCubit, SwipeState>(builder: (context, state) {
        if (state is SwipableUsersFetched) {
          return SwipeCard(context, state.users);
        }
        return SizedBox(height: SwipeCard.MaxHeight);
      }),
      buttonsRow(),
    ]);
  }

  Widget buttonsRow() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 48.0),
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
