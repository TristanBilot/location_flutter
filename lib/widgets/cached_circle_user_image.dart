import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedCircleUserImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final BoxShape shape;
  final bool withBorder;

  CachedCircleUserImage(
    this.imageUrl, {
    this.size = 80,
    this.borderWidth = 1.0,
    this.borderColor = Colors.grey,
    this.shape = BoxShape.circle,
    this.withBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: withBorder
              ? Border.all(
                  width: borderWidth,
                  color: borderColor,
                  style: BorderStyle.solid,
                )
              : null,
          shape: shape,
          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        strokeWidth: 3.0,
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}