import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:location_project/helpers/distance_adapter.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/widgets/cached_image.dart';
import 'package:location_project/widgets/textSF.dart';

class PremiumUserCard extends StatefulWidget {
  final User user;
  const PremiumUserCard(this.user);

  @override
  _PremiumUserCardState createState() => _PremiumUserCardState();
}

class _PremiumUserCardState extends State<PremiumUserCard> {
  static final double radius = 10.0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Container(
          child: SizedBox.expand(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedImage(widget.user.mainPictureURL),
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              end: const Alignment(0.0, -1),
              begin: const Alignment(0.0, 1),
              colors: [
                Colors.black38,
                Colors.black12.withOpacity(0.0),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0, left: 8.0, right: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: TextSF('${widget.user.firstName}, ${widget.user.age}',
                    fontSize: 19),
              ),
              TextSF('${DistanceAdapter().adapt(widget.user.distance)}'),
            ],
          ),
        ),
      ],
    );
  }
}
