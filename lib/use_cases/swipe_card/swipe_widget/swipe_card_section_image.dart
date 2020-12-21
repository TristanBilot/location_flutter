import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SwipeCardSectionImage extends StatefulWidget {
  final String cardID;
  final String pictureURL;

  SwipeCardSectionImage(Key key, this.cardID, this.pictureURL)
      : super(key: key);

  @override
  _SwipeCardSectionImageState createState() =>
      _SwipeCardSectionImageState(this.pictureURL);
}

class _SwipeCardSectionImageState extends State<SwipeCardSectionImage> {
  String pictureURL;

  _SwipeCardSectionImageState(this.pictureURL);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: CachedNetworkImage(
        imageUrl: pictureURL,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).backgroundColor,
        ),
        fadeInDuration: Duration(milliseconds: 100),
        fadeOutDuration: Duration(milliseconds: 100),
      ),
    );
  }
}
