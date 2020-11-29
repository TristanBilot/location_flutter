import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';

class SwipeCardSection extends StatelessWidget {
  final int cardNum;
  final User user;
  SwipeCardSection(this.cardNum, this.user);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(20),
              child: user == null
                  ? Image.asset(
                      'assets/mock_images/damien.duprat@hotmail.fr.png', //
                      fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: user == null ? '' : user.pictureURL,
                      fit: BoxFit.cover),
            ),
          ),
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter)),
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
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700)),
                    Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    Text('A short description.',
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.white)),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
