import 'package:flutter/material.dart';
import 'package:location_project/themes/dark_theme.dart';
import 'package:location_project/widgets/cached_circle_user_image.dart';

class CachedCircleUserImageWithActiveStatus extends StatefulWidget {
  final String pictureURL;
  final bool isActive;
  final double size;
  final double statusSize;
  final Alignment statusAlignment;
  final Function onTapped;
  final Color borderColor;

  CachedCircleUserImageWithActiveStatus({
    this.pictureURL,
    this.isActive,
    this.size = 55,
    this.statusSize = 15,
    this.statusAlignment = Alignment.topRight,
    this.onTapped,
    this.borderColor,
  });

  @override
  _CachedCircleUserImageWithActiveStatusState createState() =>
      _CachedCircleUserImageWithActiveStatusState();
}

class _CachedCircleUserImageWithActiveStatusState
    extends State<CachedCircleUserImageWithActiveStatus> {
  Color get _getStatusBorderColor {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? DarkTheme.BackgroundDarkColor : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTapped,
      child: Stack(
        alignment: widget.statusAlignment,
        children: [
          CachedCircleUserImage(
            widget.pictureURL,
            size: widget.size,
            borderColor: widget.borderColor,
          ),
          widget.isActive
              ? Container(
                  padding: EdgeInsets.only(top: 40),
                  height: widget.statusSize,
                  width: widget.statusSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    border: Border.all(color: _getStatusBorderColor, width: 2),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
