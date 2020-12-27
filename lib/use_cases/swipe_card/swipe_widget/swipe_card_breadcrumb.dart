import 'package:flutter/material.dart';
import 'package:location_project/themes/dark_theme.dart';

class SwipeCardBreadcrumb extends StatelessWidget {
  final int index;
  final int max;
  final double cardWidth;

  const SwipeCardBreadcrumb(
    Key key,
    this.index,
    this.max,
    this.cardWidth,
  ) : super(key: key);

  BorderRadiusGeometry _getBorderRadius(int i) {
    double rad = 10.0;
    if (max == 1) return BorderRadius.circular(rad);
    if (i == 0)
      return BorderRadius.only(
        bottomLeft: Radius.circular(rad),
        topLeft: Radius.circular(rad),
      );
    if (i == max - 1)
      return BorderRadius.only(
        bottomRight: Radius.circular(rad),
        topRight: Radius.circular(rad),
      );
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = DarkTheme.BackgroundDarkColor.withAlpha(180);
    final unselectedColor = selectedColor.withAlpha(100);
    final sideMargin = 10.0;
    final elementWidth = (cardWidth / max) - (2 * sideMargin);

    return Row(
      children: List.generate(max, (i) => i)
          .map(
            (i) => Container(
              width: elementWidth,
              height: 5,
              decoration: BoxDecoration(
                color: i == (index) ? selectedColor : unselectedColor,
                borderRadius: _getBorderRadius(i),
              ),
            ),
          )
          .toList(),
    );
  }
}
