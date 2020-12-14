import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/themes/dark_theme.dart';

class SwipeCardSection extends StatelessWidget {
  final User user;
  SwipeCardSection(this.user);

  final double _cardBorderRadius = 15.0;
  final double _descriptionContainerHeight = 80.0;

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
