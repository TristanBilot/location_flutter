import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/themes/light_theme.dart';
import 'package:location_project/use_cases/swipe_card/swipe_widget/swipe_card_section_image.dart';
import 'package:location_project/widgets/gradient_icon.dart';
import 'package:uuid/uuid.dart';

class SwipeCardSection extends StatefulWidget {
  final int index;
  final Key key;
  final User user;
  final Function(User, int index) likeCallback;
  final Function(User, int index) unlikeCallback;

  static Map<int, int> CurrentlyDisplayedPictureIndex = Map();

  const SwipeCardSection(
    this.index,
    this.key,
    this.user,
    this.likeCallback,
    this.unlikeCallback,
  ) : super(key: key);

  @override
  _SwipeCardSectionState createState() => _SwipeCardSectionState();
}

class _SwipeCardSectionState extends State<SwipeCardSection> {
  final double _cardBorderRadius = 15.0;
  final double _descriptionContainerHeight = 110.0;
  final String _cardID = Uuid().v4();

  int _displayedPictureIndex;
  String _displayedPictureURL;

  @override
  void initState() {
    super.initState();

    _displayedPictureIndex = 0;
    _displayedPictureURL = widget.user.mainPictureURL;
  }

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
            onPressed: () => widget.unlikeCallback(widget.user, widget.index),
            backgroundColor: color,
            child: GradientIcon(Icons.close, 26, GreyGradient),
          ),
          Padding(padding: EdgeInsets.only(right: 8.0)),
          FloatingActionButton(
            heroTag: null,
            onPressed: () => widget.likeCallback(widget.user, widget.index),
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

  /* ! linked to the max width of swipe_card.dart */
  double _getExactlyHalfOfCardWidth() {
    double minWidth = MediaQuery.of(context).size.width * 0.82;
    double maxWidth = MediaQuery.of(context).size.width * 0.92;
    double average = (minWidth + maxWidth) / 2;
    return average / 2;
  }

  _updateCurrentlyDisplayedPicture({@required bool increment}) {
    int index =
        increment ? _displayedPictureIndex + 1 : _displayedPictureIndex - 1;
    if (index >= widget.user.pictureURLs.length || index < 0) {
      HapticFeedback.vibrate();
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        SwipeCardSection.CurrentlyDisplayedPictureIndex[widget.index] = index;
        _displayedPictureIndex = index;
        _displayedPictureURL = widget.user.pictureURLs[index];
      });
      // _displayedPictureIndex = index;
      // context
      //     .read<SwipeImageCubit>()
      //     .changeDisplayedImage(_cardID, widget.user.pictureURLs[index]);
    }
  }

  void _updateDisplayedPictureIfNeeded() {
    _displayedPictureURL = widget.user.pictureURLs[
        SwipeCardSection.CurrentlyDisplayedPictureIndex[widget.index]];
    _displayedPictureIndex =
        SwipeCardSection.CurrentlyDisplayedPictureIndex[widget.index];
  }

  @override
  Widget build(BuildContext context) {
    _updateDisplayedPictureIfNeeded();
    return Card(
      elevation: 6,
      shadowColor: _getCardShadowColor(context),
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Stack(
            children: [
              Container(
                padding:
                    EdgeInsets.only(bottom: _descriptionContainerHeight - 10),
                child: SizedBox.expand(
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(_cardBorderRadius),
                        topRight: Radius.circular(_cardBorderRadius)),
                    child: SwipeCardSectionImage(
                      UniqueKey(),
                      _cardID,
                      _displayedPictureURL,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: _getExactlyHalfOfCardWidth(),
                      child: GestureDetector(
                        onTap: () =>
                            _updateCurrentlyDisplayedPicture(increment: false),
                      ),
                    ),
                  ),
                  Container(
                    width: _getExactlyHalfOfCardWidth(),
                    child: GestureDetector(
                      onTap: () =>
                          _updateCurrentlyDisplayedPicture(increment: true),
                    ),
                  ),
                ],
              ),
            ],
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
                        widget.user == null
                            ? 'mock'
                            : '${widget.user.firstName}, ${widget.user.age}',
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
