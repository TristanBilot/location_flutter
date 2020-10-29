import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedCircleUserImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final BoxShape shape;
  final bool withBorder;
  final BoxFit fit;

  CachedCircleUserImage(
    this.imageUrl, {
    this.size = 80,
    this.borderWidth = 1.0,
    this.borderColor,
    this.shape = BoxShape.circle,
    this.withBorder = true,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: withBorder
              ? Border.all(
                  width: borderWidth,
                  color: borderColor ?? Colors.grey,
                  style: BorderStyle.solid,
                )
              : null,
          shape: shape,
          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).primaryColor,
        ),
        strokeWidth: 3.0,
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
