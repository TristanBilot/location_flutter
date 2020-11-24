import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

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

  Color _shimmerBaseColor(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark
        ? Theme.of(context).primaryColor
        : Theme.of(context).backgroundColor;
  }

  Color _shimmerHighlightColor(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDark ? Colors.grey[800] : Colors.grey[300];
  }

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
      placeholder: (context, url) => Container(
        child: Shimmer.fromColors(
          baseColor: _shimmerBaseColor(context),
          highlightColor: _shimmerHighlightColor(context),
          enabled: true,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
