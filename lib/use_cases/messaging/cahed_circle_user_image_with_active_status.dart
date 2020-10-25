import 'package:flutter/material.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';

class CachedCircleUserImageWithActiveStatus extends StatefulWidget {
  final String pictureURL;
  final bool isActive;
  final double size;
  final Function onTapped;

  CachedCircleUserImageWithActiveStatus({
    this.pictureURL,
    this.isActive,
    this.size = 55,
    this.onTapped,
  });

  @override
  _CachedCircleUserImageWithActiveStatusState createState() =>
      _CachedCircleUserImageWithActiveStatusState();
}

class _CachedCircleUserImageWithActiveStatusState
    extends State<CachedCircleUserImageWithActiveStatus> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapped,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          CachedCircleUserImage(
            widget.pictureURL,
            size: widget.size,
          ),
          widget.isActive
              ? Container(
                  padding: EdgeInsets.only(top: 40),
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
