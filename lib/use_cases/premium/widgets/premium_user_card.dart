import 'package:flutter/material.dart';
import 'package:location_project/models/user.dart';
import 'package:location_project/widgets/cached_image.dart';

class PremiumUserCard extends StatefulWidget {
  final User user;
  const PremiumUserCard(this.user);

  @override
  _PremiumUserCardState createState() => _PremiumUserCardState();
}

class _PremiumUserCardState extends State<PremiumUserCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox.expand(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedImage(widget.user.mainPictureURL),
        ),
      ),
    );
  }
}
