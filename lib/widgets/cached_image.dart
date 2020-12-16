import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double borderWidth;
  final Color borderColor;
  final bool withBorder;
  final BoxFit fit;
  final double borderRadius;

  CachedImage(
    this.imageUrl, {
    this.height,
    this.width,
    this.borderWidth = 1.0,
    this.borderColor,
    this.withBorder = false,
    this.fit,
    this.borderRadius = 0,
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
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: withBorder
              ? Border.all(
                  width: borderWidth,
                  color: borderColor,
                  style: BorderStyle.solid,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
        ),
      ),
      placeholder: (context, url) => Container(
        child: Shimmer.fromColors(
          baseColor: _shimmerBaseColor(context),
          highlightColor: _shimmerHighlightColor(context),
          enabled: true,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
