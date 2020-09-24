import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class BottomSheetContent extends StatelessWidget {
  final User user;

  const BottomSheetContent({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
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
                        width: 1, color: Colors.grey, style: BorderStyle.solid),
                    shape: BoxShape.circle,
                    image:
                        DecorationImage(image: imageProvider, fit: BoxFit.fill),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  strokeWidth: 3.0,
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 7, 0, 30),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '32 meters',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.location_on,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                )),
            Center(
              child: RaisedButton(
                onPressed: () => {},
                color: Colors.blue,
                child: Text(
                  'Send a message',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  // Widget build(BuildContext context) {
  //   return Material(
  //       child: SafeArea(
  //     top: false,
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: <Widget>[
  //         ListTile(
  //           title: Text('Edit'),
  //           leading: Icon(Icons.edit),
  //           onTap: () => Navigator.of(context).pop(),
  //         ),
  //         ListTile(
  //           title: Text('Copy'),
  //           leading: Icon(Icons.content_copy),
  //           onTap: () => Navigator.of(context).pop(),
  //         ),
  //         ListTile(
  //           title: Text('Cut'),
  //           leading: Icon(Icons.content_cut),
  //           onTap: () => Navigator.of(context).pop(),
  //         ),
  //         ListTile(
  //           title: Text('Move'),
  //           leading: Icon(Icons.folder_open),
  //           onTap: () => Navigator.of(context).pop(),
  //         ),
  //         ListTile(
  //           title: Text('Delete'),
  //           leading: Icon(Icons.delete),
  //           onTap: () => Navigator.of(context).pop(),
  //         )
  //       ],
  //     ),
  //   ));
  // }
}
