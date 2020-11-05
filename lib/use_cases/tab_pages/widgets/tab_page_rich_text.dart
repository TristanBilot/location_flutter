import 'package:flutter/material.dart';

class TabPageRichText extends StatelessWidget {
  final String firstName;
  final int distance;
  final bool isMsgUnread;
  final FontWeight readWeight;
  final FontWeight unreadWeight;

  TabPageRichText(
    this.firstName,
    this.distance, {
    this.isMsgUnread = false,
    this.readWeight = FontWeight.w300,
    this.unreadWeight = FontWeight.w700,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).textTheme.headline6.color),
          children: [
            TextSpan(
              text: '$firstName',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: isMsgUnread ? unreadWeight : FontWeight.w500),
            ),
            TextSpan(
              text: '  -  ${distance}m',
              style: TextStyle(
                fontSize: 11,
                fontWeight: readWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
