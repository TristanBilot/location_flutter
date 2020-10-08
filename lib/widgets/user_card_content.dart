import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location_project/widgets/like_dislike_button.dart';
import '../models/user.dart';

class UserCardContent extends StatelessWidget {
  final User user;

  const UserCardContent({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: 400,
      padding: EdgeInsets.all(20),
      child: Material(
          color: Color.fromARGB(255, 240, 240, 240),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: user.pictureURL,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 110,
                        height: 110,
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
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: user.distance == 0
                                  ? ''
                                  : '${user.distance} meters',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                  color: Color.fromARGB(255, 50, 50, 50)),
                            ),
                            // WidgetSpan(
                            //   child: Icon(
                            //     Icons.location_on,
                            //     color: Color.fromARGB(255, 50, 50, 50),
                            //     size: 16,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Spacer(),
                      LikeDislikeButton(
                          Icons.close, Colors.orange, Colors.pink),
                      Spacer(),
                      LikeDislikeButton(
                          Icons.favorite_border, Colors.pink, Colors.indigo),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
