import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/widgets/scrollable_textview.dart';
import 'package:location_project/widgets/textSF.dart';
import '../models/user.dart';

class UserCardContent extends StatefulWidget {
  final User user;
  final Function(String value) onTextSubmitted;

  UserCardContent({
    @required this.user,
    @required this.onTextSubmitted,
  });

  @override
  _UserCardContentState createState() => _UserCardContentState();
}

class _UserCardContentState extends State<UserCardContent> {
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String getNameAgeLabel() {
    final name = widget.user.firstName, age = widget.user.age;
    if (name == null && age == null) return null;
    if (name != null && age == null) return name;
    if (name == null && age != null) return age.toString();
    return '$name, ${age.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 400,
      padding: EdgeInsets.all(20),
      child: Material(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(10),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.user.pictureURL,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 1,
                              color: Colors.grey,
                              style: BorderStyle.solid),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.fill),
                        ),
                      ),
                      placeholder: (context, url) => CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        strokeWidth: 3.0,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  // Expanded(
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: TextSF(
                      getNameAgeLabel(),
                      fontSize: TextSF.FontSize + 4,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 6, 0, 0),
                    child: TextSF(
                      widget.user.distance == 0
                          ? ''
                          : '${widget.user.distance} meters',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: ScrollableTextView(
                      withTrailingButton: true,
                      controller: _textController,
                      trailingButtonOnPressed: () => {},
                      onTextSubmitted: widget.onTextSubmitted,
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}
