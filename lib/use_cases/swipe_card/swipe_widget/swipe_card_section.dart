import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/swipe_card/buttons%20cubit/swipe_buttons_cubit.dart';
import 'package:location_project/use_cases/swipe_card/swipe_page.dart';
import 'package:location_project/widgets/gradient_icon.dart';

class SwipeCardSection extends StatelessWidget {
  final User user;
  final SwipePageDelegate delegate;
  SwipeCardSection(this.user, this.delegate);

  final double _cardBorderRadius = 15.0;
  final double _descriptionContainerHeight = 110.0;

  Color _getCardShadowColor(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Color.fromARGB(255, 0, 0, 0)
        : Color.fromARGB(255, 255, 255, 255);
  }

  Color _getDescriptionContainerColor(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? DarkTheme.PrimaryDarkColor
        : Colors.white;
  }

  Widget _buttonsRow(BuildContext context) {
    final color = MediaQuery.of(context).platformBrightness == Brightness.dark
        ? DarkTheme.BackgroundDarkColor
        : Theme.of(context).backgroundColor;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: null,
            mini: true,
            onPressed: () {},
            backgroundColor: color,
            child: Icon(Icons.loop, color: Colors.yellow),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              delegate.swipe(left: true);
              context.read<SwipeButtonsCubit>().unlike(user);
            },
            backgroundColor: color,
            child: GradientIcon(Icons.close, 26, GreyGradient),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              delegate.swipe(left: false);
              context.read<SwipeButtonsCubit>().like(user, context);
            },
            backgroundColor: color,
            child: GradientIcon(Icons.favorite, 26, AppGradient),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: null,
            mini: true,
            onPressed: () {},
            backgroundColor: color,
            child: Icon(Icons.star, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: _getCardShadowColor(context),
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: _descriptionContainerHeight - 10),
            child: SizedBox.expand(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_cardBorderRadius),
                    topRight: Radius.circular(_cardBorderRadius)),
                child: CachedNetworkImage(
                    imageUrl: user.pictureURL, fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            height: _descriptionContainerHeight,
            decoration: BoxDecoration(
              color: _getDescriptionContainerColor(context),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(_cardBorderRadius),
                  bottomRight: Radius.circular(_cardBorderRadius)),
            ),
          ),
          Positioned(
            bottom: 67,
            child: _buttonsRow(context),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        user == null
                            ? 'mock'
                            : '${user.firstName}, ${user.age}',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.w700)),
                    Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    Text('A short description.', textAlign: TextAlign.start),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
